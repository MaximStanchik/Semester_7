import 'package:flutter/foundation.dart';
import '../entity/Employee.dart';
import '../database/database_helper.dart';

class EmployeeProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  List<Employee> get employees => _filteredEmployees;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  EmployeeProvider() {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      await DatabaseHelper.initializeIsolate();
      List<Employee> employees = await _dbHelper.getAllEmployees();
      _employees = employees;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
      notifyListeners();
    }
  }

  void setSortBy(String sortBy) {
    if (_sortBy != sortBy) {
      _sortBy = sortBy;
      _applyFilters();
      notifyListeners();
    }
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Employee> filtered = List.from(_employees);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) {
        return emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.position.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.department.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'age':
          comparison = a.age.compareTo(b.age);
          break;
        case 'position':
          comparison = a.position.compareTo(b.position);
          break;
        case 'salary':
          comparison = a.salary.compareTo(b.salary);
          break;
        case 'department':
          comparison = a.department.compareTo(b.department);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredEmployees = filtered;
  }

  Future<void> deleteEmployee(Employee employee) async {
    try {
      await _dbHelper.deleteEmployee(employee.id!);
      await loadEmployees();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertEmployee(Employee employee) async {
    try {
      await DatabaseHelper.initializeIsolate();
      await _dbHelper.insertEmployee(employee);
      await loadEmployees();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      await DatabaseHelper.initializeIsolate();
      await _dbHelper.updateEmployee(employee);
      await loadEmployees();
    } catch (e) {
      rethrow;
    }
  }
}

