import '../abstract/Workable.dart';

class Technician implements Workable {
  String task;

  Technician(this.task);

  @override
  void startWork() {
    print("Technician started $task.");
  }

  @override
  void stopWork() {
    print("Technician stopped $task.");
  }
}