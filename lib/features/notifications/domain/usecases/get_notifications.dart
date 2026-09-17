import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/data/models/response/notification_res.dart';
import 'package:cricket_scorer/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsParams {
  final int page;
  final int limit;

  const GetNotificationsParams({required this.page, required this.limit});
}

class GetNotificationsUseCase
    implements
        UseCase<
          Either<CricketResponse<NotificationsRes>, CricketFailure>,
          GetNotificationsParams
        > {
  final NotificationRepository notificationRepository;

  GetNotificationsUseCase({required this.notificationRepository});

  @override
  Future<Either<CricketResponse<NotificationsRes>, CricketFailure>> call({
    GetNotificationsParams? params,
  }) {
    return notificationRepository.getNotifications(
      page: params?.page ?? 1,
      limit: params?.limit ?? 20,
    );
  }
}
