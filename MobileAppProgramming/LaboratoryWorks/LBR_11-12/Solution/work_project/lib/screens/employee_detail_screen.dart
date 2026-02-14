import 'package:flutter/material.dart';
import '../entity/Employee.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', employee.id?.toString() ?? 'N/A'),
                const Divider(),
                _buildDetailRow('Name', employee.name),
                const Divider(),
                _buildDetailRow('Age', employee.age.toString()),
                const Divider(),
                _buildDetailRow('Position', employee.position),
                const Divider(),
                _buildDetailRow('Salary', '\$${employee.salary.toStringAsFixed(2)}'),
                const Divider(),
                _buildDetailRow('Department', employee.department),
                const Divider(),
                _buildDetailRow('Email', employee.email),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

