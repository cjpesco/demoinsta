import 'package:demoinsta/screens/notifications/bloc/notifications_bloc.dart';
import 'package:demoinsta/screens/notifications/widgets/widgets.dart';
import 'package:demoinsta/widgets/centered_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notifications';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          switch (state.status) {
            case NotificationsStatus.error:
              return CenteredText(text: state.failure.message);
            case NotificationsStatus.loaded:
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  final notification = state.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => context
                        .read<NotificationsBloc>()
                        .removeNotification(notification: notification),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 5.0),
                      child: Text(
                        'Swipe to delete',
                        style: TextStyle(color: Colors.white, fontSize: 17.0),
                      ),
                      color: Colors.red,
                    ),
                    child: NotificationTile(notification: notification),
                  );
                },
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
