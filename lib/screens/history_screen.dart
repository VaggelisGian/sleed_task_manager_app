import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleed_task_manager_app/components/utils.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import '../viewmodel/history_screen_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({required this.userId, super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryScreenViewModel>(context, listen: false).updateTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          if (task.status == 1)
            ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18.0,
                  decoration: task.status == 1 ? TextDecoration.none : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_dateFormatter.format(task.date)} • ${task.priority}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 15.0,
                      decoration: task.status == 1 ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'Category: ${task.category}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 15.0,
                      decoration: task.status == 1 ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.restore_from_trash,
                  color: Theme.of(context).hintColor,
                ),
                onPressed: () async {
                  await Provider.of<HistoryScreenViewModel>(context, listen: false)
                      .updateTaskStatus(task, widget.userId, context);
                  Utils().showCustomSnackBar("Task reassigned");
                },
              ),
              onTap: () => Utils().navigateTo(
                context,
                AddTaskScreen(
                  updateTaskList: () => Provider.of<HistoryScreenViewModel>(context, listen: false).updateTaskList(),
                  task: task,
                  userId: widget.userId,
                ),
                true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskCount(int completedTaskCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Text(
                'You have completed [ $completedTaskCount ] tasks',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              Provider.of<HistoryScreenViewModel>(context, listen: false).updateTaskList();
              Navigator.pop(context);
            }),
        title: Text(
          'History',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<HistoryScreenViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<List<Task>>(
            future: viewModel.taskList,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final int completedTaskCount = snapshot.data?.where((Task task) => task.status == 1).length ?? 0;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                itemCount: 1 + (snapshot.data?.length ?? 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _buildCompletedTaskCount(completedTaskCount);
                  }
                  return _buildTask(snapshot.data![index - 1]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
