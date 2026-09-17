import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase
    implements
        UseCase<
          Either<CricketResponse<Map<String, dynamic>>, CricketFailure>,
          void
        > {
  final NotificationRepository notificationRepository;

  MarkAllNotificationsReadUseCase({required this.notificationRepository});

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> call({
    void params,
  }) {
    return notificationRepository.markAllRead();
  }
}
