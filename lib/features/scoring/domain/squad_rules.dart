import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';

/// Roles a squad row may carry — mirrors the server's `SQUAD_ROLES`.
const List<String> squadRoles = ['batsman', 'bowler', 'allrounder'];

const String defaultSquadRole = 'batsman';

/// How many players start in the Playing XI when a squad is seeded, and the
/// point past which a newly typed player lands on the Bench instead. A starting
/// heuristic only — the scorer can move anyone, and the XI has no cap.
const int defaultXiSize = 11;

class SquadRow {
  /// Set only for a returning player seeded from a team roster.
  final String? playerId;
  final String name;

  /// Null until the scorer picks one, for a seeded player whose stored role
  /// is outside [squadRoles]; the request then leaves it alone.
  final String? role;

  const SquadRow({this.playerId, required this.name, this.role});

  SquadRow withRole(String value) =>
      SquadRow(playerId: playerId, name: name, role: value);
}

String _key(String name) => name.trim().toLowerCase();

/// One side's squad being edited. Immutable: every rule returns a new draft,
/// so the controller can hold it in a single `Rx` and the rules stay testable
/// without GetX. Names are compared trimmed and case-insensitively, the same
/// way the server does.
class SquadDraft {
  final List<SquadRow> rows;
  final String? captain;
  final String? viceCaptain;
  final String? keeper;

  /// Keys (trimmed, lower-cased names) of the [rows] in the Playing XI. Every
  /// other row is on the Bench. Always a subset of the row keys.
  final Set<String> xi;

  const SquadDraft({
    required this.rows,
    this.captain,
    this.viceCaptain,
    this.keeper,
    this.xi = const {},
  });

  factory SquadDraft.empty() => const SquadDraft(rows: []);

  /// A draft over [rows]. With no [xi] the first [defaultXiSize] rows are the
  /// XI; an explicit [xi] (names, any case) is used as given — including an
  /// empty one — and anything in it that is not a row is dropped.
  factory SquadDraft.seeded(List<SquadRow> rows, {Set<String>? xi}) {
    final rowKeys = {for (final row in rows) _key(row.name)};
    final keys = xi == null
        ? {for (final row in rows.take(defaultXiSize)) _key(row.name)}
        : {for (final name in xi) _key(name)}.intersection(rowKeys);
    return SquadDraft(rows: rows, xi: keys);
  }

  bool isInXi(SquadRow row) => xi.contains(_key(row.name));

  List<SquadRow> get xiRows => rows.where(isInXi).toList();

  List<SquadRow> get benchRows => rows.where((row) => !isInXi(row)).toList();

  bool _has(String name) => rows.any((row) => _key(row.name) == _key(name));

  SquadRow? _row(String name) {
    for (final row in rows) {
      if (_key(row.name) == _key(name)) return row;
    }
    return null;
  }

  bool _same(String? held, String name) =>
      held != null && _key(held) == _key(name);

  SquadDraft _copy({
    List<SquadRow>? rows,
    String? Function()? captain,
    String? Function()? viceCaptain,
    String? Function()? keeper,
    Set<String>? xi,
  }) => SquadDraft(
    rows: rows ?? this.rows,
    captain: captain != null ? captain() : this.captain,
    viceCaptain: viceCaptain != null ? viceCaptain() : this.viceCaptain,
    keeper: keeper != null ? keeper() : this.keeper,
    xi: xi ?? this.xi,
  );

  /// Ignores a blank name and a name already in the squad. The new player joins
  /// the Playing XI while it has fewer than [defaultXiSize], else the Bench.
  SquadDraft addPlayer(
    String name, {
    String? role = defaultSquadRole,
    String? playerId,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _has(trimmed)) return this;
    return _copy(
      rows: [
        ...rows,
        SquadRow(playerId: playerId, name: trimmed, role: role),
      ],
      xi: xi.length < defaultXiSize ? {...xi, _key(trimmed)} : xi,
    );
  }

  /// Like [addPlayer] but always onto the Bench — used for a player who joined
  /// the team (an accepted invitee), so the XI never changes without the
  /// scorer's own action.
  SquadDraft addToBench(String name, {String? role, String? playerId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _has(trimmed)) return this;
    return _copy(
      rows: [
        ...rows,
        SquadRow(playerId: playerId, name: trimmed, role: role),
      ],
    );
  }

  /// No-op for a name that is not in the squad. The XI has no size cap.
  SquadDraft moveToXi(String name) {
    if (!_has(name)) return this;
    return _copy(xi: {...xi, _key(name)});
  }

  /// Also clears any designation the player held: the leader-picker sheet
  /// only offers the Playing XI as candidates, so a demoted captain/
  /// vice-captain/keeper would otherwise be stuck referenced by a chip with
  /// no way to reassign or confirm them from that list.
  SquadDraft moveToBench(String name) {
    if (!_has(name)) return this;
    return _copy(
      captain: () => _same(captain, name) ? null : captain,
      viceCaptain: () => _same(viceCaptain, name) ? null : viceCaptain,
      keeper: () => _same(keeper, name) ? null : keeper,
      xi: {...xi}..remove(_key(name)),
    );
  }

  /// Also clears any designation the removed player held, and their XI place.
  SquadDraft removePlayer(String name) {
    return _copy(
      rows: rows.where((row) => _key(row.name) != _key(name)).toList(),
      captain: () => _same(captain, name) ? null : captain,
      viceCaptain: () => _same(viceCaptain, name) ? null : viceCaptain,
      keeper: () => _same(keeper, name) ? null : keeper,
      xi: {...xi}..remove(_key(name)),
    );
  }

  SquadDraft setRole(String name, String role) {
    return _copy(
      rows: [
        for (final row in rows)
          _key(row.name) == _key(name) ? row.withRole(role) : row,
      ],
    );
  }

  /// Single-select: moves the captaincy to [name], or clears it when [name]
  /// already holds it. Taking the captaincy from the vice-captain's own row
  /// clears the vice-captain — one person cannot hold both.
  SquadDraft setCaptain(String name) {
    final row = _row(name);
    if (row == null) return this;
    if (_same(captain, name)) return _copy(captain: () => null);
    return _copy(
      captain: () => row.name,
      viceCaptain: () => _same(viceCaptain, name) ? null : viceCaptain,
    );
  }

  /// Mirror of [setCaptain].
  SquadDraft setViceCaptain(String name) {
    final row = _row(name);
    if (row == null) return this;
    if (_same(viceCaptain, name)) return _copy(viceCaptain: () => null);
    return _copy(
      viceCaptain: () => row.name,
      captain: () => _same(captain, name) ? null : captain,
    );
  }

  /// Independent of captain/vice-captain: the keeper may hold either as well.
  SquadDraft setKeeper(String name) {
    final row = _row(name);
    if (row == null) return this;
    if (_same(keeper, name)) return _copy(keeper: () => null);
    return _copy(keeper: () => row.name);
  }

  SaveSquadReq toRequest(String side) {
    return SaveSquadReq(
      side: side,
      players: [
        for (final row in rows)
          SquadPlayerReq(
            playerId: row.playerId,
            name: row.name,
            role: row.role,
          ),
      ],
      captain: captain,
      viceCaptain: viceCaptain,
      keeper: keeper,
      // Always an explicit array: saving is the scorer choosing an XI, even an
      // empty one. (Skip is the only way to leave it unset, and sends nothing.)
      playingXI: [for (final row in xiRows) row.name],
    );
  }
}
