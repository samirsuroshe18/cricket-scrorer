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
  group('a role the scorer never chose', () {
    test('stays null through the draft and is left off the request', () {
      final draft = SquadDraft.empty().addPlayer('Pant', role: null);

      expect(draft.rows.single.role, isNull);
      final req = draft.toRequest('teamA');
      expect(req.players.single.role, isNull);
      expect(req.players.single.toJson().containsKey('role'), isFalse);
    });

    test('choosing a role sets it', () {
      final draft = SquadDraft.empty()
          .addPlayer('Pant', role: null)
          .setRole('Pant', 'allrounder');

      expect(draft.rows.single.role, 'allrounder');
    });
  });

  group('Playing XI and Bench', () {
    List<SquadRow> rows(int n) => [
      for (var i = 1; i <= n; i++) SquadRow(name: 'Player $i', role: 'batsman'),
    ];

    List<String> names(List<SquadRow> rs) => rs.map((r) => r.name).toList();

    test(
      'seeding 14 rows puts the first 11 in the XI and the rest on the Bench',
      () {
        final draft = SquadDraft.seeded(rows(14));

        expect(draft.xiRows, hasLength(11));
        expect(names(draft.xiRows).first, 'Player 1');
        expect(names(draft.xiRows).last, 'Player 11');
        expect(names(draft.benchRows), ['Player 12', 'Player 13', 'Player 14']);
      },
    );

    test('an explicit XI is respected, including an empty one', () {
      final some = SquadDraft.seeded(rows(4), xi: {'player 2', ' PLAYER 4 '});
      final none = SquadDraft.seeded(rows(4), xi: <String>{});

      expect(names(some.xiRows), ['Player 2', 'Player 4']);
      expect(names(some.benchRows), ['Player 1', 'Player 3']);
      expect(none.xiRows, isEmpty);
      expect(none.benchRows, hasLength(4));
    });

    test('an XI name that is not in the rows is ignored', () {
      final draft = SquadDraft.seeded(rows(2), xi: {'player 1', 'ghost'});

      expect(names(draft.xiRows), ['Player 1']);
    });

    test('moves are case-insensitive and unknown names are no-ops', () {
      final draft = SquadDraft.seeded(rows(3), xi: {'player 1'});

      final moved = draft.moveToXi(' player 3 ').moveToBench('PLAYER 1');
      final same = draft.moveToXi('nobody').moveToBench('nobody');

      expect(names(moved.xiRows), ['Player 3']);
      expect(names(moved.benchRows), ['Player 1', 'Player 2']);
      expect(names(same.xiRows), ['Player 1']);
    });

    test('there is no cap: a 12th player can be moved into the XI', () {
      final draft = SquadDraft.seeded(rows(12)).moveToXi('Player 12');

      expect(draft.xiRows, hasLength(12));
    });

    test(
      'a typed player joins the XI while it has fewer than 11, else the Bench',
      () {
        final small = SquadDraft.seeded(rows(10)).addPlayer('Newcomer');
        final full = SquadDraft.seeded(rows(11)).addPlayer('Newcomer');

        expect(names(small.xiRows), contains('Newcomer'));
        expect(names(full.benchRows), ['Newcomer']);
      },
    );

    test('addToBench never enters the XI, even with room', () {
      final draft = SquadDraft.seeded(rows(2)).addToBench(
        'Invitee',
        role: null,
        playerId: 'p9',
      );

      expect(names(draft.benchRows), ['Invitee']);
      expect(draft.benchRows.single.playerId, 'p9');
      expect(draft.benchRows.single.role, isNull);
    });

    test('addToBench ignores a blank or duplicate name', () {
      final draft = SquadDraft.seeded(
        rows(2),
      ).addToBench('  ').addToBench('player 1');

      expect(draft.rows, hasLength(2));
    });

    test('removing a player clears their XI membership', () {
      final draft = SquadDraft.seeded(rows(3)).removePlayer('Player 1');

      expect(names(draft.xiRows), ['Player 2', 'Player 3']);
      expect(draft.xi.contains('player 1'), isFalse);
    });

    test('moving a player does not touch captain, vice-captain or keeper', () {
      final draft = SquadDraft.seeded(rows(3))
          .setCaptain('Player 1')
          .setViceCaptain('Player 2')
          .setKeeper('Player 3')
          .moveToBench('Player 1')
          .moveToBench('Player 3');

      expect(draft.captain, 'Player 1');
      expect(draft.viceCaptain, 'Player 2');
      expect(draft.keeper, 'Player 3');
    });

    test('a role or designation change keeps the XI', () {
      final draft = SquadDraft.seeded(
        rows(3),
        xi: {'player 2'},
      ).setRole('Player 2', 'bowler').setCaptain('Player 1');

      expect(names(draft.xiRows), ['Player 2']);
    });

    test('toRequest always carries the XI names, in row order', () {
      final req = SquadDraft.seeded(
        rows(3),
        xi: {'player 3', 'player 1'},
      ).toRequest('teamA');
      final empty = SquadDraft.seeded(
        rows(2),
        xi: <String>{},
      ).toRequest('teamA');

      expect(req.playingXI, ['Player 1', 'Player 3']);
      expect(empty.playingXI, isNotNull);
      expect(empty.playingXI, isEmpty);
    });

    test('an existing draft built with addPlayer stays consistent', () {
      final req = _draft().toRequest('teamA');

      expect(req.playingXI, ['Rohit', 'Bumrah', 'Pant']);
    });
  });
}
