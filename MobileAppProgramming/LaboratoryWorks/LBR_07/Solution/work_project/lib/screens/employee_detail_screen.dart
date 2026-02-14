import 'package:flutter/material.dart';
import '../entity/Employee.dart';
import '../services/file_service.dart';
import 'file_locations_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final FileService _fileService = FileService.instance;
  bool _isSaving = false;

  Future<void> _saveToFile(DirectoryType directoryType) async {
    setState(() => _isSaving = true);
    try {
      final fileName = 'employee_${widget.employee.id ?? 'new'}_${directoryType.name}.json';
      final filePath = await _fileService.saveEmployeeToFile(
        widget.employee,
        directoryType,
        fileName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee saved to: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showSaveDialog() async {
    final directoryType = await showDialog<DirectoryType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Employee to File'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: DirectoryType.values.length,
            itemBuilder: (context, index) {
              final type = DirectoryType.values[index];
              return ListTile(
                title: Text(_getDirectoryTypeName(type)),
                onTap: () => Navigator.pop(context, type),
              );
            },
          ),
        ),
      ),
    );

    if (directoryType != null) {
      await _saveToFile(directoryType);
    }
  }

  String _getDirectoryTypeName(DirectoryType type) {
    return type.name
        .split(RegExp(r'(?=[A-Z])'))
        .join(' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _showSaveDialog,
            tooltip: 'Save to file',
          ),
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FileLocationsScreen()),
              );
            },
            tooltip: 'File Locations',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', widget.employee.id?.toString() ?? 'N/A'),
                const Divider(),
                _buildDetailRow('Name', widget.employee.name),
                const Divider(),
                _buildDetailRow('Age', widget.employee.age.toString()),
                const Divider(),
                _buildDetailRow('Position', widget.employee.position),
                const Divider(),
                _buildDetailRow('Salary', '\$${widget.employee.salary.toStringAsFixed(2)}'),
                const Divider(),
                _buildDetailRow('Department', widget.employee.department),
                const Divider(),
                _buildDetailRow('Email', widget.employee.email),
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

