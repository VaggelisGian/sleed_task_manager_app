import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static late final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colCategory = 'category';
  String colStatus = 'status';

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}task_list.db';
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tasksTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colCategory TEXT, $colStatus INTEGER)',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database? db = await this.db;
    return await db!.query(tasksTable);
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    return taskMapList.map((taskMap) => Task.fromMap(taskMap)).toList();
  }

  Future<int> insertTask(Task task) async {
    Database? db = await this.db;
    return await db!.insert(tasksTable, task.toMap());
  }

  Future<int> updateTask(Task task) async {
    Database? db = await this.db;
    return await db!.update(
      tasksTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      tasksTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTask() async {
    Database? db = await this.db;
    return await db!.delete(tasksTable);
  }

  Future<void> addTaskToFirebase(Task task, String userId) async {
    final tasksCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('tasks');
    await tasksCollection.doc(task.id.toString()).set(task.toMap());
  }

  Future<void> deleteAllTasks(String userId) async {
    Database? db = await this.db;
    await db!.delete(tasksTable);

    final tasksCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('tasks');
    final querySnapshot = await tasksCollection.get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> syncToFirebase(String userId) async {
    try {
      final tasksCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('tasks');
      final localTasks = await getTaskList();
      final querySnapshot = await tasksCollection.get().timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            "The connection has timed out, the data will be synced when the connection is restored.");
      });
      final firebaseTaskMap = {
        for (var doc in querySnapshot.docs) int.parse(doc.id): Task.fromMap(doc.data() as Map<String, dynamic>)
      };

      for (var task in localTasks) {
        if (firebaseTaskMap.containsKey(task.id)) {
          if (task.date.isAfter(firebaseTaskMap[task.id]!.date)) {
            await tasksCollection.doc(task.id.toString()).update(task.toMap()).timeout(const Duration(seconds: 10),
                onTimeout: () {
              throw TimeoutException(
                  "The connection has timed out, the data will be synced when the connection is restored.");
            });
          }
        } else {
          await tasksCollection.doc(task.id.toString()).set(task.toMap()).timeout(const Duration(seconds: 10),
              onTimeout: () {
            throw TimeoutException(
                "The connection has timed out, the data will be synced when the connection is restored.");
          });
        }
      }
    } catch (e) {
      print('Error syncing to Firebase: $e');
      throw Exception('Error syncing to Firebase: $e');
    }
  }

  Future<void> syncFromFirebase(String userId) async {
    try {
      Database? db = await this.db;
      final tasksCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('tasks');
      final querySnapshot = await tasksCollection.get().timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            "The connection has timed out, the data will be synced when the connection is restored.");
      });
      final localTasks = await getTaskList();
      final localTaskMap = {for (var task in localTasks) task.id!: task};

      for (var doc in querySnapshot.docs) {
        final task = Task.fromMap(doc.data() as Map<String, dynamic>);
        if (localTaskMap.containsKey(task.id)) {
          if (task.date.isAfter(localTaskMap[task.id]!.date)) {
            await updateTask(task).timeout(const Duration(seconds: 10), onTimeout: () {
              throw TimeoutException(
                  "The connection has timed out, the data will be synced when the connection is restored.");
            });
          }
        } else {
          await insertTask(task).timeout(const Duration(seconds: 10), onTimeout: () {
            throw TimeoutException(
                "The connection has timed out, the data will be synced when the connection is restored.");
          });
        }
      }
    } catch (e) {
      print('Error syncing from Firebase: $e');
      throw Exception('Error syncing from Firebase: $e');
    }
  }
}
