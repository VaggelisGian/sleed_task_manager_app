class Task {
  int? id;
  String title;
  DateTime date;
  String priority;
  String category;
  int status; // 0 - Incomplete, 1 - Complete

  Task({
    this.id,
    required this.title,
    required this.date,
    required this.priority,
    required this.category,
    required this.status,
  });

  Task.withId({
    this.id,
    required this.title,
    required this.date,
    required this.priority,
    required this.category,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['category'] = category;
    map['status'] = status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      category: map['category'],
      status: map['status'],
    );
  }
}
