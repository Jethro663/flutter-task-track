import '../models/task_model.dart';
import '../../core/core_state.dart';

class TaskRepository {
  final CoreState _state = CoreState();

  List<TaskItem> getAllTasks() {
    return _state.taskItems;
  }

  void addTask(TaskItem task) {
    _state.addTask(task);
  }

  void removeTask(TaskItem task) {
    _state.removeTask(task);
  }
  
  void updateTask(TaskItem task) {
    _state.updateTask(task);
  }
}