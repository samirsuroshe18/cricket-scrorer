import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase
    implements
        UseCase<
          Either<CricketResponse<Map<String, dynamic>>, CricketFailure>,
          String
        > {
  final NotificationRepository notificationRepository;

  MarkNotificationReadUseCase({required this.notificationRepository});

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> call({
    String? params,
  }) {
    return notificationRepository.markRead(notificationId: params ?? '');
  }
}
