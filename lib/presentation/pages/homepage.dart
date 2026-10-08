import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/core_state.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_category_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../widgets/task_widget.dart';

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

  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  void _showAddCategoryModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Category"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Category Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
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
              child: Text("Save"),
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
          title: Text("Edit Category"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Category Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
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
              child: Text("Update"),
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
              title: Text("Add Task for ${date.day}/${date.month}/${date.year}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: "Task Name"),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: detailsController,
                      decoration: InputDecoration(hintText: "Task Details"),
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<TaskCategory>(
                        value: selectedCategory,
                        decoration: InputDecoration(hintText: "Category"),
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
                      Text("No categories found. Defaulting to 'General'."),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      _taskRepository.addTask(
                        TaskItem(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: nameController.text.trim(),
                          content: detailsController.text.trim(),
                          category: selectedCategory?.name ?? "General",
                          dateAdded: date,
                          isFinished: false,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
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
        
        if (tasks.isEmpty) {
          return Center(
            child: Text(
              onlyUnfinished ? "All caught up!" : "No tasks yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
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
            );
          },
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
            child: Text(
              "No categories yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              title: Text(category.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditCategoryModal(context, category),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _categoryRepository.removeCategory(category),
                  ),
                ],
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

        // Helper to get tasks for a specific day
        List<TaskItem> _getTasksForDay(DateTime day) {
          return allTasks.where((task) {
            return task.dateAdded.year == day.year &&
                   task.dateAdded.month == day.month &&
                   task.dateAdded.day == day.day;
          }).toList();
        }

        final selectedDayTasks = _selectedDay != null ? _getTasksForDay(_selectedDay!) : <TaskItem>[];

        return Column(
          children: [
            TableCalendar<TaskItem>(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getTasksForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, tasks) {
                  if (tasks.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        width: 7.0,
                        height: 7.0,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: selectedDayTasks.isEmpty
                  ? Center(child: Text("No tasks for this day"))
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
        backgroundColor: Colors.blueGrey,
        title: Text(title, style: TextStyle(color: Colors.amber)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text("Task Track Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.check_box_outline_blank),
              title: Text("To-Do"),
              selected: _currentView == HomeView.todo,
              onTap: () {
                setState(() => _currentView = HomeView.todo);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("All Tasks"),
              selected: _currentView == HomeView.allTasks,
              onTap: () {
                setState(() => _currentView = HomeView.allTasks);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Categories"),
              selected: _currentView == HomeView.categories,
              onTap: () {
                setState(() => _currentView = HomeView.categories);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("Calendar"),
              selected: _currentView == HomeView.calendar,
              onTap: () {
                setState(() => _currentView = HomeView.calendar);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentView == HomeView.categories) {
            _showAddCategoryModal(context);
          } else if (_currentView == HomeView.calendar && _selectedDay != null) {
            _showAddTaskModal(context, _selectedDay!);
          } else {
            Navigator.pushNamed(context, '/create');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}