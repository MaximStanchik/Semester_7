import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event.dart';
import '../bloc/employee/employee_state.dart';
import '../entity/Employee.dart';
import 'employee_detail_screen.dart';
import 'employee_edit_screen.dart';
import 'file_locations_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteEmployee(BuildContext context, Employee employee) async {
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
      context.read<EmployeeBloc>().add(EmployeeDeleteRequested(employee));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, employeeState) {
        final loaded = employeeState is EmployeeLoaded ? employeeState : null;
        final isLoading = loaded?.isLoading ?? employeeState is EmployeeLoading || employeeState is EmployeeInitial;
        final employees = loaded?.employees ?? const <Employee>[];
        final searchQuery = loaded?.searchQuery ?? '';
        final sortBy = loaded?.sortBy ?? 'name';
        final sortAscending = loaded?.sortAscending ?? true;

        if (_searchController.text != searchQuery) {
          _searchController.value = _searchController.value.copyWith(
            text: searchQuery,
            selection: TextSelection.collapsed(offset: searchQuery.length),
            composing: TextRange.empty,
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discover',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Employees',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.folder, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FileLocationsScreen()),
                            );
                          },
                          tooltip: 'File Locations',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 55,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(10, 10),
                          blurRadius: 20,
                          color: Colors.grey.withOpacity(0.18),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                        hintText: 'Search here...',
                        border: InputBorder.none,
                        suffixIcon: Icon(
                          Icons.search_outlined,
                          color: Color.fromARGB(255, 1, 12, 50),
                          size: 28,
                        ),
                      ),
                      onChanged: (value) =>
                          context.read<EmployeeBloc>().add(EmployeeSearchQueryChanged(value)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Sort by:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: sortBy,
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(value: 'age', child: Text('Age')),
                          DropdownMenuItem(value: 'position', child: Text('Position')),
                          DropdownMenuItem(value: 'salary', child: Text('Salary')),
                          DropdownMenuItem(value: 'department', child: Text('Department')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<EmployeeBloc>().add(EmployeeSortByChanged(value));
                          }
                        },
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 20,
                            color: Colors.black,
                          ),
                          onPressed: () =>
                              context.read<EmployeeBloc>().add(const EmployeeSortOrderToggled()),
                          tooltip: sortAscending ? 'Ascending' : 'Descending',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: () {
                    if (employeeState is EmployeeError) {
                      return Center(child: Text('Error: ${employeeState.message}'));
                    }
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (employees.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            searchQuery.isEmpty
                                ? 'No employees in database. Add one using the + button!'
                                : 'No employees match your search.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: employees.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return _buildEmployeeCard(context, employee, index);
                      },
                    );
                  }(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'employee_add_fab',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmployeeEditScreen(),
                ),
              );
              if (context.mounted) {
                context.read<EmployeeBloc>().add(const EmployeeLoadRequested());
              }
            },
            backgroundColor: const Color(0xFF3A2A2A),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee, int index) {
    final themeColor = index.isEven ? const Color(0xFFFFA726) : const Color(0xFF66BB6A);
    final bgColor = themeColor.withOpacity(0.22);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailScreen(employee: employee),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.edit, color: Colors.black.withOpacity(0.55), size: 22),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmployeeEditScreen(employee: employee),
                            ),
                          );
                          if (context.mounted) {
                            context.read<EmployeeBloc>().add(const EmployeeLoadRequested());
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                        onPressed: () => _deleteEmployee(context, employee),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${employee.position} • ${employee.department}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Age: ${employee.age}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeColor.withOpacity(0.95),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Salary: ${employee.salary}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeColor.withOpacity(0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

