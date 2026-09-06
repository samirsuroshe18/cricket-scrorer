import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';

abstract class SearchRepository {
  /// `GET /v1/search` — any authenticated user. Searches every organization
  /// and tournament by name regardless of the caller's membership.
  Future<Either<CricketResponse<SearchRes>, CricketFailure>> search({
    required String query,
  });
}
