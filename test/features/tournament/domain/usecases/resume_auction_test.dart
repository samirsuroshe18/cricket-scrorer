import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resume_auction.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTournamentRepository implements TournamentRepository {
  String? lastTournamentId;

  @override
  Future<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>> resumeAuction({
    required String tournamentId,
  }) async {
    lastTournamentId = tournamentId;
    return Either.result(
      CricketResponse(
        message: 'Auction resumed',
        data: AuctionPauseResumeRes(tournamentId: tournamentId, status: 'active'),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('ResumeAuctionUseCase delegates to the repository with the given tournamentId', () async {
    final repository = _FakeTournamentRepository();
    final useCase = ResumeAuctionUseCase(tournamentRepository: repository);

    final response = await useCase(params: ResumeAuctionParams(tournamentId: 'tournament-1'));

    expect(repository.lastTournamentId, 'tournament-1');
    expect(response.isResult, isTrue);
    expect(response.result.data!.status, 'active');
  });
}
