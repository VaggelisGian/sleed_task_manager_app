import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../models/task_model.dart';
import '../viewmodel/add_task_screen_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task? task;
  final String userId;

  const AddTaskScreen({required this.updateTaskList, this.task, required this.userId, super.key});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddTaskScreenViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<AddTaskScreenViewModel>(context, listen: false);
    viewModel.initializeTask(widget.task);
  }

  @override
  void dispose() {
    viewModel.clearControllers();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? 'Add Task' : 'Update Task',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Consumer<AddTaskScreenViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        children: <Widget>[
                          _buildTitleField(viewModel),
                          _buildDateField(viewModel),
                          _buildPriorityField(viewModel),
                          _buildCategoryField(viewModel),
                          _buildSubmitButton(viewModel),
                          if (widget.task != null) _buildDeleteButton(viewModel),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(AddTaskScreenViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        style: const TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).textTheme.bodyMedium?.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (input) => input!.trim().isEmpty ? 'Please enter a task title' : null,
        onSaved: (input) => viewModel.title = input!,
        initialValue: viewModel.title,
      ),
    );
  }

  Widget _buildDateField(AddTaskScreenViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        readOnly: true,
        controller: viewModel.dateController,
        style: const TextStyle(fontSize: 18.0),
        onTap: () => viewModel.handleDatePicker(context),
        decoration: InputDecoration(
          labelText: 'Date',
          labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).textTheme.bodyMedium?.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityField(AddTaskScreenViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            isDense: true,
            items: viewModel.priorities.map((String priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              );
            }).toList(),
            style: const TextStyle(fontSize: 18.0),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              labelText: 'Priority',
              labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).textTheme.bodyMedium?.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
                borderRadius: BorderRadius.circular(10.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (input) => viewModel.priority == null ? 'Please select a priority level' : null,
            onChanged: (value) {
              viewModel.priority = value;
            },
            onSaved: (value) => viewModel.priority = value,
            value: viewModel.priority,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryField(AddTaskScreenViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            isDense: true,
            items: viewModel.categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              );
            }).toList(),
            style: const TextStyle(fontSize: 18.0),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              labelText: 'Category',
              labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).textTheme.bodyMedium?.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
                borderRadius: BorderRadius.circular(10.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (input) => viewModel.category == null ? 'Please select a category' : null,
            onChanged: (value) {
              viewModel.category = value;
            },
            onSaved: (value) => viewModel.category = value,
            value: viewModel.category,
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AddTaskScreenViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: 60.0,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.task == null
              ? [Theme.of(context).hintColor, Theme.of(context).hintColor]
              : [Colors.green, Colors.green],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () => viewModel.submitTask(context, _formKey, widget.task, widget.userId, widget.updateTaskList),
        child: Text(
          widget.task == null ? 'Add' : 'Update',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(AddTaskScreenViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0),
      height: 60.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextButton(
        onPressed: () => viewModel.deleteTask(context, widget.task, widget.userId, widget.updateTaskList),
        child: Text(
          'Delete',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
