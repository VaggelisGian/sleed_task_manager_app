import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/db_helper.dart';
import '../main.dart';
import '../models/task_model.dart';
import '../screens/home_screen.dart';

class Utils {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void showCustomSnackBar(String message) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(message, style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.grey[800],
      margin: const EdgeInsets.all(16),
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void navigateTo(BuildContext context, Widget page, bool isGoingRight) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, animation2, child) {
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: isGoingRight ? const Offset(-1, 0) : const Offset(1, 0),
              end: const Offset(0, 0),
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  void showAlertDialog(BuildContext context, String userId) async {
    Widget cancelButton = TextButton(
      child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 15.0)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("OK", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 15.0)),
      onPressed: () {
        DatabaseHelper.instance.deleteAllTask();
        DatabaseHelper.instance.deleteAllTasks(userId);
        showCustomSnackBar("All data cleared");
        navigateTo(context, HomeScreen(userId: userId), true);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      content: Text("Would you like to clear all data? It cannot be undone.",
          style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.onPrimary)),
      actions: [cancelButton, continueButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  // When a task is added or updated, a notification will be scheduled
  Future<void> scheduleNotification(Task task) async {
    if (flutterLocalNotificationsPlugin == null) {
      print('Error: flutterLocalNotificationsPlugin is not initialized');
      return;
    }

    // Ensure the id fits within the size of a 32-bit integer
    int notificationId = task.id! % pow(2, 31).toInt();

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    print('task.date = ${task.date} - ${tz.TZDateTime.from(task.date, tz.local)} - ${tz.local} ');
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder',
        'You have a task: ${task.title}',
        tz.TZDateTime.from(task.date, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Notification scheduled successfully for task: ${task.title}');
    } catch (e) {
      print('Error scheduling notification for task: ${task.title}, Error: $e');
    }
  }
}
