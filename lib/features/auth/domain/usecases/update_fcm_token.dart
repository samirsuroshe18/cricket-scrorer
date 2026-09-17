import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

/// Registers this device's FCM token against the signed-in user
/// (`POST /v1/user/update-fcm`) — the missing link that made every
/// server-triggered push a no-op: `FirebaseService.generateToken()` already
/// retrieved a token, but nothing ever sent it here until this usecase was
/// wired into `HomeController.onInit`.
class UpdateFcmTokenUseCase
    implements
        UseCase<
          Either<CricketResponse<Map<String, dynamic>>, CricketFailure>,
          String
        > {
  final AuthRepository authRepository;

  UpdateFcmTokenUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> call({
    String? params,
  }) {
    return authRepository.updateFcmToken(fcmToken: params ?? '');
  }
}
