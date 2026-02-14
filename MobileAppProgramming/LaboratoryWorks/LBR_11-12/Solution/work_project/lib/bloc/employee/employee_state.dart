import 'package:equatable/equatable.dart';

import '../../entity/Employee.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {
  const EmployeeInitial();
}

class EmployeeLoading extends EmployeeState {
  const EmployeeLoading();
}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  final bool isLoading;
  final String searchQuery;
  final String sortBy;
  final bool sortAscending;

  const EmployeeLoaded({
    required this.employees,
    required this.isLoading,
    required this.searchQuery,
    required this.sortBy,
    required this.sortAscending,
  });

  @override
  List<Object?> get props => [employees, isLoading, searchQuery, sortBy, sortAscending];

  EmployeeLoaded copyWith({
    List<Employee>? employees,
    bool? isLoading,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
  }) {
    return EmployeeLoaded(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}
