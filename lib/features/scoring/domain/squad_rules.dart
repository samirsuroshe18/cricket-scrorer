import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';

/// Roles a squad row may carry — mirrors the server's `SQUAD_ROLES`.
const List<String> squadRoles = ['batsman', 'bowler', 'allrounder'];

const String defaultSquadRole = 'batsman';

class SquadRow {
  /// Set only for a returning player seeded from a team roster.
  final String? playerId;
  final String name;
  final String role;

  const SquadRow({this.playerId, required this.name, required this.role});

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

  const SquadDraft({
    required this.rows,
    this.captain,
    this.viceCaptain,
    this.keeper,
  });

  factory SquadDraft.empty() => const SquadDraft(rows: []);

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
  }) => SquadDraft(
    rows: rows ?? this.rows,
    captain: captain != null ? captain() : this.captain,
    viceCaptain: viceCaptain != null ? viceCaptain() : this.viceCaptain,
    keeper: keeper != null ? keeper() : this.keeper,
  );

  /// Ignores a blank name and a name already in the squad.
  SquadDraft addPlayer(
    String name, {
    String role = defaultSquadRole,
    String? playerId,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _has(trimmed)) return this;
    return _copy(
      rows: [
        ...rows,
        SquadRow(playerId: playerId, name: trimmed, role: role),
      ],
    );
  }

  /// Also clears any designation the removed player held.
  SquadDraft removePlayer(String name) {
    return _copy(
      rows: rows.where((row) => _key(row.name) != _key(name)).toList(),
      captain: () => _same(captain, name) ? null : captain,
      viceCaptain: () => _same(viceCaptain, name) ? null : viceCaptain,
      keeper: () => _same(keeper, name) ? null : keeper,
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
    );
  }
}
