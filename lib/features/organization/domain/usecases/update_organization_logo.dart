import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class UpdateOrganizationLogoParams {
  final String orgId;
  final File file;

  UpdateOrganizationLogoParams({required this.orgId, required this.file});
}

class UpdateOrganizationLogoUseCase
    implements
        UseCase<Either<CricketResponse<String>, CricketFailure>,
            UpdateOrganizationLogoParams> {
  final OrganizationRepository organizationRepository;

  UpdateOrganizationLogoUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<String>, CricketFailure>> call({
    UpdateOrganizationLogoParams? params,
  }) {
    return organizationRepository.updateLogo(
      orgId: params!.orgId,
      file: params.file,
    );
  }
}
