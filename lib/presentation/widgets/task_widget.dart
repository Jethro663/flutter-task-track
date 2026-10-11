import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class WidgetTask extends StatelessWidget {
  final TaskItem task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WidgetTask({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  // Helper function for priority colors
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
      default:
        return Colors.teal.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withValues(alpha: 0.92),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Checkbox(
              value: task.isFinished,
              activeColor: const Color(0xFF212121),
              onChanged: onToggle,
            ),
            title: Text(
              task.name,
              style: TextStyle(
                decoration: task.isFinished ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w600,
                color: task.isFinished ? Colors.black45 : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.content.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.content,
                    style: TextStyle(
                      color: task.isFinished ? Colors.black38 : Colors.black87,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212121).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    // Color-Coded Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getPriorityColor(task.priority).withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                    // Deadline Tag
                    if (task.deadline != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey.shade200, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event, size: 12, color: Colors.blueGrey.shade700),
                            const SizedBox(width: 4),
                            Text(
                              "${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}",
                              style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF424242)),
                  tooltip: "Edit task",
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                  tooltip: "Delete task",
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}