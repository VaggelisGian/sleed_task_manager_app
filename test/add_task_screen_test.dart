import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleed_task_manager_app/screens/add_task_screen.dart';
import 'package:sleed_task_manager_app/viewmodel/add_task_screen_model.dart';

void main() {
  testWidgets('AddTaskScreen should display correct title and fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AddTaskScreenViewModel(null),
        child: MaterialApp(
          home: AddTaskScreen(
            updateTaskList: () {},
            userId: 'testUserId',
          ),
        ),
      ),
    );

    expect(find.text('Add Task'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
