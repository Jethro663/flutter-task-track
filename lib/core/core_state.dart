import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/models/task_model.dart';
import '../data/models/task_category_model.dart';

class CoreState extends ChangeNotifier {
  static final CoreState _coreState = CoreState._internal();
  
  factory CoreState() {
    return _coreState;
  }
  
  CoreState._internal() {
    categories = [
      TaskCategory(id: 1, name: "General"),
      TaskCategory(id: 2, name: "Work"),
      TaskCategory(id: 3, name: "Personal"),
      TaskCategory(id: 4, name: "Finance"),
      TaskCategory(id: 5, name: "Study"),
    ];
  }

  List<TaskItem> taskItems = [];
  
  List<TaskCategory> categories = [];

  // Dagdag para sa Color Palette / Theme
  Color _themeColor = const Color(0xFF212121);

  Color get themeColor => _themeColor;

  void setThemeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }

  void addTask(TaskItem task) {
    taskItems.add(task);
    notifyListeners();
  }

  void removeTask(TaskItem task) {
    taskItems.removeWhere((item) => item.id == task.id);
    notifyListeners();
  }
  
  void updateTask(TaskItem task) {
    final index = taskItems.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      taskItems[index] = task;
      notifyListeners();
    }
  }

  void addCategory(TaskCategory category) {
    categories.add(category);
    notifyListeners();
  }

  void removeCategory(TaskCategory category) {
    categories.removeWhere((item) => item.id == category.id);
    notifyListeners();
  }

  void updateCategory(TaskCategory category) {
    final index = categories.indexWhere((item) => item.id == category.id);
    if (index != -1) {
      categories[index] = category;
      notifyListeners();
    }
  }
}