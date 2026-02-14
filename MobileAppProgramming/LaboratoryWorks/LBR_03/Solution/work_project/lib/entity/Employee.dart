import 'dart:convert';
import 'dart:io';

class Employee implements Comparable<Employee>{
  String name;
  int age;

  static int employeeCount = 0;

  Employee(this.name, this.age) {
    employeeCount++;
  }

  Employee.fromIntern(String name) : this(name, 18);

  Employee.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'] {
    employeeCount++;
  }

  String get employeeName => name;

  set employeeAge(int age) {
    if (age > 0) {
      this.age = age;
    }
  }

  static void showEmployeeCount() {
    print("Total employees: $employeeCount");
  }

  void takeLeave({required int days}) {
    print("$name is taking $days days off.");
  }

  void workOvertime([int hours = 2]) {
    print("$name is working overtime for $hours hours.");
  }

  void taskAssignment(Function task) {
    print("Assigning task to $name.");
    task();
  }

  @override
  int compareTo(Employee other) {
    return age.compareTo(other.age);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Employee',
      'name': name,
      'age': age,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static Employee fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Employee.fromJson(json);
  }

  static Future<void> saveToFile(String filePath, Employee employee) async {
    final file = File(filePath);
    await file.writeAsString(employee.toJsonString());
    print('Employee data saved to $filePath');
  }

  static Future<Employee> loadFromFile(String filePath) async {
    final file = File(filePath);
    String jsonString = await file.readAsString();
    return Employee.fromJsonString(jsonString);
  }
}