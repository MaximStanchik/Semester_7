import 'package:work_project/entity/Employee.dart';
import 'package:work_project/entity/EmployeeIterable.dart';
import 'package:work_project/entity/Technician.dart';
import 'package:work_project/abstract/Worker.dart';
import 'package:work_project/entity/Engineer.dart';
import 'package:work_project/entity/Manager.dart';
import 'dart:async';

import 'package:work_project/service/FetchingData.dart';

Future<void> main(List<String> arguments) async {

  print('Start fetching data...');
  print(callFuture());
  print('Data fetching completed.');

  Technician technician = Technician("fixing machinery");
  technician.startWork();
  technician.stopWork();

  print('---------------------------');

  Employee employee1 = Employee("Vlad", 30);
  print("Employee name: ${employee1.employeeName}");
  print("Employee age: ${employee1.age}");

  employee1.employeeAge = 35;
  print("Updated employee age: ${employee1.age}");

  Employee intern = Employee.fromIntern("Anton");
  print("Intern name: ${intern.employeeName}");
  print("Intern age: ${intern.age}");

  Employee.showEmployeeCount();

  employee1.takeLeave(days: 5);

  employee1.workOvertime();
  employee1.workOvertime(4);

  employee1.taskAssignment(() {
    print("Task: Write a report.");
  });

  Employee.showEmployeeCount();

  print('---------------------------');

  List<Worker> workers = [
    Manager("Vlad", 35, "Engineering"),
    Engineer("Anton", 28, "Software"),
    Engineer("Egor", 23, "Network")
  ];

  for (var worker in workers) {
    worker.work();

    if (worker is Engineer) {
      worker.sendMessage("Task completed successfully!");
      worker.scheduleMeeting(DateTime.now().add(Duration(days: 1)));
    }
  }

  print('---------------------------');

  Map<String, int> employeeHours = {
    "Alice": 40,
    "Bob": 35,
    "Steve": 45
  };

  employeeHours.forEach((employee, hours) {
    print("$employee worked $hours hours this week.");
  });

  print('---------------------------');

  Set<String> completedTasks = {"Review designs", "Test prototypes"};
  completedTasks.add("Deploy updates");

  print("Completed tasks: $completedTasks");

  print('---------------------------');

  List<String> tasks = ["task1", "task2", "break task", "task3"];

  for (var task in tasks) {
    if (task == "task2") {
      continue;
    }
    if (task == "break task") {
      break;
    }
    print(task);
  }

  print('---------------------------');

  List<Employee> employees = [
    Employee("Alice", 30),
    Employee("Bob", 25),
    Employee("Charlie", 35)
  ];

  employees.sort();
  print("Employees sorted by age:");
  for (var emp in employees) {
    print("${emp.employeeName}: ${emp.age} years old");
  }

  print('---------------------------');

  EmployeeIterable employeeIterable = EmployeeIterable(employees);
  print("Iterating through employees:");
  for (var employee in employeeIterable) {
    print("Employee: ${employee.employeeName}");
  }

  print('---------------------------');

  print("Testing async functions:");
  fetchData().then((data) => print(data));
  callFuture().then((_) => print("Future callback completed"));

  print('---------------------------');
  print('JSON Serialization Demo');
  print('---------------------------');

  Employee employee = Employee("Alice", 30);

  print("=== Serialization to JSON ===");
  await Employee.saveToFile('employee.json', employee);

  print("\n=== Deserialization from JSON ===");

  Employee deserializedEmployee = await Employee.loadFromFile('employee.json');

  print("Deserialized Employee: ${deserializedEmployee.name}, Age: ${deserializedEmployee.age}");

  print('---------------------------');

  try {
    int result = 100 ~/ 0;
    print(result);
  } catch (e) {
    print("Caught an exception: $e");
  } finally {
    print("Execution completed.");
  }
}