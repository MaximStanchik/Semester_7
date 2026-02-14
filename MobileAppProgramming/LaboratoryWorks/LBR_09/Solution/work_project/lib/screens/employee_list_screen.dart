import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entity/Employee.dart';
import '../providers/employee_provider.dart';
import 'employee_detail_screen.dart';
import 'employee_edit_screen.dart';
import 'file_locations_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  Future<void> _deleteEmployee(BuildContext context, Employee employee) async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
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
        await employeeProvider.deleteEmployee(employee);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting employee: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, _) {
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
                  onChanged: (value) => employeeProvider.setSearchQuery(value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text('Sort by: '),
                    DropdownButton<String>(
                      value: employeeProvider.sortBy,
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(value: 'age', child: Text('Age')),
                        DropdownMenuItem(value: 'position', child: Text('Position')),
                        DropdownMenuItem(value: 'salary', child: Text('Salary')),
                        DropdownMenuItem(value: 'department', child: Text('Department')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          employeeProvider.setSortBy(value);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(employeeProvider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () => employeeProvider.toggleSortOrder(),
                      tooltip: employeeProvider.sortAscending ? 'Ascending' : 'Descending',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: employeeProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : employeeProvider.employees.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                employeeProvider.searchQuery.isEmpty 
                                    ? 'No employees in database. Add one using the + button!' 
                                    : 'No employees match your search.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemExtent: 80.0,
                            itemCount: employeeProvider.employees.length,
                            itemBuilder: (context, index) {
                              final employee = employeeProvider.employees[index];
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
                                          employeeProvider.loadEmployees();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteEmployee(context, employee),
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
              employeeProvider.loadEmployees();
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

