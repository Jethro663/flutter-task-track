import 'package:flutter/material.dart';
import '../../core/core_state.dart';
import '../../data/models/task_category_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../widgets/custom_progress_gauges.dart';
import '../widgets/task_details_sheet.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  String _selectedCategoryFilter = "All";

  void _confirmDelete(BuildContext context, TaskItem task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Task",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Delete \"${task.name}\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _taskRepository.removeTask(task);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskModal(BuildContext context, TaskItem task) {
    final nameController = TextEditingController(text: task.name);
    final detailsController = TextEditingController(text: task.content);
    final categories = _categoryRepository.getAllCategories();
    TaskCategory? selectedCategory = categories
        .where((category) => category.name == task.category)
        .firstOrNull;
    DateTime? selectedDeadline = task.deadline;
    String selectedPriority = task.priority.isEmpty ? "Medium" : task.priority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                "Edit Task",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Task name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Details",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: InputDecoration(
                          labelText: "Priority",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const ["Urgent", "High", "Medium", "Low"]
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedPriority = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (categories.isNotEmpty)
                        DropdownButtonFormField<TaskCategory>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: "Category",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setModalState(() => selectedCategory = value),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDeadline ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDeadline = picked);
                          }
                        },
                        icon: const Icon(Icons.event_outlined),
                        label: Text(
                          selectedDeadline == null
                              ? "Set due date"
                              : "Due ${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoreState().themeColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    task
                      ..name = nameController.text.trim()
                      ..content = detailsController.text.trim()
                      ..priority = selectedPriority
                      ..deadline = selectedDeadline
                      ..category = selectedCategory?.name ?? task.category;
                    _taskRepository.updateTask(task);
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
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
        final int inProgressTasks = allTasks
            .where((t) => !t.isFinished && t.progress > 0)
            .length;
        final int onHoldTasks = allTasks
            .where((t) => !t.isFinished && t.progress == 0)
            .length;

        final double completedPercent = totalTasks == 0
            ? 0.0
            : (completedTasks / totalTasks) * 100.0;
        final double inProgressPercent = totalTasks == 0
            ? 0.0
            : (inProgressTasks / totalTasks) * 100.0;
        final double onHoldPercent = totalTasks == 0
            ? 0.0
            : (onHoldTasks / totalTasks) * 100.0;

        final List<double> weekdayCounts = List.generate(7, (i) {
          final int weekday = i + 1;
          return allTasks
              .where((t) => t.dateAdded.weekday == weekday)
              .length
              .toDouble();
        });
        final double maxCount = weekdayCounts.reduce((a, b) => a > b ? a : b);
        final List<double> normalizedHeights = maxCount == 0
            ? List.filled(7, 0.05)
            : weekdayCounts
                  .map((h) => (h / maxCount).clamp(0.05, 1.0))
                  .toList();

        final String activitySubtitle = totalTasks == 0
            ? "No tasks yet"
            : "$totalTasks task${totalTasks == 1 ? '' : 's'} this session";

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD2F8CE),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Task Activity",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B381E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activitySubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0x991B381E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B381E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_outward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InteractiveWeeklyBarChart(dayHeights: normalizedHeights),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2D9FC),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$totalTasks",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E1065),
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Total Tasks",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0x992E1065),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completedTasks.toString(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF451A03),
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Tasks Done",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0x99451A03),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                        "Task Overview",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1E24),
                          letterSpacing: -0.4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1E24),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_outward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Productivity Completion",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${completedPercent.toInt()}% completed",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MultiSegmentProgressBar(
                    completedPercent: completedPercent,
                    inProgressPercent: inProgressPercent,
                    onHoldPercent: onHoldPercent,
                  ),
                  const SizedBox(height: 18),
                  _buildLegendRow(
                    color: const Color(0xFF48BB78),
                    label: "Completed",
                    percent: "${completedPercent.toInt()}%",
                    count: "$completedTasks tasks",
                  ),
                  const Divider(height: 16, thickness: 0.6),
                  _buildLegendRow(
                    color: const Color(0xFF9F7AEA),
                    label: "In Progress",
                    percent: "${inProgressPercent.toInt()}%",
                    count: "$inProgressTasks tasks",
                  ),
                  const Divider(height: 16, thickness: 0.6),
                  _buildLegendRow(
                    color: const Color(0xFFECC94B),
                    label: "On Hold",
                    percent: "${onHoldPercent.toInt()}%",
                    count: "$onHoldTasks tasks",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Priority Tasks",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1E24),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categoryOptions.take(4).map((cat) {
                      final isSelected = _selectedCategoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E1E24),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1E1E24),
                          backgroundColor: Colors.white.withValues(alpha: 0.8),
                          onSelected: (val) {
                            setState(() => _selectedCategoryFilter = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...allTasks
                .where(
                  (t) =>
                      _selectedCategoryFilter == "All" ||
                      t.category == _selectedCategoryFilter,
                )
                .take(3)
                .map((task) {
                  final subtitle = task.assignee.trim().isEmpty
                      ? task.category
                      : "${task.category} - ${task.assignee}";
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withValues(alpha: 0.94),
                    child: ListTile(
                      onTap: () {
                        TaskDetailsSheet.show(
                          context,
                          task: task,
                          onEdit: () => _showEditTaskModal(context, task),
                          onDelete: () => _confirmDelete(context, task),
                          onUpdate: (t) => _taskRepository.updateTask(t),
                        );
                      },
                      leading: CircularProgressBadge(
                        percentage: task.isFinished
                            ? 100
                            : task.progress.toDouble(),
                        size: 38,
                        activeColor: const Color(0xFF1E1E24),
                        trackColor: Colors.black12,
                        textColor: const Color(0xFF1E1E24),
                      ),
                      title: Text(
                        task.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.black45,
                      ),
                    ),
                  );
                }),
          ],
        );
      },
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required String percent,
    required String count,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E24),
          ),
        ),
        const Spacer(),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            percent,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E24),
            ),
          ),
        ),
      ],
    );
  }
}
