import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/add_player_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum _Step { picker, createForm }

enum _Tab { myPlayers, appUsers }

/// Pauses typing before the "My players" search re-queries the server.
const Duration _searchDebounce = Duration(milliseconds: 350);

/// Loose shape check that only gates the Find button; the server does the real
/// validation and answers the same `USER_NOT_FOUND` for anything it can't match.
final RegExp _looksLikeEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// The add-player sheet's body: pick one of the scorer's existing players,
/// find an app user by exact email and invite them, or fall through to the
/// original "create a new player" form. One sheet with a step switch rather
/// than a second sheet — a GetX snackbar is a route, so stacking sheets would
/// make `Get.back()` close the wrong one.
///
/// Server errors are shown inline (never as a snackbar) for the same reason,
/// and are the server's own localized message.
class AddPlayerPicker extends StatefulWidget {
  const AddPlayerPicker({
    required this.controller,
    required this.onDone,
    super.key,
  });

  final TeamProfileController controller;

  /// Called once a player has been added or invited; closes the sheet.
  final VoidCallback onDone;

  @override
  State<AddPlayerPicker> createState() => _AddPlayerPickerState();
}

class _AddPlayerPickerState extends State<AddPlayerPicker> {
  final _search = TextEditingController();
  final _email = TextEditingController();

  _Step _step = _Step.picker;
  _Tab _tab = _Tab.myPlayers;

  // My players
  final List<MyPlayerRow> _players = [];
  int _page = 1;
  bool _hasMore = false;
  bool _loadingPlayers = true;
  String? _playersError;
  String? _addError;
  String? _addingId;
  Timer? _debounce;

  /// Bumped per query; a slower response for an older query is dropped.
  int _generation = 0;

  // App users
  LookedUpUserRes? _found;
  String? _lookupError;
  bool _lookingUp = false;

  /// Bumped whenever the email is edited or a lookup starts. A lookup only
  /// applies if it is still the latest, so an answer for an address the scorer
  /// has since changed can never surface a card — and an Invite button — for
  /// someone they did not ask about.
  int _lookupGeneration = 0;
  bool _inviting = false;
  String? _inviteError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPlayers(reset: true));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers({required bool reset}) async {
    final generation = ++_generation;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _loadingPlayers = true;
      _playersError = null;
    });

    final (res, error) = await widget.controller.loadMyPlayers(
      q: _search.text.trim(),
      page: page,
    );

    if (!mounted || generation != _generation) return;
    setState(() {
      _loadingPlayers = false;
      if (res == null) {
        _playersError = error;
        return;
      }
      if (reset) _players.clear();
      _players.addAll(res.players);
      _page = res.page;
      _hasMore = res.hasMore;
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(
      _searchDebounce,
      () => unawaited(_loadPlayers(reset: true)),
    );
  }

  Future<void> _addExisting(MyPlayerRow player) async {
    if (_addingId != null) return;
    setState(() {
      _addingId = player.playerId;
      _addError = null;
    });

    final error = await widget.controller.addExistingPlayer(player.playerId);

    if (!mounted) return;
    if (error == null) {
      widget.onDone();
    } else {
      setState(() {
        _addingId = null;
        _addError = error;
      });
    }
  }

  Future<void> _find() async {
    if (_lookingUp) return;
    final generation = ++_lookupGeneration;
    setState(() {
      _lookingUp = true;
      _found = null;
      _lookupError = null;
      _inviteError = null;
    });

    final (user, error) = await widget.controller.lookupUserByEmail(
      _email.text,
    );

    if (!mounted || generation != _lookupGeneration) return;
    setState(() {
      _lookingUp = false;
      _found = user;
      _lookupError = error;
    });
  }

  Future<void> _invite(LookedUpUserRes user) async {
    if (_inviting) return;
    setState(() {
      _inviting = true;
      _inviteError = null;
    });

    final error = await widget.controller.inviteUser(user.userId);

    if (!mounted) return;
    if (error == null) {
      widget.onDone();
    } else {
      setState(() {
        _inviting = false;
        _inviteError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _Step.createForm) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _step = _Step.picker),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: CricketText(text: TranslationKeys.backToPlayers.tr),
            ),
            8.h,
            AddPlayerForm(
              controller: widget.controller,
              onAdded: widget.onDone,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_Tab>(
          segments: [
            ButtonSegment(
              value: _Tab.myPlayers,
              label: CricketText(text: TranslationKeys.myPlayers.tr),
            ),
            ButtonSegment(
              value: _Tab.appUsers,
              label: CricketText(text: TranslationKeys.appUsers.tr),
            ),
          ],
          selected: {_tab},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              setState(() => _tab = selection.first),
        ),
        16.h,
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
          ),
          child: SingleChildScrollView(
            child: _tab == _Tab.myPlayers
                ? _myPlayersBody(context)
                : _appUsersBody(context),
          ),
        ),
        12.h,
        OutlinedButton.icon(
          onPressed: () => setState(() => _step = _Step.createForm),
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: CricketText(text: TranslationKeys.createNewPlayer.tr),
        ),
      ],
    );
  }

  Widget _errorLine(BuildContext context, String message) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: CricketText(
      text: message,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.error,
      ),
    ),
  );

  Widget _myPlayersBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CricketTextField(
          controller: _search,
          hintText: TranslationKeys.searchPlayersHint.tr,
          prefixIcon: const Icon(Icons.search),
          hideCounter: true,
          textCapitalization: TextCapitalization.words,
          onChanged: _onSearchChanged,
        ),
        8.h,
        for (final player in _players) _playerRow(context, player),
        if (_loadingPlayers)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_players.isEmpty && _playersError == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CricketText(
              text: TranslationKeys.noPlayersYet.tr,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_hasMore && !_loadingPlayers)
          TextButton(
            onPressed: () => unawaited(_loadPlayers(reset: false)),
            child: CricketText(text: TranslationKeys.loadMorePlayers.tr),
          ),
        if (_playersError != null) _errorLine(context, _playersError!),
        if (_addError != null) _errorLine(context, _addError!),
      ],
    );
  }

  String _roleLabel(String role) => switch (role) {
    'batsman' => TranslationKeys.roleBatsman.tr,
    'bowler' => TranslationKeys.roleBowler.tr,
    'allrounder' => TranslationKeys.roleAllrounder.tr,
    'wicketkeeper' => TranslationKeys.roleWicketkeeper.tr,
    _ => TranslationKeys.roleUnknown.tr,
  };

  Widget _playerRow(BuildContext context, MyPlayerRow player) {
    final Widget trailing;
    if (player.onTeam) {
      trailing = CricketText(
        text: TranslationKeys.onRoster.tr,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    } else if (_addingId == player.playerId) {
      trailing = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      trailing = IconButton(
        key: ValueKey('add-player-${player.playerId}'),
        onPressed: _addingId == null ? () => _addExisting(player) : null,
        icon: const Icon(Icons.add_circle_outline),
        tooltip: TranslationKeys.addPlayer.tr,
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: CricketText(text: player.playerName),
      subtitle: CricketText(
        text: [
          _roleLabel(player.role),
          if (player.jerseyNumber != null) '#${player.jerseyNumber}',
        ].join(' · '),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _appUsersBody(BuildContext context) {
    final user = _found;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CricketText(
          text: TranslationKeys.findUserByEmailHint.tr,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        CricketTextField(
          controller: _email,
          hintText: TranslationKeys.email.tr,
          labelText: TranslationKeys.email.tr,
          prefixIcon: const Icon(Icons.mail_outline),
          keyboardType: TextInputType.emailAddress,
          hideCounter: true,
          onChanged: (_) => setState(() {
            _lookupGeneration++;
            _lookingUp = false;
            _found = null;
            _lookupError = null;
            _inviteError = null;
          }),
        ),
        12.h,
        CricketButton(
          buttonText: TranslationKeys.findUser.tr,
          isDisabled:
              _lookingUp || !_looksLikeEmail.hasMatch(_email.text.trim()),
          onPressed: _find,
        ),
        if (_lookupError != null) _errorLine(context, _lookupError!),
        if (user != null) ...[
          12.h,
          _userCard(context, user),
          if (_inviteError != null) _errorLine(context, _inviteError!),
        ],
      ],
    );
  }

  Widget _userCard(BuildContext context, LookedUpUserRes user) {
    final photo = user.photoUrl;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          foregroundImage: photo != null ? NetworkImage(photo) : null,
          child: CricketText(
            text: user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
          ),
        ),
        title: CricketText(text: user.fullName),
        subtitle: user.userName == null
            ? null
            : CricketText(text: '@${user.userName}'),
        trailing: _inviting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                key: const ValueKey('invite-user'),
                onPressed: () => _invite(user),
                child: CricketText(text: TranslationKeys.invite.tr),
              ),
      ),
    );
  }
}
