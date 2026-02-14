class Employee {
  String name;
  int age;

  static int employeeCount = 0;

  Employee(this.name, this.age) {
    employeeCount++;
  }

  Employee.fromIntern(String name) : this(name, 18);

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
}