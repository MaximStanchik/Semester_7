import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/database_helper.dart';
import '../../entity/Employee.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  EmployeeBloc() : super(const EmployeeInitial()) {
    on<EmployeeLoadRequested>(_onLoadRequested);
    on<EmployeeSearchQueryChanged>(_onSearchQueryChanged);
    on<EmployeeSortByChanged>(_onSortByChanged);
    on<EmployeeSortOrderToggled>(_onSortOrderToggled);
    on<EmployeeDeleteRequested>(_onDeleteRequested);
    on<EmployeeUpsertRequested>(_onUpsertRequested);
  }

  Future<void> _onLoadRequested(
    EmployeeLoadRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      final prevLoaded = state is EmployeeLoaded ? state as EmployeeLoaded : null;
      emit(
        EmployeeLoaded(
          employees: prevLoaded?.employees ?? const <Employee>[],
          isLoading: true,
          searchQuery: _searchQuery,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
        ),
      );

      await DatabaseHelper.initializeIsolate();
      final employees = await _dbHelper.getAllEmployees();
      final filtered = _applyFilters(employees);

      emit(
        EmployeeLoaded(
          employees: filtered,
          isLoading: false,
          searchQuery: _searchQuery,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
        ),
      );
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onSearchQueryChanged(
    EmployeeSearchQueryChanged event,
    Emitter<EmployeeState> emit,
  ) async {
    _searchQuery = event.query;
    add(const EmployeeLoadRequested());
  }

  Future<void> _onSortByChanged(
    EmployeeSortByChanged event,
    Emitter<EmployeeState> emit,
  ) async {
    _sortBy = event.sortBy;
    add(const EmployeeLoadRequested());
  }

  Future<void> _onSortOrderToggled(
    EmployeeSortOrderToggled event,
    Emitter<EmployeeState> emit,
  ) async {
    _sortAscending = !_sortAscending;
    add(const EmployeeLoadRequested());
  }

  Future<void> _onDeleteRequested(
    EmployeeDeleteRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      if (event.employee.id == null) return;
      await _dbHelper.deleteEmployee(event.employee.id!);
      add(const EmployeeLoadRequested());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onUpsertRequested(
    EmployeeUpsertRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      if (event.employee.id == null) {
        await _dbHelper.insertEmployee(event.employee);
      } else {
        await _dbHelper.updateEmployee(event.employee);
      }
      add(const EmployeeLoadRequested());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  List<Employee> _applyFilters(List<Employee> employees) {
    var filtered = List<Employee>.from(employees);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((emp) {
        return emp.name.toLowerCase().contains(q) ||
            emp.position.toLowerCase().contains(q) ||
            emp.department.toLowerCase().contains(q) ||
            emp.email.toLowerCase().contains(q);
      }).toList();
    }

    filtered.sort((a, b) {
      int comparison;
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

    return filtered;
  }
}
