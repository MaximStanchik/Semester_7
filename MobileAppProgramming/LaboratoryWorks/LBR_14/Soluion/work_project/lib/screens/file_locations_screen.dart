import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/file_service.dart';
import '../entity/Employee.dart';

class FileLocationsScreen extends StatefulWidget {
  const FileLocationsScreen({super.key});

  @override
  State<FileLocationsScreen> createState() => _FileLocationsScreenState();
}

class _FileLocationsScreenState extends State<FileLocationsScreen> {
  final FileService _fileService = FileService.instance;
  Map<DirectoryType, String?> _directoryPaths = {};
  Map<DirectoryType, Employee?> _savedEmployees = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    setState(() => _isLoading = true);
    try {
      final paths = await _fileService.getAllFilePaths();
      setState(() {
        _directoryPaths = paths;
        _isLoading = false;
      });
      _loadSavedEmployees();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading directories: $e')),
        );
      }
    }
  }

  Future<void> _loadSavedEmployees() async {
    final Map<DirectoryType, Employee?> loaded = {};
    for (var type in DirectoryType.values) {
      try {
        final dirPath = _directoryPaths[type];
        if (dirPath != null) {
          final fileName = 'employee_${type.name}.json';
          final filePath = '$dirPath/$fileName';
          if (await _fileService.fileExists(filePath)) {
            final employee = await _fileService.readEmployeeFromFile(filePath);
            loaded[type] = employee;
          }
        }
      } catch (e) {
        print('Error loading from ${type.name}: $e');
      }
    }
    setState(() {
      _savedEmployees = loaded;
    });
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

  String _getPlatformSupport(DirectoryType type) {
    switch (type) {
      case DirectoryType.applicationLibrary:
        return 'iOS only';
      case DirectoryType.externalStorage:
      case DirectoryType.externalCache:
      case DirectoryType.externalStorageDirectories:
      case DirectoryType.downloads:
        return 'Android only';
      default:
        return 'Android & iOS';
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Path copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Locations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: DirectoryType.values.map((type) {
                final path = _directoryPaths[type];
                final employee = _savedEmployees[type];
                final isSupported = path != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(_getDirectoryTypeName(type)),
                    subtitle: Text(
                      isSupported ? _getPlatformSupport(type) : 'Not supported on ${Platform.isAndroid ? "Android" : "iOS"}',
                      style: TextStyle(
                        color: isSupported ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Path: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    path ?? 'Not available',
                                    style: TextStyle(
                                      color: isSupported ? Colors.black87 : Colors.grey,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                if (isSupported)
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () => _copyToClipboard(path),
                                    tooltip: 'Copy path',
                                  ),
                              ],
                            ),
                            if (employee != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                'Saved Employee:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              _buildEmployeeInfo(employee),
                            ] else if (isSupported) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'No employee file found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                            if (!isSupported) ...[
                              const SizedBox(height: 8),
                              Text(
                                _fileService.getPlatformError(type),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEmployeeInfo(Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${employee.name}'),
        Text('Age: ${employee.age}'),
        Text('Position: ${employee.position}'),
        Text('Salary: \$${employee.salary.toStringAsFixed(2)}'),
        Text('Department: ${employee.department}'),
        Text('Email: ${employee.email}'),
      ],
    );
  }
}

