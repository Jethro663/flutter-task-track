import 'package:flutter/material.dart';
import '../../core/core_state.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_category_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';

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
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void addTask() {
    if (_nameController.text.trim().isEmpty) return;
    
    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      content: _detailsController.text.trim(),
      category: _selectedCategory?.name ?? "General",
      dateAdded: DateTime.now(),
      isFinished: false,
    );
    
    _taskRepository.addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Task name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter task name"
              ),
            ),
            SizedBox(height: 16),
            Text("Task Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter details"
              ),
            ),
            SizedBox(height: 16),
            Text("Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // Listen to CoreState so the dropdown updates when categories are added
            ListenableBuilder(
              listenable: CoreState(),
              builder: (context, child) {
                final categories = _categoryRepository.getAllCategories();
                
                // Ensure _selectedCategory is still valid, else default to null or first
                if (_selectedCategory != null && !categories.any((c) => c.id == _selectedCategory!.id)) {
                  _selectedCategory = null;
                }
                if (_selectedCategory == null && categories.isNotEmpty) {
                  _selectedCategory = categories.first;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<TaskCategory>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
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
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _showAddCategoryModal,
                        icon: Icon(Icons.add),
                        label: Text("Add Category"),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: addTask, 
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16)
              ),
              child: Text("Add Task", style: TextStyle(fontSize: 18))
            )
          ],
        ),
      ),
    );
  }
}