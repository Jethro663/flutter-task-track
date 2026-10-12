import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/models/task_model.dart';
import '../data/models/task_category_model.dart';

class CoreState extends ChangeNotifier {
  static final CoreState _coreState = CoreState._internal();

  factory CoreState() {
    return _coreState;
  }

  CoreState._internal();

  String userName = "TaskTrack User";
  Uint8List? profileImageBytes;

  void setUserName(String name) {
    userName = name.trim().isEmpty ? "Your Name" : name.trim();
    notifyListeners();
  }

  void setProfileImage(Uint8List bytes) {
    profileImageBytes = bytes;
    notifyListeners();
  }

  void clearProfileImage() {
    profileImageBytes = null;
    notifyListeners();
  }

  List<TaskItem> taskItems = [];
  List<TaskCategory> categories = [];

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
    for (final task in taskItems) {
      if (task.category == category.name) {
        task.category = "Uncategorized";
      }
    }
    notifyListeners();
  }

  void updateCategory(TaskCategory category) {
    final index = categories.indexWhere((item) => item.id == category.id);
    if (index != -1) {
      final oldName = categories[index].name;
      categories[index] = category;
      for (final task in taskItems) {
        if (task.category == oldName) {
          task.category = category.name;
        }
      }
      notifyListeners();
    }
  }
}
