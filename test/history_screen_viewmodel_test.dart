import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sleed_task_manager_app/data/db_helper.dart';
import 'package:sleed_task_manager_app/models/task_model.dart';
import 'package:sleed_task_manager_app/viewmodel/history_screen_viewmodel.dart';
import 'package:sleed_task_manager_app/viewmodel/home_screen_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockHomeScreenViewModel extends Mock implements HomeScreenViewModel {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HistoryScreenViewModel viewModel;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockHomeScreenViewModel mockHomeScreenViewModel;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockHomeScreenViewModel = MockHomeScreenViewModel();

    when(mockDatabaseHelper.getTaskList()).thenAnswer((_) async => [
          Task(
            id: 1,
            title: 'Test Task 1',
            status: 1,
            date: DateTime.now(),
            priority: 'High',
            category: 'Work',
          ),
          Task(
            id: 2,
            title: 'Test Task 2',
            status: 1,
            date: DateTime.now(),
            priority: 'Medium',
            category: 'Personal',
          ),
        ]);

    viewModel = HistoryScreenViewModel();
    viewModel.updateTaskList();
  });

  group('HistoryScreenViewModel Tests', () {
    test('updateTaskList should fetch task list and notify listeners', () async {
      viewModel.updateTaskList();

      final tasks = await viewModel.taskList;
      expect(tasks.length, 2);
      expect(tasks[0].title, 'Test Task 1');
      expect(tasks[1].title, 'Test Task 2');
      verify(mockDatabaseHelper.getTaskList()).called(2);
    });

    test('updateTaskStatus should update task status and sync with Firebase', () async {
      final task = Task(id: 1, title: 'Test Task', status: 1, date: DateTime.now(), priority: 'High', category: 'Work');
      final userId = 'testUserId';
      final context = MockBuildContext();

      when(mockDatabaseHelper.updateTask(task)).thenAnswer((_) async => 1);
      when(mockHomeScreenViewModel.updateTaskList()).thenAnswer((_) async => {});

      final mockProvider = Provider.of<HomeScreenViewModel>;
      when(mockProvider(context, listen: false)).thenReturn(mockHomeScreenViewModel);

      await viewModel.updateTaskStatus(task, userId, context);

      expect(task.status, 0);
      verify(mockDatabaseHelper.updateTask(task)).called(1);
      verify(mockHomeScreenViewModel.updateTaskList()).called(1);
    });
  });
}
