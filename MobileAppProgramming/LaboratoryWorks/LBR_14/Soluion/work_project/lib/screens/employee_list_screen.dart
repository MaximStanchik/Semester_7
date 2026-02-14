import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event.dart';
import '../bloc/employee/employee_state.dart';
import '../entity/Employee.dart';
import '../utils/animations.dart';
import 'employee_detail_screen.dart';
import 'employee_edit_screen.dart';
import 'file_locations_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _headerController;
  late final AnimationController _folderController;
  late final AnimationController _fabController;

  bool _wasTickerEnabled = true;
  int _cardsAnimationSeed = 0;

  late final Animation<double> _discoverOpacity;
  late final Animation<Offset> _discoverSlide;
  late final Animation<double> _employeesOpacity;
  late final Animation<Offset> _employeesSlide;
  late final Animation<double> _folderScale;
  late final Animation<double> _searchOpacity;
  late final Animation<Offset> _searchSlide;
  late final Animation<double> _sortOpacity;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EmployeeBloc>().add(const EmployeeLoadRequested());
    });

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _folderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    final discoverCurve = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.00, 0.22, curve: SinInCurve()),
    );
    _discoverOpacity = Tween<double>(begin: 0, end: 1).animate(discoverCurve);
    _discoverSlide = Tween<Offset>(begin: const Offset(-0.18, 0), end: Offset.zero).animate(discoverCurve);

    final employeesCurve = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.12, 0.35, curve: SinInCurve()),
    );
    _employeesOpacity = Tween<double>(begin: 0, end: 1).animate(employeesCurve);
    _employeesSlide = Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero).animate(employeesCurve);

    final folderCurve = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.28, 0.50, curve: SinInCurve()),
    );
    _folderScale = Tween<double>(begin: 0.6, end: 1).animate(folderCurve);

    final searchCurve = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.46, 0.70, curve: SinInCurve()),
    );
    _searchOpacity = Tween<double>(begin: 0, end: 1).animate(searchCurve);
    _searchSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(searchCurve);

    final sortCurve = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.66, 0.90, curve: SinInCurve()),
    );
    _sortOpacity = Tween<double>(begin: 0, end: 1).animate(sortCurve);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _headerController.forward(from: 0);
      _fabController.repeat(reverse: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.of(context);
    if (enabled && !_wasTickerEnabled) {
      _folderController.reset();
      _headerController.forward(from: 0);
      _fabController.repeat(reverse: true);
      setState(() => _cardsAnimationSeed++);
    }
    _wasTickerEnabled = enabled;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerController.dispose();
    _folderController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _headerController
      ..stop()
      ..reset()
      ..forward();
    _folderController.reset();
    _fabController
      ..stop()
      ..reset()
      ..repeat(reverse: true);
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _discoverOpacity,
                              child: SlideTransition(
                                position: _discoverSlide,
                                child: const Text(
                                  'Discover',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FadeTransition(
                              opacity: _employeesOpacity,
                              child: SlideTransition(
                                position: _employeesSlide,
                                child: const Text(
                                  'Employees',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScaleTransition(
                        scale: _folderScale,
                        child: Container(
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
                            icon: RotationTransition(
                              turns: Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(parent: _folderController, curve: Curves.easeInOut),
                              ),
                              child: const Icon(Icons.folder, color: Colors.black),
                            ),
                            onPressed: () {
                              _folderController.forward(from: 0);
                              Navigator.push(
                                context,
                                buildSlideFadeRoute(builder: (context) => const FileLocationsScreen()),
                              );
                            },
                            tooltip: 'File Locations',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _searchOpacity,
                    child: SlideTransition(
                      position: _searchSlide,
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
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _sortOpacity,
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
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: () {
                    if (employeeState is EmployeeError) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: Center(
                          key: const ValueKey('employee_error'),
                          child: Text('Error: ${employeeState.message}'),
                        ),
                      );
                    }
                    if (isLoading) {
                      return const AnimatedSwitcher(
                        duration: Duration(milliseconds: 240),
                        child: Center(
                          key: ValueKey('employee_loading'),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (employees.isEmpty) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: Center(
                          key: const ValueKey('employee_empty'),
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
                        ),
                      );
                    }

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: ListView.separated(
                        key: const ValueKey('employee_list'),
                        itemCount: employees.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          return _buildEmployeeCard(context, employee, index);
                        },
                      ),
                    );
                  }(),
                ),
              ],
            ),
          ),
          floatingActionButton: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.06).animate(
              CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
            ),
            child: FloatingActionButton(
              heroTag: 'employee_add_fab',
              onPressed: () async {
                await Navigator.push(
                  context,
                  buildScaleFadeRoute(builder: (context) => const EmployeeEditScreen()),
                );
                if (context.mounted) {
                  context.read<EmployeeBloc>().add(const EmployeeLoadRequested());
                }
              },
              backgroundColor: const Color(0xFF3A2A2A),
              child: const Icon(Icons.add, color: Colors.white),
            ),
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
          buildSlideUpFadeRoute(builder: (context) => EmployeeDetailScreen(employee: employee)),
        );
      },
      child: TweenAnimationBuilder<double>(
        key: ValueKey('employee_card_${employee.id ?? index}_$_cardsAnimationSeed'),
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 420 + (index * 35).clamp(0, 280)),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 12),
              child: child,
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
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  builder: (context, t, child) {
                    return Transform.scale(scale: t, child: child);
                  },
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
                              buildScaleFadeRoute(builder: (context) => EmployeeEditScreen(employee: employee)),
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
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 520),
                          curve: Curves.easeOut,
                          builder: (context, t, child) {
                            return Transform.scale(scale: 1 - (0.04 * (1 - t)), child: child);
                          },
                          child: Container(
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
                        ),
                        const SizedBox(width: 10),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 620),
                          curve: Curves.easeOut,
                          builder: (context, t, child) {
                            return Opacity(opacity: 0.65 + (0.35 * t), child: child);
                          },
                          child: Container(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

