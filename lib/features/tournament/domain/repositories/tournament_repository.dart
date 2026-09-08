import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/register_pool_player_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_pool_entry_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_auction_setup_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_setup_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_event_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/standings_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';

abstract class TournamentRepository {
  /// `POST /v1/organization/:orgId/tournaments` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  });

  /// `GET /v1/tournament/:tournamentId` — any org member.
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>>
  getTournament({required String tournamentId});

  /// `PATCH /v1/tournament/:tournamentId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  });

  /// `DELETE /v1/tournament/:tournamentId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTournament({
    required String tournamentId,
  });

  /// `POST /v1/tournament/:tournamentId/teams` — owner-only, team must
  /// already belong to the tournament's own organization.
  Future<Either<CricketResponse<void>, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  });

  /// `DELETE /v1/tournament/:tournamentId/teams/:teamId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  });

  /// `POST /v1/tournament/:tournamentId/fixtures` — owner-only. Generates
  /// the full schedule (round_robin/league) or the next round (knockout).
  Future<Either<CricketResponse<void>, CricketFailure>> generateFixtures({
    required String tournamentId,
  });

  /// `GET /v1/tournament/:tournamentId/fixtures` — any org member.
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>>
  getFixtures({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/fixtures/:fixtureId/start-match` —
  /// any org member. Returns the same shape `POST /v1/match` does.
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>>
  startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  });

  /// `PATCH /v1/tournament/:tournamentId/fixtures/:fixtureId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  });

  /// `GET /v1/tournament/:tournamentId/standings` — any org member.
  /// round_robin/league only; a knockout tournament fails with
  /// `STANDINGS_NOT_APPLICABLE`.
  Future<Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>>
  getStandings({required String tournamentId});

  /// `GET /v1/tournament/:tournamentId/leaderboards` — any org member, every
  /// tournament format.
  Future<Either<CricketResponse<TournamentLeaderboardsRes>, CricketFailure>>
  getLeaderboards({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/pool` — owner-only. Base price is
  /// always organizer-set; nothing here reads career stats.
  Future<Either<CricketResponse<PoolEntryRes>, CricketFailure>>
  registerPoolPlayer({
    required String tournamentId,
    required RegisterPoolPlayerReq params,
  });

  /// `GET /v1/tournament/:tournamentId/pool` — any org member.
  Future<Either<CricketResponse<List<PoolEntryRes>>, CricketFailure>>
  getPool({required String tournamentId});

  /// `PATCH /v1/tournament/:tournamentId/pool/:playerId` — owner-only,
  /// basePrice only.
  Future<Either<CricketResponse<PoolEntryRes>, CricketFailure>>
  updatePoolEntry({
    required String tournamentId,
    required String playerId,
    required UpdatePoolEntryReq params,
  });

  /// `DELETE /v1/tournament/:tournamentId/pool/:playerId` — owner-only,
  /// hard removal. No cutoff in this pass.
  Future<Either<CricketResponse<void>, CricketFailure>> removePoolEntry({
    required String tournamentId,
    required String playerId,
  });

  /// `PATCH /v1/tournament/:tournamentId/auction-setup` — owner-only. Each
  /// field applied only if present; `owners` fully replaces the current set
  /// when present. No code path from career stats to any field here.
  Future<Either<CricketResponse<AuctionSetupRes>, CricketFailure>>
  setAuctionSetup({
    required String tournamentId,
    required UpdateAuctionSetupReq params,
  });

  /// `GET /v1/tournament/:tournamentId/auction-setup` — any org member.
  Future<Either<CricketResponse<AuctionSetupRes>, CricketFailure>>
  getAuctionSetup({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/auction/start` — owner-only.
  Future<Either<CricketResponse<AuctionStartRes>, CricketFailure>>
  startAuction({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/auction/pause` — owner-only.
  Future<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>>
  pauseAuction({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/auction/resume` — owner-only.
  Future<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>>
  resumeAuction({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/auction/next` — owner-only.
  Future<Either<CricketResponse<AuctionNextLotRes>, CricketFailure>>
  nextAuctionLot({required String tournamentId});

  /// The auction room's live half — see [AuctionSocketService]. Every
  /// stream here (except [watchAuctionState], which owns room join/leave)
  /// assumes the room is already joined.
  Stream<Either<AuctionStateRes, CricketFailure>> watchAuctionState({required String tournamentId});
  Stream<AuctionLotRes> watchAuctionLotOnBlock({required String tournamentId});
  Stream<AuctionBidAcceptedRes> watchAuctionBidAccepted({required String tournamentId});
  Stream<AuctionBidRejectedRes> watchAuctionBidRejected({required String tournamentId});
  Stream<AuctionLotResolvedRes> watchAuctionLotResolved({required String tournamentId});
  Stream<void> watchAuctionPaused({required String tournamentId});
  Stream<DateTime?> watchAuctionResumed({required String tournamentId});
  Stream<void> watchAuctionSessionCompleted({required String tournamentId});

  /// Fire-and-forget — see [AuctionSocketService.bid].
  Future<void> bidOnAuctionLot({required String tournamentId, required String lotId});
}
