import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entity/Employee.dart';
import '../providers/employee_provider.dart';

class EmployeeEditScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeEditScreen({super.key, this.employee});

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _ageController.text = widget.employee!.age.toString();
      _positionController.text = widget.employee!.position;
      _salaryController.text = widget.employee!.salary.toString();
      _departmentController.text = widget.employee!.department;
      _emailController.text = widget.employee!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      
      final employee = Employee(
        id: widget.employee?.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        position: _positionController.text.trim(),
        salary: double.parse(_salaryController.text.trim()),
        department: _departmentController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (widget.employee == null) {
        await employeeProvider.insertEmployee(employee);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee added successfully')),
          );
        }
      } else {
        await employeeProvider.updateEmployee(employee);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee updated successfully')),
          );
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving employee: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an age';
                }
                final age = int.tryParse(value.trim());
                if (age == null) {
                  return 'Please enter a valid number';
                }
                if (age < 0) {
                  return 'Age must be non-negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a position';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salaryController,
              decoration: const InputDecoration(
                labelText: 'Salary',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a salary';
                }
                final salary = double.tryParse(value.trim());
                if (salary == null) {
                  return 'Please enter a valid number';
                }
                if (salary < 0) {
                  return 'Salary must be non-negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a department';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an email';
                }
                final email = value.trim();
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(email)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveEmployee,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.employee == null ? 'Add Employee' : 'Update Employee'),
            ),
          ],
        ),
      ),
    );
  }
}

