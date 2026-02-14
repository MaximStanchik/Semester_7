import 'package:work_project/mixin/Communicator.dart';
import 'package:work_project/mixin/Scheduler.dart';

import '../abstract/Worker.dart';

class Engineer extends Worker with Communicator, Scheduler{
  String specialization;

  Engineer(super.name, super.age, this.specialization);

  @override
  void work() {
    print("$name is working on $specialization tasks.");
  }
}