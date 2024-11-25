import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/utils.dart';
import '../data/db_helper.dart';
import '../models/task_model.dart';
import 'home_screen_viewmodel.dart';

class AddTaskScreenViewModel extends ChangeNotifier {
  late String _title;
  String? _priority;
  String? _category;
  late DateTime _date;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final TextEditingController dateController = TextEditingController();
  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> priorities = ['Low', 'Medium', 'High'];
  final List<String> categories = ['Work', 'Personal', 'Others'];

  AddTaskScreenViewModel(Task? task) {
    initializeTask(task);
  }

  void initializeTask(Task? task) {
    if (task != null) {
      _title = task.title;
      _date = task.date;
      _priority = task.priority;
      _category = task.category;
    } else {
      _title = '';
      _date = DateTime.now();
    }
    dateController.text = dateFormatter.format(_date);
  }

  String get title => _title;
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  String? get priority => _priority;
  set priority(String? value) {
    _priority = value;
    notifyListeners();
  }

  String? get category => _category;
  set category(String? value) {
    _category = value;
    notifyListeners();
  }

  Future<void> handleDatePicker(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _date.isBefore(now) ? now : _date;

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(9999, 12, 31),
      builder: (BuildContext context, Widget? child) {
        final ThemeData theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.hintColor,
              onPrimary: theme.colorScheme.onPrimary,
              onSurface: theme.textTheme.bodySmall?.color,
            ),
            dialogBackgroundColor: theme.dialogBackgroundColor,
            datePickerTheme: theme.datePickerTheme.copyWith(
              yearForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Theme.of(context).colorScheme.onSecondary;
                }
                return Theme.of(context).textTheme.bodyLarge!.color!;
              }),
              dayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Theme.of(context).colorScheme.onSecondary;
                }
                return Theme.of(context).textTheme.bodyLarge!.color!;
              }),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && date != _date) {
      _date = date;
      dateController.text = dateFormatter.format(date);
      print('Date: $_date - ${dateController.text}');
      notifyListeners();
    }
  }

  Future<void> deleteTask(BuildContext context, Task? task, String userId, Function updateTaskList) async {
    Utils().showLoadingDialog(context, "Deleting...");

    try {
      if (task != null) {
        await DatabaseHelper.instance.deleteTask(task.id!);

        Navigator.pop(context);
        Navigator.pop(context);
        updateTaskList();

        Utils().showCustomSnackBar("Task Deleted");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(task.id.toString())
            .delete()
            .timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            throw TimeoutException("The connection has timed out, please try again!");
          },
        );

        Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList();
      }
    } catch (e) {
      if (e is TimeoutException) {
        Utils().showCustomSnackBar(
            "The connection has timed out, the data will be synced when the connection is restored.");
      } else {
        Utils().showCustomSnackBar("Error deleting task: $e");
      }
      print('Error: $e');
    }
  }

  Future<void> submitTask(
      BuildContext context, GlobalKey<FormState> formKey, Task? task, String userId, Function updateTaskList) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final Task newTask = Task(
        title: _title,
        date: _date,
        priority: _priority!,
        category: _category!,
        status: task?.status ?? 0,
      );
      Utils().showLoadingDialog(context, "Submitting...");
      try {
        if (task == null) {
          final int taskId = await DatabaseHelper.instance.insertTask(newTask);
          newTask.id = taskId;
          await _updateFirebase(context, newTask, userId);
          Utils().showCustomSnackBar("New Task Added");
        } else {
          newTask.id = task.id;
          await DatabaseHelper.instance.updateTask(newTask);
          await _updateFirebase(context, newTask, userId);
          Utils().showCustomSnackBar("Task Updated");
        }
        Navigator.pop(context);
        updateTaskList();

        Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList();

        await Utils().scheduleNotification(newTask);
      } catch (e) {
        Utils().showCustomSnackBar("Error saving task");
        print('Error: $e');
      }

      Navigator.pop(context);
    }
  }

  Future<void> _updateFirebase(BuildContext context, Task task, String userId) async {
    Utils().showLoadingDialog(context, "Updating...");
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id.toString())
          .set(task.toMap())
          .timeout(const Duration(seconds: 3), onTimeout: () {
        throw TimeoutException(
            "The connection has timed out, the data will be synced when the connection is restored.");
      });
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        if (e is TimeoutException) {
          Utils().showCustomSnackBar(
              "The connection has timed out, the data will be synced when the connection is restored.");
          Navigator.pop(context);
        } else {
          Utils().showCustomSnackBar("Error updating Firebase: $e");
        }
      }
      print('Error: $e');
      _scheduleRetry(context, task, userId);
    }
  }

  void _scheduleRetry(BuildContext context, Task task, String userId) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('tasks')
                .doc(task.id.toString())
                .set(task.toMap());
            Utils().showCustomSnackBar("Task synced to Firebase");
            _connectivitySubscription?.cancel();
          } catch (e) {
            Utils().showCustomSnackBar("Error syncing task: $e");
          }
        }
      },
    );
  }

  void clearControllers() {
    dateController.clear();
  }
}
