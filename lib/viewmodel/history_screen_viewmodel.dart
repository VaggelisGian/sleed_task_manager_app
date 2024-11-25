import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../data/db_helper.dart';
import '../models/task_model.dart';
import '../viewmodel/home_screen_viewmodel.dart';

class HistoryScreenViewModel extends ChangeNotifier {
  late Future<List<Task>> _taskList;
  Future<List<Task>> get taskList => _taskList;

  HistoryScreenViewModel() {
    updateTaskList();
  }

  void updateTaskList() {
    _taskList = DatabaseHelper.instance.getTaskList();
    notifyListeners();
  }

  Future<void> updateTaskStatus(Task task, String userId, BuildContext context) async {
    task.status = 0;
    await DatabaseHelper.instance.updateTask(task);
    await _updateTaskStatusInFirebase(task, userId);
    updateTaskList();
    notifyListeners();

    Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList();
  }

  Future<void> _updateTaskStatusInFirebase(Task task, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id.toString())
          .update({'status': task.status});
    } catch (e) {
      print("Error updating task status in Firebase: $e");
    }
  }
}
