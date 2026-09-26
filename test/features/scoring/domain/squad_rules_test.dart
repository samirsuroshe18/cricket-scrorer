import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:flutter_test/flutter_test.dart';

SquadDraft _draft() => SquadDraft.empty()
    .addPlayer('Rohit')
    .addPlayer('Bumrah', role: 'bowler')
    .addPlayer('Pant');

void main() {
  group('addPlayer / removePlayer', () {
    test('trims and appends, defaulting the role to batsman', () {
      final draft = SquadDraft.empty().addPlayer('  Rohit ');

      expect(draft.rows.single.name, 'Rohit');
      expect(draft.rows.single.role, 'batsman');
    });

    test('ignores a blank name and a case-insensitive duplicate', () {
      final draft = SquadDraft.empty()
          .addPlayer('Rohit')
          .addPlayer('   ')
          .addPlayer(' rohit ');

      expect(draft.rows, hasLength(1));
    });

    test('removing a designated player clears that designation', () {
      final draft = _draft()
          .setCaptain('Rohit')
          .setKeeper('Rohit')
          .removePlayer('rohit');

      expect(draft.rows.map((r) => r.name), ['Bumrah', 'Pant']);
      expect(draft.captain, isNull);
      expect(draft.keeper, isNull);
    });
  });

  group('designations', () {
    test('selecting a designation moves it to the new player', () {
      final draft = _draft().setCaptain('Rohit').setCaptain('Bumrah');

      expect(draft.captain, 'Bumrah');
    });

    test('selecting the current holder again clears it', () {
      final draft = _draft().setKeeper('Pant').setKeeper('pant');

      expect(draft.keeper, isNull);
    });

    test(
      'captain on the vice-captain clears the vice-captain, and vice versa',
      () {
        final captainWins = _draft()
            .setViceCaptain('Rohit')
            .setCaptain('Rohit');
        final vcWins = _draft().setCaptain('Rohit').setViceCaptain('Rohit');

        expect(captainWins.captain, 'Rohit');
        expect(captainWins.viceCaptain, isNull);
        expect(vcWins.viceCaptain, 'Rohit');
        expect(vcWins.captain, isNull);
      },
    );

    test('the keeper may also be captain or vice-captain', () {
      final draft = _draft().setCaptain('Pant').setKeeper('Pant');

      expect(draft.captain, 'Pant');
      expect(draft.keeper, 'Pant');
    });

    test('ignores a name that is not in the squad', () {
      final draft = _draft().setCaptain('Nobody');

      expect(draft.captain, isNull);
    });
  });

  group('setRole / toRequest', () {
    test('setRole changes only the named player', () {
      final draft = _draft().setRole('Pant', 'allrounder');

      expect(draft.rows.map((r) => r.role), [
        'batsman',
        'bowler',
        'allrounder',
      ]);
    });

    test('toRequest carries side, rows and designations', () {
      final req = _draft().setCaptain('Rohit').toRequest('teamB');

      expect(req.side, 'teamB');
      expect(req.players.map((p) => p.name), ['Rohit', 'Bumrah', 'Pant']);
      expect(req.captain, 'Rohit');
      expect(req.keeper, isNull);
    });

    test('keeps a returning player\'s id on the request', () {
      final draft = SquadDraft.empty().addPlayer('Rohit', playerId: 'p1');

      expect(draft.toRequest('teamA').players.single.playerId, 'p1');
    });
  });
}
