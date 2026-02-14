import 'dart:async';
import 'dart:isolate';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../entity/Employee.dart';

Database? _database;
String? _databasePath;

Future<String> _getDatabasePath() async {
  if (_databasePath != null) return _databasePath!;
  final documentsDirectory = await getApplicationDocumentsDirectory();
  _databasePath = join(documentsDirectory.path, 'employees.db');
  return _databasePath!;
}

Future<Database> _getDatabase() async {
  if (_database != null) return _database!;
  
  final dbPath = await _getDatabasePath();
  _database = await openDatabase(
    dbPath,
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE employees(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          age INTEGER NOT NULL,
          position TEXT NOT NULL,
          salary REAL NOT NULL,
          department TEXT NOT NULL,
          email TEXT NOT NULL
        )
      ''');
    },
  );
  return _database!;
}

List<Employee> _processEmployeeMaps(List<Map<String, dynamic>> maps) {
  return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  static Future<void> initializeIsolate() async {
    await _getDatabase();
  }

  Future<int> insertEmployee(Employee employee) async {
    final db = await _getDatabase();
    final result = await db.insert('employees', employee.toMap());
    return await compute((int id) => id, result);
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return await compute(_processEmployeeMaps, maps);
  }

  Future<Employee?> getEmployeeById(int id) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    final employees = await compute(_processEmployeeMaps, maps);
    return employees.first;
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await _getDatabase();
    final result = await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
    return await compute((int count) => count, result);
  }

  Future<int> deleteEmployee(int id) async {
    final db = await _getDatabase();
    final result = await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
    return await compute((int count) => count, result);
  }

  Future<List<Employee>> searchEmployees(String query) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'name LIKE ? OR position LIKE ? OR department LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return await compute(_processEmployeeMaps, maps);
  }

  Future<List<Employee>> sortEmployees(String sortBy, bool ascending) async {
    final db = await _getDatabase();
    final String orderBy = ascending ? '$sortBy ASC' : '$sortBy DESC';
    final List<Map<String, dynamic>> maps = await db.query('employees', orderBy: orderBy);
    return await compute(_processEmployeeMaps, maps);
  }
}
