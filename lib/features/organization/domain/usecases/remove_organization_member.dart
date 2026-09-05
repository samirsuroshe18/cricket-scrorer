import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class RemoveOrganizationMemberParams {
  final String orgId;
  final String userId;

  RemoveOrganizationMemberParams({required this.orgId, required this.userId});
}

class RemoveOrganizationMemberUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            RemoveOrganizationMemberParams> {
  final OrganizationRepository organizationRepository;

  RemoveOrganizationMemberUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveOrganizationMemberParams? params,
  }) {
    return organizationRepository.removeMember(
      orgId: params!.orgId,
      userId: params.userId,
    );
  }
}
