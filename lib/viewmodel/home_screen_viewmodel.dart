import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/task_model.dart';

class HomeScreenViewModel extends ChangeNotifier {
  late Future<List<Task>> _taskList;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';

  HomeScreenViewModel() {
    updateTaskList();
  }

  Future<List<Task>> get taskList => _taskList;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedPriority => _selectedPriority;

  void updateTaskList() {
    _taskList = DatabaseHelper.instance.getTaskList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedPriority = 'All';
    updateTaskList();
  }

  void searchTasks(String query) {
    _searchQuery = query;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void filterTasks(String category, String priority) {
    _selectedCategory = category;
    _selectedPriority = priority;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> updateTaskStatus(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    updateTaskList();
  }

  void refreshTaskList() {
    updateTaskList();
  }
}
