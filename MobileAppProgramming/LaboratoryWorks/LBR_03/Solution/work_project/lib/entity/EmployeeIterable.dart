import 'Employee.dart';
import 'EmployeeIterator.dart';

class EmployeeIterable extends Iterable<Employee> {
  final List<Employee> _employees;

  EmployeeIterable(this._employees);

  @override
  Iterator<Employee> get iterator => EmployeeIterator(_employees);
}
