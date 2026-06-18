import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/update_profile_req.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase
    implements
        UseCase<
          Either<CricketResponse<void>, CricketFailure>,
          UpdateProfileReq
        > {
  final AuthRepository authRepository;

  UpdateProfileUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    UpdateProfileReq? params,
    File? file,
  }) {
    return authRepository.updateProfile(params: params, file: file);
  }
}
