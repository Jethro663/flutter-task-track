import 'package:flutter/material.dart';
import '../../core/core_state.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  void _showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CoreState().themeColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _confirmDeleteAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete All Data", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: const Text("Are you sure you want to delete all tasks and categories? This action is permanent and cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final allTasks = _taskRepository.getAllTasks();
                for (var task in List.from(allTasks)) {
                  _taskRepository.removeTask(task);
                }
                
                final allCategories = _categoryRepository.getAllCategories();
                for (var cat in List.from(allCategories)) {
                  _categoryRepository.removeCategory(cat);
                }

                Navigator.pop(context);
                _showTopSnackBar(context, "All data has been successfully deleted.");
              },
              child: const Text("Delete Everything"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final tasks = _taskRepository.getAllTasks();
        final categories = _categoryRepository.getAllCategories();

        final int totalTasks = tasks.length;
        final int completedTasks = tasks.where((t) => t.isFinished).length;
        final int pendingTasks = tasks.where((t) => !t.isFinished).length;

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'User Profile & History Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),

            // Profile & Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: CoreState().themeColor,
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Productivity User",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "TaskTrack Active Member",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const Divider(height: 32, thickness: 0.8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat("Total", totalTasks.toString()),
                      _buildProfileStat("Completed", completedTasks.toString()),
                      _buildProfileStat("Pending", pendingTasks.toString()),
                      _buildProfileStat("Categories", categories.length.toString()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Color Palette Selection Section
            const Text(
              'Appearance & Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Color Palette",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Choose your preferred accent theme color for the app interface.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildColorOption(context, "Classic Dark", const Color(0xFF212121)),
                      _buildColorOption(context, "Ocean Blue", const Color(0xFF1565C0)),
                      _buildColorOption(context, "Emerald", const Color(0xFF2E7D32)),
                      _buildColorOption(context, "Sunset", const Color(0xFFD84315)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Data Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),

            // Danger Zone / Delete All Data Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Danger Zone",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Permanently delete all tasks, categories, and reset your history statistics.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Delete All Data", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _confirmDeleteAllData(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildColorOption(BuildContext context, String name, Color color) {
    final isSelected = CoreState().themeColor.value == color.value;

    return InkWell(
      onTap: () {
        CoreState().setThemeColor(color);
        _showTopSnackBar(context, "Theme updated to $name!");
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: isSelected ? 6 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 22) : null,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
              color: const Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }
}