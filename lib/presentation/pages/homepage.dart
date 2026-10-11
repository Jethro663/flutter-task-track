import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/core_state.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_category_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../widgets/task_widget.dart';
import '../widgets/rotating_gradient_background.dart';

enum HomeView { todo, allTasks, categories, calendar }

class HomePageState extends StatefulWidget {
  const HomePageState({super.key});

  @override
  State<StatefulWidget> createState() => Homepage();
}

class Homepage extends State<HomePageState> {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  HomeView _currentView = HomeView.todo;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategoryFilter = "All";

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCategoryModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Category Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212121),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _categoryRepository.addCategory(
                    TaskCategory(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: nameController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryModal(BuildContext context, TaskCategory category) {
    final TextEditingController nameController = TextEditingController(text: category.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Category", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Category Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212121),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _categoryRepository.updateCategory(
                    TaskCategory(
                      id: category.id,
                      name: nameController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskModal(BuildContext context, DateTime date) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    TaskCategory? selectedCategory;
    
    final categories = _categoryRepository.getAllCategories();
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                "Add Task for ${date.day}/${date.month}/${date.year}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Task Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        hintText: "Task Details",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<TaskCategory>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          hintText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCategory = value;
                          });
                        },
                      )
                    else
                      const Text("No categories found. Defaulting to 'General'."),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212121),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      _taskRepository.addTask(
                        TaskItem(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: nameController.text.trim(),
                          content: detailsController.text.trim(),
                          category: selectedCategory?.name ?? "General",
                          dateAdded: date,
                          deadline: date,
                          isFinished: false,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskModal(BuildContext context, TaskItem task) {
    final TextEditingController nameController = TextEditingController(text: task.name);
    final TextEditingController detailsController = TextEditingController(text: task.content);
    
    final categories = _categoryRepository.getAllCategories();
    TaskCategory? selectedCategory;
    if (categories.isNotEmpty) {
      selectedCategory = categories.firstWhere(
        (c) => c.name == task.category,
        orElse: () => categories.first,
      );
    }

    DateTime? selectedDeadline = task.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Edit Task", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Task Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        labelText: "Task Details",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<TaskCategory>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDeadline = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.event, color: Color(0xFF212121)),
                      label: Text(
                        selectedDeadline == null
                            ? "Set Due Date"
                            : "Due: ${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                        style: const TextStyle(color: Color(0xFF212121)),
                      ),
                    ),
                    if (selectedDeadline != null)
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedDeadline = null;
                          });
                        },
                        child: const Text("Remove Due Date", style: TextStyle(color: Colors.red)),
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212121),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      task.name = nameController.text.trim();
                      task.content = detailsController.text.trim();
                      if (selectedCategory != null) {
                        task.category = selectedCategory!.name;
                      }
                      task.deadline = selectedDeadline;
                      _taskRepository.updateTask(task);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar() {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final categories = _categoryRepository.getAllCategories();
        final categoryOptions = ["All", ...categories.map((c) => c.name)];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF424242)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryOptions.map((catName) {
                    final isSelected = _selectedCategoryFilter == catName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(
                          catName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF212121),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF212121),
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF212121) : Colors.black12,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryFilter = catName;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskListView(bool onlyUnfinished) {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        var tasks = _taskRepository.getAllTasks();

        if (onlyUnfinished) {
          tasks = tasks.where((t) => !t.isFinished).toList();
        }

        if (_selectedCategoryFilter != "All") {
          tasks = tasks.where((t) => t.category == _selectedCategoryFilter).toList();
        }

        if (_searchQuery.trim().isNotEmpty) {
          final query = _searchQuery.trim().toLowerCase();
          tasks = tasks.where((t) {
            return t.name.toLowerCase().contains(query) ||
                t.content.toLowerCase().contains(query);
          }).toList();
        }
        
        return Column(
          children: [
            _buildSearchAndFilterBar(),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _searchQuery.isNotEmpty || _selectedCategoryFilter != "All"
                              ? "No matching tasks found."
                              : (onlyUnfinished ? "No pending tasks." : "No tasks found."),
                          style: const TextStyle(fontSize: 16, color: Color(0xFF424242), fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return WidgetTask(
                          task: task,
                          onToggle: (value) {
                            if (value != null) {
                              final updatedTask = task..isFinished = value;
                              _taskRepository.updateTask(updatedTask);
                            }
                          },
                          onDelete: () {
                            _taskRepository.removeTask(task);
                          },
                          onEdit: () {
                            _showEditTaskModal(context, task);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryListView() {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final categories = _categoryRepository.getAllCategories();
        
        if (categories.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "No categories yet.",
                style: TextStyle(fontSize: 16, color: Color(0xFF424242)),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Colors.white.withValues(alpha: 0.92),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.folder_outlined, color: Color(0xFF212121)),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                      onPressed: () => _showEditCategoryModal(context, category),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                      onPressed: () => _categoryRepository.removeCategory(category),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final allTasks = _taskRepository.getAllTasks();

        List<TaskItem> getTasksForDay(DateTime day) {
          return allTasks.where((task) {
            final date = task.deadline ?? task.dateAdded;
            return date.year == day.year &&
                   date.month == day.month &&
                   date.day == day.day;
          }).toList();
        }

        final selectedDayTasks = _selectedDay != null ? getTasksForDay(_selectedDay!) : <TaskItem>[];

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.all(12),
              color: Colors.white.withValues(alpha: 0.93),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: TableCalendar<TaskItem>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: getTasksForDay,
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF212121),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF757575),
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, tasks) {
                    if (tasks.isNotEmpty) {
                      return Positioned(
                        bottom: 2,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF212121),
                          ),
                          width: 6.0,
                          height: 6.0,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              child: selectedDayTasks.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("No tasks scheduled for this day"),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedDayTasks.length,
                      itemBuilder: (context, index) {
                        final task = selectedDayTasks[index];
                        return WidgetTask(
                          task: task,
                          onToggle: (value) {
                            if (value != null) {
                              final updatedTask = task..isFinished = value;
                              _taskRepository.updateTask(updatedTask);
                            }
                          },
                          onDelete: () {
                            _taskRepository.removeTask(task);
                          },
                          onEdit: () {
                            _showEditTaskModal(context, task);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    Widget body;
    
    switch (_currentView) {
      case HomeView.todo:
        title = "To-Do";
        body = _buildTaskListView(true);
        break;
      case HomeView.allTasks:
        title = "All Tasks";
        body = _buildTaskListView(false);
        break;
      case HomeView.categories:
        title = "Categories";
        body = _buildCategoryListView();
        break;
      case HomeView.calendar:
        title = "Calendar";
        body = _buildCalendarView();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF212121)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text("Task Track", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outline_blank),
              title: const Text("To-Do"),
              selected: _currentView == HomeView.todo,
              onTap: () {
                setState(() => _currentView = HomeView.todo);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("All Tasks"),
              selected: _currentView == HomeView.allTasks,
              onTap: () {
                setState(() => _currentView = HomeView.allTasks);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text("Categories"),
              selected: _currentView == HomeView.categories,
              onTap: () {
                setState(() => _currentView = HomeView.categories);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text("Calendar"),
              selected: _currentView == HomeView.calendar,
              onTap: () {
                setState(() => _currentView = HomeView.calendar);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: RotatingGradientBackground(
        child: body,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF212121),
        foregroundColor: Colors.white,
        onPressed: () {
          if (_currentView == HomeView.categories) {
            _showAddCategoryModal(context);
          } else if (_currentView == HomeView.calendar && _selectedDay != null) {
            _showAddTaskModal(context, _selectedDay!);
          } else {
            Navigator.pushNamed(context, '/create');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
