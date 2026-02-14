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
      List<Employee> employees = await _dbHelper.getAllEmployees();
      setState(() {
        _employees = employees;
        _applyFilters();
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

  void _applyFilters() {
    List<Employee> filtered = _employees;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) {
        return emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.position.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.department.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'age':
          comparison = a.age.compareTo(b.age);
          break;
        case 'position':
          comparison = a.position.compareTo(b.position);
          break;
        case 'salary':
          comparison = a.salary.compareTo(b.salary);
          break;
        case 'department':
          comparison = a.department.compareTo(b.department);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredEmployees = filtered;
    });
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
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
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _applyFilters();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                      _applyFilters();
                    });
                  },
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

