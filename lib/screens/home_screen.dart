import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../components/filter_sheet.dart';
import '../components/utils.dart';
import '../models/task_model.dart';
import '../viewmodel/home_screen_viewmodel.dart';
import 'history_screen.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({required this.userId, super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList();
  }

  void onBackPressed(bool value) {
    SystemNavigator.pop();
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          if (task.status == 0)
            ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '${_dateFormatter.format(task.date)} • ${task.priority} • ${task.category}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough,
                ),
              ),
              trailing: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Checkbox(
                    value: task.status == 1,
                    side: BorderSide(
                      color: Theme.of(context).hintColor,
                      width: 1.5,
                    ),
                    activeColor: Theme.of(context).hintColor,
                    onChanged: (bool? value) async {
                      setState(() {
                        task.status = value! ? 1 : 0;
                      });

                      Utils().showCustomSnackBar(
                        task.status == 1 ? "Task Completed" : "Task Incomplete",
                      );

                      Future.delayed(const Duration(milliseconds: 200), () async {
                        await Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskStatus(task);
                        Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList();
                      });
                    },
                  );
                },
              ),
              onTap: () => Utils().navigateTo(
                context,
                AddTaskScreen(
                  updateTaskList: Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList,
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

  void _showSearchModal() {
    _searchController.text = Provider.of<HomeScreenViewModel>(context, listen: false).searchQuery;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Tasks',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  Provider.of<HomeScreenViewModel>(context, listen: false).searchTasks(value);
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool areFiltersApplied = Provider.of<HomeScreenViewModel>(context).searchQuery.isNotEmpty ||
        Provider.of<HomeScreenViewModel>(context).selectedCategory != 'All' ||
        Provider.of<HomeScreenViewModel>(context).selectedPriority != 'All';

    return PopScope(
      onPopInvoked: onBackPressed,
      child: Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'clearFilters',
              backgroundColor: areFiltersApplied ? Theme.of(context).colorScheme.error : Colors.grey[300],
              foregroundColor: areFiltersApplied ? Theme.of(context).colorScheme.onPrimary : Colors.grey,
              child: const Icon(Icons.clear),
              onPressed:
                  areFiltersApplied ? Provider.of<HomeScreenViewModel>(context, listen: false).clearFilters : null,
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'addTask',
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.add_outlined),
              onPressed: () => Utils().navigateTo(
                context,
                AddTaskScreen(
                  updateTaskList: Provider.of<HomeScreenViewModel>(context, listen: false).updateTaskList,
                  userId: widget.userId,
                ),
                true,
              ),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'searchTask',
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.search),
              onPressed: _showSearchModal,
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'filterTask',
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.filter_list),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return FilterSheet(
                      onFilter: Provider.of<HomeScreenViewModel>(context, listen: false).filterTasks,
                      selectedCategory: Provider.of<HomeScreenViewModel>(context).selectedCategory,
                      selectedPriority: Provider.of<HomeScreenViewModel>(context).selectedPriority,
                    );
                  },
                );
              },
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.calendar_today_outlined,
              size: MediaQuery.of(context).size.width * 0.06,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: null,
          ),
          title: Row(
            children: [
              Text(
                "Task",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1.2,
                ),
              ),
              Text(
                "Manager",
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              )
            ],
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.all(0),
              child: IconButton(
                icon: const Icon(Icons.history_outlined),
                iconSize: MediaQuery.of(context).size.width * 0.06,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
                onPressed: () => Utils().navigateTo(
                  context,
                  HistoryScreen(
                    userId: widget.userId,
                  ),
                  true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                iconSize: MediaQuery.of(context).size.width * 0.06,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
                onPressed: () => Utils().navigateTo(
                  context,
                  Settings(
                    userId: widget.userId,
                  ),
                  true,
                ),
              ),
            )
          ],
        ),
        body: Consumer<HomeScreenViewModel>(
          builder: (context, viewModel, child) {
            return FutureBuilder<List<Task>>(
              future: viewModel.taskList,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final int completedTaskCount = snapshot.data?.where((Task task) => task.status == 0).length ?? 0;

                final filteredTasks = snapshot.data?.where((task) {
                  final matchesSearchQuery = task.title.toLowerCase().contains(viewModel.searchQuery.toLowerCase());
                  final matchesCategory =
                      viewModel.selectedCategory == 'All' || task.category == viewModel.selectedCategory;
                  final matchesPriority =
                      viewModel.selectedPriority == 'All' || task.priority == viewModel.selectedPriority;
                  return matchesSearchQuery && matchesCategory && matchesPriority;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  itemCount: 1 + (filteredTasks?.length ?? 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
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
                                  'You have [ $completedTaskCount ] pending task out of [ ${snapshot.data?.length ?? 0} ]',
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
                    return _buildTask(filteredTasks![index - 1]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
