/// A bowler already seen this match, as far as this device knows — the
/// picker's chip data.
///
/// [id] may be null: a name recorded from an offline queue entry has no
/// server-assigned id yet, since the id only exists once the server has
/// actually resolved (or created) the `Player` document — which happens on
/// sync, not on enqueue. A chip built from such an entry still works; it just
/// sends a bare name, the same as typing it fresh, and takes on a real id the
/// next time an ack names this bowler.
///
/// [id]'s presence is the whole mechanism that lets `selectBowler` tell "the
/// same bowler, returning" apart from "a new player who happens to share a
/// name" — see docs/api.md's "Identity: bowlerId vs a bare name".
class BowlerRef {
  final String? id;
  final String name;

  const BowlerRef({required this.id, required this.name});

  bool sameName(String other) => name.trim().toLowerCase() == other.trim().toLowerCase();
}
