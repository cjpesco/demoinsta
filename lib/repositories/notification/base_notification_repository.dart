import 'package:demoinsta/models/models.dart';

abstract class BaseNotificationRepository {
  Stream<List<Future<Notif>>> getUserNotifications({String userId});
  void deleteNotification({String notificationId, String userId});
}
