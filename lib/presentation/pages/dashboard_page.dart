import 'package:flutter/material.dart';
import '../../core/core_state.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  String _selectedCategoryFilter = "All";
  String _sortBy = "Closest"; 

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red.shade600;
      case 'high':
        return Colors.orange.shade800;
      case 'medium':
        return Colors.blue.shade700;
      case 'low':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _showTaskDetailsModal(BuildContext context, TaskItem task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.assignment_outlined, color: CoreState().themeColor, size: 28),
              const SizedBox(width: 10),
              const Text(
                "Task Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getPriorityColor(task.priority)),
                ),
                child: Text(
                  task.priority.isNotEmpty ? task.priority : 'Medium',
                  style: TextStyle(
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500, 
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Task Name",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF424242)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      task.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Description / Details",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF424242)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    constraints: const BoxConstraints(minHeight: 80),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      task.content.isNotEmpty ? task.content : "No details provided.",
                      style: const TextStyle(fontSize: 14, color: Color(0xFF212121), height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Category",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF424242)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                task.category,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF424242)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: task.isFinished ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: task.isFinished ? Colors.green.shade300 : Colors.orange.shade300),
                              ),
                              child: Text(
                                task.isFinished ? "Completed" : "Pending",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: task.isFinished ? Colors.green.shade800 : Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Due Date & Schedule",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF424242)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: CoreState().themeColor, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          task.deadline != null
                              ? "${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}"
                              : "No due date set",
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CoreState().themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
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
        final allTasks = _taskRepository.getAllTasks();
        final categories = _categoryRepository.getAllCategories();
        final categoryOptions = ["All", ...categories.map((c) => c.name)];

        final int totalTasks = allTasks.length;
        final int completedTasks = allTasks.where((t) => t.isFinished).length;
        final int pendingTasks = allTasks.where((t) => !t.isFinished).length;
        final int urgentPending = allTasks.where((t) => !t.isFinished && t.priority.toLowerCase() == 'urgent').length;
        final int highPending = allTasks.where((t) => !t.isFinished && t.priority.toLowerCase() == 'high').length;

        var recentTasks = allTasks.where((t) => !t.isFinished).toList();
        if (_selectedCategoryFilter != "All") {
          recentTasks = recentTasks.where((t) => t.category == _selectedCategoryFilter).toList();
        }

        if (_sortBy == "Closest") {
          recentTasks.sort((a, b) => (a.deadline ?? a.dateAdded).compareTo(b.deadline ?? b.dateAdded));
        } else if (_sortBy == "Furthest") {
          recentTasks.sort((a, b) => (b.deadline ?? b.dateAdded).compareTo(a.deadline ?? a.dateAdded));
        } else {
          int getPriorityWeight(String p) {
            switch (p.toLowerCase()) {
              case 'urgent': return 1;
              case 'high': return 2;
              case 'medium': return 3;
              case 'low': return 4;
              default: return 5;
            }
          }
          recentTasks.sort((a, b) => getPriorityWeight(a.priority).compareTo(getPriorityWeight(b.priority)));
        }

        return ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              "Productivity Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
            ),
            const SizedBox(height: 12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Overall Completion", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                      Text(
                        totalTasks > 0 ? "${((completedTasks / totalTasks) * 100).toStringAsFixed(0)}%" : "0%",
                        style: TextStyle(fontWeight: FontWeight.bold, color: CoreState().themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalTasks > 0 ? completedTasks / totalTasks : 0.0,
                      backgroundColor: Colors.grey.shade200,
                      color: CoreState().themeColor,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Total", totalTasks.toString()),
                      _buildStatItem("Pending", pendingTasks.toString()),
                      _buildStatItem("Done", completedTasks.toString()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Priority Focus",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Urgent Pending", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          urgentPending.toString(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("High Priority", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          highPending.toString(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Pending Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort, size: 16),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                    items: const [
                      DropdownMenuItem(value: "Closest", child: Text("Due: Closest")),
                      DropdownMenuItem(value: "Furthest", child: Text("Due: Furthest")),
                      DropdownMenuItem(value: "Priority", child: Text("Priority")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryOptions.map((cat) {
                  final isSelected = _selectedCategoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: CoreState().themeColor,
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF212121),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() => _selectedCategoryFilter = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            recentTasks.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text("No pending tasks found.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTasks.length > 5 ? 5 : recentTasks.length,
                    itemBuilder: (context, index) {
                      final task = recentTasks[index];
                      final pColor = _getPriorityColor(task.priority);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () => _showTaskDetailsModal(context, task),
                          title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            task.deadline != null
                                ? "Due: ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}"
                                : "No due date",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: pColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              task.priority.isNotEmpty ? task.priority : 'Medium',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: pColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}