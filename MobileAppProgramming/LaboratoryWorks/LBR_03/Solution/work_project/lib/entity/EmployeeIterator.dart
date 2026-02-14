import 'Employee.dart';

class EmployeeIterator implements Iterator<Employee> {
  int _index = -1;
  final List<Employee> _employees;

  EmployeeIterator(this._employees);

  @override
  Employee get current => _employees[_index];

  @override
  bool moveNext() {
    _index++;
    return _index < _employees.length;
  }
}