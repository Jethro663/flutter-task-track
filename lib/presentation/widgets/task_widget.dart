import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'custom_progress_gauges.dart';
import 'task_details_sheet.dart';

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

  Color _getCardBackgroundColor() {
    switch (task.colorTheme.toLowerCase()) {
      case 'mint':
        return const Color(0xFFD4F8CE);
      case 'lavender':
        return const Color(0xFFE2D9FC);
      case 'yellow':
        return const Color(0xFFFEF3C7);
      case 'coral':
        return const Color(0xFFFFDDD2);
      default:
        final hash = task.id.abs() % 3;
        if (hash == 0) return const Color(0xFFE2D9FC);
        if (hash == 1) return const Color(0xFFFEF3C7);
        return const Color(0xFFD4F8CE);
    }
  }

  Color _getTextColor() {
    switch (task.colorTheme.toLowerCase()) {
      case 'mint':
        return const Color(0xFF1B381E);
      case 'lavender':
        return const Color(0xFF2E1065);
      case 'yellow':
        return const Color(0xFF451A03);
      case 'coral':
        return const Color(0xFF4C0519);
      default:
        return const Color(0xFF1E1E24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCardBackgroundColor();
    final textColor = _getTextColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            TaskDetailsSheet.show(
              context,
              task: task,
              onEdit: onEdit,
              onDelete: onDelete,
              onUpdate: (updatedTask) {
                TaskRepository().updateTask(updatedTask);
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.isFinished,
                    activeColor: textColor,
                    checkColor: bgColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: BorderSide(color: textColor.withValues(alpha: 0.5), width: 1.8),
                    onChanged: onToggle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.isFinished ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: task.isFinished ? textColor.withValues(alpha: 0.5) : textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (task.content.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          task.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: task.isFinished
                                ? textColor.withValues(alpha: 0.4)
                                : textColor.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          AvatarStack(count: task.participantsCount, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "${task.participantsCount} participants",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircularProgressBadge(
                  percentage: task.isFinished ? 100 : task.progress.toDouble(),
                  size: 50,
                  activeColor: textColor,
                  trackColor: textColor.withValues(alpha: 0.2),
                  textColor: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}