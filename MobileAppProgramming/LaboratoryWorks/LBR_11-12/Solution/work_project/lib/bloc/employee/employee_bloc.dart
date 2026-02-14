import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entity/Employee.dart';
import '../../repositories/firestore_employee_repository.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final FirestoreEmployeeRepository _repo;

  StreamSubscription<List<Employee>>? _employeesSub;
  List<Employee> _allEmployees = const <Employee>[];

  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  EmployeeBloc({FirestoreEmployeeRepository? repo})
      : _repo = repo ?? FirestoreEmployeeRepository(),
        super(const EmployeeInitial()) {
    on<EmployeeLoadRequested>(_onLoadRequested);
    on<EmployeeStreamUpdated>(_onStreamUpdated);
    on<EmployeeSearchQueryChanged>(_onSearchQueryChanged);
    on<EmployeeSortByChanged>(_onSortByChanged);
    on<EmployeeSortOrderToggled>(_onSortOrderToggled);
    on<EmployeeDeleteRequested>(_onDeleteRequested);
    on<EmployeeUpsertRequested>(_onUpsertRequested);

    add(const EmployeeLoadRequested());
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

      _employeesSub ??= _repo.watchAll().listen(
        (employees) {
          add(EmployeeStreamUpdated(employees));
        },
      );

      if (_allEmployees.isEmpty) {
        _allEmployees = await _repo.fetchAll();
      }

      final filtered = _applyFilters(_allEmployees);

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

  Future<void> _onStreamUpdated(
    EmployeeStreamUpdated event,
    Emitter<EmployeeState> emit,
  ) async {
    _allEmployees = event.employees;
    final filtered = _applyFilters(_allEmployees);
    emit(
      EmployeeLoaded(
        employees: filtered,
        isLoading: false,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        sortAscending: _sortAscending,
      ),
    );
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
      await _repo.delete(event.employee);
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
      await _repo.upsert(event.employee);
      add(const EmployeeLoadRequested());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _employeesSub?.cancel();
    return super.close();
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
