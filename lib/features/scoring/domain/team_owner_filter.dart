/// `mine` — `Team.createdBy` is the caller. `others` — visible only through
/// organization membership, created by a different member (a teammate's
/// team, e.g. one the caller might now face as an opponent). Maps to the
/// backend's `GET /v1/team?owner=`.
enum TeamOwnerFilter {
  mine,
  others;

  String get queryValue => switch (this) {
    TeamOwnerFilter.mine => 'mine',
    TeamOwnerFilter.others => 'others',
  };
}
