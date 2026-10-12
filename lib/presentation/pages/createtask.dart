import 'package:flutter/material.dart';
import '../../core/core_state.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_category_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../widgets/rotating_gradient_background.dart';

class CreateTaskState extends StatefulWidget {
  const CreateTaskState({super.key});

  @override
  State<StatefulWidget> createState() => CreateTaskPage();
}

class CreateTaskPage extends State<CreateTaskState> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  TaskCategory? _selectedCategory;
  DateTime? _selectedDeadline;
  String _selectedPriority = 'Medium';
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _showAddCategoryModal() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Add Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                  final newCategory = TaskCategory(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: nameController.text.trim(),
                  );
                  _categoryRepository.addCategory(newCategory);

                  setState(() {
                    _selectedCategory = newCategory;
                  });

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

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void addTask() {
    if (_nameController.text.trim().isEmpty) return;

    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      content: _detailsController.text.trim(),
      category: _selectedCategory?.name ?? "Uncategorized",
      dateAdded: DateTime.now(),
      deadline: _selectedDeadline,
      isFinished: false,
      priority: _selectedPriority,
      progress: 0,
      colorTheme: (DateTime.now().millisecond % 3 == 0)
          ? 'mint'
          : (DateTime.now().millisecond % 3 == 1 ? 'lavender' : 'yellow'),
    );

    _taskRepository.addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Task",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RotatingGradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              color: Colors.white.withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Task Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter task name",
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Task Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter details (optional)",
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: CoreState(),
                      builder: (context, child) {
                        final categories = _categoryRepository
                            .getAllCategories();

                        if (_selectedCategory != null &&
                            !categories.any(
                              (c) => c.id == _selectedCategory!.id,
                            )) {
                          _selectedCategory = null;
                        }
                        if (_selectedCategory == null &&
                            categories.isNotEmpty) {
                          _selectedCategory = categories.first;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (categories.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: const Text(
                                  "No categories yet. This task will be Uncategorized.",
                                  style: TextStyle(
                                    color: Color(0xFF616161),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              DropdownButtonFormField<TaskCategory>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _showAddCategoryModal,
                                icon: const Icon(
                                  Icons.add,
                                  color: Color(0xFF212121),
                                ),
                                label: const Text(
                                  "Add New Category",
                                  style: TextStyle(
                                    color: Color(0xFF212121),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Priority",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _priorities.map((String priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Deadline (Optional)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _pickDeadline,
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF212121),
                            ),
                            label: Text(
                              _selectedDeadline == null
                                  ? "Choose Deadline Date"
                                  : "${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}",
                              style: const TextStyle(color: Color(0xFF212121)),
                            ),
                          ),
                        ),
                        if (_selectedDeadline != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            tooltip: "Clear deadline",
                            onPressed: () =>
                                setState(() => _selectedDeadline = null),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212121),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Add Task",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
