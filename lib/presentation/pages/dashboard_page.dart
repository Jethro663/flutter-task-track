import 'package:flutter/material.dart';
import '../../core/core_state.dart';
import '../../data/repositories/task_repository.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final TaskRepository _taskRepository = TaskRepository();

  // Helper function for priority colors
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade800;
      case 'medium':
        return Colors.blue.shade700;
      case 'low':
      default:
        return Colors.teal.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final tasks = _taskRepository.getAllTasks();

        final int totalTasks = tasks.length;
        final int completedTasks = tasks.where((t) => t.isFinished).length;
        final int pendingTasks = tasks.where((t) => !t.isFinished).length;
        final double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
        
        // Priority breakdowns
        final int urgentTasks = tasks.where((t) => !t.isFinished && t.priority.toLowerCase() == 'urgent').length;
        final int highTasks = tasks.where((t) => !t.isFinished && t.priority.toLowerCase() == 'high').length;

        // Filter pending tasks to show upcoming ones
        final pendingList = tasks.where((t) => !t.isFinished).toList();
        final displayListCount = pendingList.length > 5 ? 5 : pendingList.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Productivity Overview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Visual Progress Card
                      Container(
                        width: double.infinity,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Overall Completion',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF424242)),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.black12,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212121)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Total', totalTasks.toString()),
                                _buildStatItem('Pending', pendingTasks.toString()),
                                _buildStatItem('Done', completedTasks.toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Priority Focus Cards
                      const Text(
                        'Priority Focus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200, width: 0.8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Urgent Pending', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Text('$urgentTasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200, width: 0.8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('High Priority', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Text('$highTasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Pending Tasks Section
                      const Text(
                        'Recent Pending Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 12),
                      pendingList.isEmpty
                          ? Container(
                              width: double.infinity,
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
                              child: const Text(
                                'No pending tasks. Great job!',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            )
                          : Container(
                              width: double.infinity,
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
                                children: List.generate(displayListCount, (index) {
                                  final task = pendingList[index];
                                  final priorityColor = _getPriorityColor(task.priority);
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                task.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF212121),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: priorityColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: priorityColor.withValues(alpha: 0.4),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                task.priority,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: priorityColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (index < displayListCount - 1)
                                        const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
                                    ],
                                  );
                                }),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
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
}