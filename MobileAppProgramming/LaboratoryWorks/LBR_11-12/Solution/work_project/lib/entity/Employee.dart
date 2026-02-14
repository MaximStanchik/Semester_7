class Employee {
  int? id;
  String? firestoreId;
  String name;
  int age;
  String position;
  double salary;
  String department;
  String email;

  static int employeeCount = 0;

  Employee({
    this.id,
    this.firestoreId,
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
        firestoreId = null,
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'name': name,
      'age': age,
      'position': position,
      'salary': salary,
      'department': department,
      'email': email,
    };
  }

  factory Employee.fromFirestore(
    dynamic doc,
  ) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    return Employee(
      id: (data['id'] as num?)?.toInt(),
      firestoreId: (data['firestoreId'] as String?) ?? doc.id as String?,
      name: (data['name'] as String?) ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      position: (data['position'] as String?) ?? '',
      salary: (data['salary'] as num?)?.toDouble() ?? 0,
      department: (data['department'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
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