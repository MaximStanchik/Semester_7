import 'package:flutter/material.dart';
import '../entity/Employee.dart';
import '../database/database_helper.dart';
import 'employee_detail_screen.dart';
import 'employee_edit_screen.dart';
import 'file_locations_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      await DatabaseHelper.initializeIsolate();
      final employees = await _dbHelper.sortEmployees(_sortBy, _sortAscending);
      setState(() {
        _employees = List<Employee>.from(employees);
        _filteredEmployees = _filterEmployees(_employees);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading employees: $e')),
        );
      }
    }
  }

  List<Employee> _filterEmployees(List<Employee> source) {
    var filtered = List<Employee>.from(source);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) {
        final query = _searchQuery.toLowerCase();
        return emp.name.toLowerCase().contains(query) ||
            emp.position.toLowerCase().contains(query) ||
            emp.department.toLowerCase().contains(query) ||
            emp.email.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _handleSearch(String value) {
    setState(() {
      _searchQuery = value;
      _filteredEmployees = _filterEmployees(_employees);
    });
  }

  Future<void> _handleSortFieldChange(String? value) async {
    if (value == null || value == _sortBy) return;
    setState(() => _sortBy = value);
    await _loadEmployees();
  }

  Future<void> _toggleSortOrder() async {
    setState(() => _sortAscending = !_sortAscending);
    await _loadEmployees();
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteEmployee(employee.id!);
        _loadEmployees();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting employee: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _handleSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Sort by: '),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'age', child: Text('Age')),
                    DropdownMenuItem(value: 'position', child: Text('Position')),
                    DropdownMenuItem(value: 'salary', child: Text('Salary')),
                    DropdownMenuItem(value: 'department', child: Text('Department')),
                  ],
                  onChanged: _handleSortFieldChange,
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: _toggleSortOrder,
                  tooltip: _sortAscending ? 'Ascending' : 'Descending',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _searchQuery.isEmpty 
                                ? 'No employees in database. Add one using the + button!' 
                                : 'No employees match your search.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemExtent: 80.0,
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(employee.name),
                              subtitle: Text('${employee.position} - ${employee.department}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EmployeeEditScreen(employee: employee),
                                        ),
                                      );
                                      _loadEmployees();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEmployee(employee),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmployeeDetailScreen(employee: employee),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeEditScreen(),
            ),
          );
          _loadEmployees();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

