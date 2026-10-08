import '../../core/core_state.dart';
import '../models/task_category_model.dart';

class CategoryRepository {
  final CoreState _state = CoreState();

  List<TaskCategory> getAllCategories() {
    return _state.categories;
  }

  void addCategory(TaskCategory category) {
    _state.addCategory(category);
  }

  void removeCategory(TaskCategory category) {
    _state.removeCategory(category);
  }

  void updateCategory(TaskCategory category) {
    _state.updateCategory(category);
  }
}
