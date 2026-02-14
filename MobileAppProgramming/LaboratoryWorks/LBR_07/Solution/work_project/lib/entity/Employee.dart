class Employee {
  int? id;
  String name;
  int age;
  String position;
  double salary;
  String department;
  String email;

  static int employeeCount = 0;

  Employee({
    this.id,
    required this.name,
    required this.age,
    required this.position,
    required this.salary,
    required this.department,
    required this.email,
  }) {
    employeeCount++;
  }

  Employee.fromIntern(String name)
      : id = null,
        name = name,
        age = 18,
        position = 'Intern',
        salary = 0.0,
        department = 'General',
        email = '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'position': position,
      'salary': salary,
      'department': department,
      'email': email,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      position: map['position'] as String,
      salary: (map['salary'] as num).toDouble(),
      department: map['department'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'position': position,
      'salary': salary,
      'department': department,
      'email': email,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int?,
      name: json['name'] as String,
      age: json['age'] as int,
      position: json['position'] as String,
      salary: (json['salary'] as num).toDouble(),
      department: json['department'] as String,
      email: json['email'] as String,
    );
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
  String toString() {
    return 'Employee(id: $id, name: $name, age: $age, position: $position, salary: $salary, department: $department, email: $email)';
  }
}