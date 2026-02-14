import 'package:equatable/equatable.dart';

import '../../entity/Employee.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class EmployeeLoadRequested extends EmployeeEvent {
  const EmployeeLoadRequested();
}

class EmployeeSearchQueryChanged extends EmployeeEvent {
  final String query;

  const EmployeeSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class EmployeeSortByChanged extends EmployeeEvent {
  final String sortBy;

  const EmployeeSortByChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class EmployeeSortOrderToggled extends EmployeeEvent {
  const EmployeeSortOrderToggled();
}

class EmployeeDeleteRequested extends EmployeeEvent {
  final Employee employee;

  const EmployeeDeleteRequested(this.employee);

  @override
  List<Object?> get props => [employee];
}

class EmployeeStreamUpdated extends EmployeeEvent {
  final List<Employee> employees;

  const EmployeeStreamUpdated(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeeUpsertRequested extends EmployeeEvent {
  final Employee employee;

  const EmployeeUpsertRequested(this.employee);

  @override
  List<Object?> get props => [employee];
}
