/// Longest team name / short name the backend accepts (`Team` schema,
/// enforced server-side by `parseTeamFields`). Both the create and edit
/// forms check `String.length` (UTF-16 code units, matching the backend's
/// own count) against these before sending, rather than trusting a text
/// field's own character-counting formatter — a Devanagari or emoji value
/// can look under the limit and still be over it on the wire.
const maxTeamNameLength = 50;
const maxShortNameLength = 5;
