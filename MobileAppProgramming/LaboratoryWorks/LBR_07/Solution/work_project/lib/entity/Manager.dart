import '../abstract/Worker.dart';

class Manager extends Worker {
  String department;

  Manager(super.name, super.age, this.department);

  @override
  void work() {
    print("$name is managing the $department department.");
  }
}