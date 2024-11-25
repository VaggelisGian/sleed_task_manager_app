import 'package:flutter_test/flutter_test.dart';
import 'package:sleed_task_manager_app/viewmodel/add_task_screen_model.dart';
import 'package:sleed_task_manager_app/models/task_model.dart';

void main() {
  group('AddTaskScreenViewModel', () {
    test('initializeTask should set task properties correctly', () {
      final task = Task(
        id: 1,
        title: 'Test Task',
        date: DateTime(2023, 10, 10),
        priority: 'High',
        category: 'Work',
        status: 0,
      );
      final viewModel = AddTaskScreenViewModel(task);

      expect(viewModel.title, 'Test Task');
      expect(viewModel.priority, 'High');
      expect(viewModel.category, 'Work');
      expect(viewModel.dateController.text, 'Oct 10, 2023');
    });

    test('title setter should update title and notify listeners', () {
      final viewModel = AddTaskScreenViewModel(null);
      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      viewModel.title = 'New Task';

      expect(viewModel.title, 'New Task');
      expect(notified, true);
    });
  });
}
