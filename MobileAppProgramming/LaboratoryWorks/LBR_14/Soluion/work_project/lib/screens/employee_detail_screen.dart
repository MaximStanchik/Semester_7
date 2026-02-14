import 'package:flutter/material.dart';
import '../entity/Employee.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _rowOpacity;
  late final List<Animation<double>> _rowScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    final rowsCount = 7;
    _rowOpacity = List.generate(rowsCount, (i) {
      final start = (i * 0.09).clamp(0.0, 1.0);
      final end = (start + 0.22).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _rowScale = List.generate(rowsCount, (i) {
      final start = (i * 0.09).clamp(0.0, 1.0);
      final end = (start + 0.22).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.92, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedDetailRow(0, 'ID', widget.employee.id?.toString() ?? 'N/A'),
                const Divider(),
                _buildAnimatedDetailRow(1, 'Name', widget.employee.name),
                const Divider(),
                _buildAnimatedDetailRow(2, 'Age', widget.employee.age.toString()),
                const Divider(),
                _buildAnimatedDetailRow(3, 'Position', widget.employee.position),
                const Divider(),
                _buildAnimatedDetailRow(4, 'Salary', '\$${widget.employee.salary.toStringAsFixed(2)}'),
                const Divider(),
                _buildAnimatedDetailRow(5, 'Department', widget.employee.department),
                const Divider(),
                _buildAnimatedDetailRow(6, 'Email', widget.employee.email),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDetailRow(int index, String label, String value) {
    return FadeTransition(
      opacity: _rowOpacity[index],
      child: ScaleTransition(scale: _rowScale[index], child: _buildDetailRow(label, value)),
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

