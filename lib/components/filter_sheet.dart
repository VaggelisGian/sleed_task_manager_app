import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final Function(String, String) onFilter;
  final String selectedCategory;
  final String selectedPriority;

  const FilterSheet({
    super.key,
    required this.onFilter,
    required this.selectedCategory,
    required this.selectedPriority,
  });

  @override
  FilterSheetState createState() => FilterSheetState();
}

class FilterSheetState extends State<FilterSheet> {
  late String selectedCategory;
  late String selectedPriority;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    selectedPriority = widget.selectedPriority;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            items: <String>['All', 'Work', 'Personal', 'Others'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
          DropdownButton<String>(
            value: selectedPriority,
            items: <String>['All', 'High', 'Medium', 'Low'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPriority = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              widget.onFilter(selectedCategory, selectedPriority);
              Navigator.pop(context);
            },
            child: Text(
              'Apply Filters',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
