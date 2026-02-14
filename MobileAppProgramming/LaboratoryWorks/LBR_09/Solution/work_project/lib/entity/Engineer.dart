import '../abstract/Worker.dart';

class Engineer extends Worker {
  String specialization;

  Engineer(super.name, super.age, this.specialization);

  @override
  void work() {
    print("$name is working on $specialization tasks.");
  }
}