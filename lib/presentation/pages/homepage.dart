import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/core_state.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_category_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../widgets/task_widget.dart';
import '../widgets/rotating_gradient_background.dart';
import '../widgets/custom_progress_gauges.dart';
import '../widgets/task_details_sheet.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';

enum HomeView { dashboard, todo, allTasks, categories, calendar, settings }

class HomePageState extends StatefulWidget {
  const HomePageState({super.key});

  @override
  State<StatefulWidget> createState() => Homepage();
}

class Homepage extends State<HomePageState> {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  HomeView _currentView = HomeView.todo;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategoryFilter = "All";

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  int _weekOffset = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
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
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Add Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Category Name",
              border: OutlineInputBorder(),
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
                if (nameController.text.trim().isNotEmpty) {
                  _categoryRepository.addCategory(
                    TaskCategory(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: nameController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryModal(BuildContext context, TaskCategory category) {
    final TextEditingController nameController = TextEditingController(
      text: category.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Edit Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Category Name",
              border: OutlineInputBorder(),
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
                if (nameController.text.trim().isNotEmpty) {
                  _categoryRepository.updateCategory(
                    TaskCategory(
                      id: category.id,
                      name: nameController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskModal(BuildContext context, DateTime date) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    TaskCategory? selectedCategory;

    final categories = _categoryRepository.getAllCategories();
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Add Task for ${date.day}/${date.month}/${date.year}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Task Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        hintText: "Task Details",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<TaskCategory>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          hintText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCategory = value;
                          });
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: const Text(
                          "No categories yet. This task will be Uncategorized.",
                          style: TextStyle(
                            color: Color(0xFF616161),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
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
                    if (nameController.text.trim().isNotEmpty) {
                      _taskRepository.addTask(
                        TaskItem(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: nameController.text.trim(),
                          content: detailsController.text.trim(),
                          category: selectedCategory?.name ?? "Uncategorized",
                          dateAdded: date,
                          deadline: date,
                          isFinished: false,
                          progress: 40,
                          colorTheme: "lavender",
                        ),
                      );
                      Navigator.pop(context);
                    }
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

  void _showEditTaskModal(BuildContext context, TaskItem task) {
    final TextEditingController nameController = TextEditingController(
      text: task.name,
    );
    final TextEditingController detailsController = TextEditingController(
      text: task.content,
    );

    final categories = _categoryRepository.getAllCategories();
    TaskCategory? selectedCategory;
    if (categories.isNotEmpty) {
      selectedCategory = categories.firstWhere(
        (c) => c.name == task.category,
        orElse: () => categories.first,
      );
    }

    DateTime? selectedDeadline = task.deadline;
    String selectedPriority = task.priority.isNotEmpty
        ? task.priority
        : 'Medium';
    final List<String> priorityOptions = ['Urgent', 'High', 'Medium', 'Low'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: CoreState().themeColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Edit Task Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Task Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Enter task name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Description / Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: detailsController,
                        decoration: InputDecoration(
                          hintText: "Add notes or details...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Category",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (categories.isNotEmpty)
                        DropdownButtonFormField<TaskCategory>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      const SizedBox(height: 16),

                      const Text(
                        "Priority Level",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: priorityOptions.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              selectedPriority = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Due Date",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
                            setModalState(() {
                              selectedDeadline = picked;
                            });
                          }
                        },
                        icon: Icon(Icons.event, color: CoreState().themeColor),
                        label: Text(
                          selectedDeadline == null
                              ? "Set Due Date"
                              : "Due: ${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                          style: TextStyle(
                            color: CoreState().themeColor,
                            fontWeight: FontWeight.w600,
                          ),
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
                    if (nameController.text.trim().isNotEmpty) {
                      task.name = nameController.text.trim();
                      task.content = detailsController.text.trim();
                      if (selectedCategory != null) {
                        task.category = selectedCategory!.name;
                      }
                      task.priority = selectedPriority;
                      task.deadline = selectedDeadline;
                      _taskRepository.updateTask(task);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTopProfileBar() {
    final state = CoreState();
    final userInitial = state.userName.trim().isEmpty
        ? "T"
        : state.userName.trim()[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFEF3C7), width: 2),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFFFB4A2),
              backgroundImage: state.profileImageBytes == null
                  ? null
                  : MemoryImage(state.profileImageBytes!),
              child: state.profileImageBytes == null
                  ? Text(
                      userInitial,
                      style: const TextStyle(
                        color: Color(0xFF212121),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                state.userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E24),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No new notifications"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateWeekSelector() {
    final now = DateTime.now().add(Duration(days: _weekOffset * 7));
    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    final dayName = weekdays[now.weekday - 1];
    final monthName = months[now.month - 1];
    final dateStr = "$dayName, $monthName ${now.day}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _weekOffset--),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _weekOffset == 0
                    ? "This Week"
                    : (_weekOffset > 0
                          ? "In $_weekOffset Weeks"
                          : "${_weekOffset.abs()} Weeks Ago"),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E24),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _weekOffset++),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTaskCard(TaskItem? heroTask) {
    if (heroTask == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD2F8CE),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            TaskDetailsSheet.show(
              context,
              task: heroTask,
              onEdit: () => _showEditTaskModal(context, heroTask),
              onDelete: () => _taskRepository.removeTask(heroTask),
              onUpdate: (updated) => _taskRepository.updateTask(updated),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current tasks",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0x991B381E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          heroTask.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B381E),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          size: 16,
                          color: Color(0xFF1B381E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B381E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_outward,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.trending_up,
                              size: 14,
                              color: Color(0xFF1B381E),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "+12%",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B381E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B381E),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              heroTask.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B381E),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              "UI/UX",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SemiCircleGauge(
                    percentage: heroTask.isFinished
                        ? 100
                        : heroTask.progress.toDouble(),
                    size: 110,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final categories = _categoryRepository.getAllCategories();
        final categoryOptions = ["All", ...categories.map((c) => c.name)];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF424242),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryOptions.map((catName) {
                    final isSelected = _selectedCategoryFilter == catName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(
                          catName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF212121),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1E1E24),
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF1E1E24)
                                : Colors.black12,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryFilter = catName;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskListView(bool onlyUnfinished) {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        var tasks = _taskRepository.getAllTasks();

        if (onlyUnfinished) {
          tasks = tasks.where((t) => !t.isFinished).toList();
        }

        if (_selectedCategoryFilter != "All") {
          tasks = tasks
              .where((t) => t.category == _selectedCategoryFilter)
              .toList();
        }

        if (_searchQuery.trim().isNotEmpty) {
          final query = _searchQuery.trim().toLowerCase();
          tasks = tasks.where((t) {
            return t.name.toLowerCase().contains(query) ||
                t.content.toLowerCase().contains(query);
          }).toList();
        }

        final heroTask = tasks.isNotEmpty ? tasks.first : null;
        final remainingTasks = tasks.length > 1
            ? tasks.sublist(1)
            : <TaskItem>[];

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _buildTopProfileBar(),
            _buildDateWeekSelector(),
            if (heroTask != null) _buildHeroTaskCard(heroTask),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Tasks",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1E24),
                      letterSpacing: -0.4,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentView = HomeView.allTasks;
                      });
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSearchAndFilterBar(),
            const SizedBox(height: 4),
            if (remainingTasks.isEmpty && heroTask == null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "No pending tasks.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              ...remainingTasks.map((task) {
                return WidgetTask(
                  task: task,
                  onToggle: (value) {
                    if (value != null) {
                      final updated = task..isFinished = value;
                      if (value) updated.progress = 100;
                      _taskRepository.updateTask(updated);
                    }
                  },
                  onDelete: () {
                    _confirmDelete(
                      context,
                      "Delete Task",
                      "Are you sure you want to delete this task?",
                      () => _taskRepository.removeTask(task),
                    );
                  },
                  onEdit: () => _showEditTaskModal(context, task),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildCategoryListView() {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final categories = _categoryRepository.getAllCategories();
        final tasks = _taskRepository.getAllTasks();
        final totalTasks = tasks.length;

        if (categories.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CoreState().themeColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.category_outlined,
                        color: CoreState().themeColor,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Create your first category",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Categories you create here will appear in task forms, filters, activity metrics, and calendar views.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF616161),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CoreState().themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _showAddCategoryModal(context),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add Category",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.folder_special_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${categories.length} categor${categories.length == 1 ? 'y' : 'ies'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "$totalTasks task${totalTasks == 1 ? '' : 's'} organized by your own labels",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E1E24),
                        ),
                        icon: const Icon(Icons.add),
                        tooltip: "Add category",
                        onPressed: () => _showAddCategoryModal(context),
                      ),
                    ],
                  ),
                ),
              );
            }

            final categoryIndex = index - 1;
            final category = categories[categoryIndex];
            final categoryTasks = tasks
                .where((task) => task.category == category.name)
                .toList();
            final completed = categoryTasks
                .where((task) => task.isFinished)
                .length;
            final progress = categoryTasks.isEmpty
                ? 0.0
                : completed / categoryTasks.length;
            final accentColors = [
              const Color(0xFF14B8A6),
              const Color(0xFF6366F1),
              const Color(0xFFF59E0B),
              const Color(0xFFEF4444),
              const Color(0xFF22C55E),
            ];
            final accent = accentColors[categoryIndex % accentColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.folder_outlined, color: accent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Color(0xFF1E1E24),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 6,
                                  value: progress,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "$completed/${categoryTasks.length}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blueGrey,
                      size: 20,
                    ),
                    tooltip: "Edit category",
                    onPressed: () => _showEditCategoryModal(context, category),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    tooltip: "Delete category",
                    onPressed: () {
                      _confirmDelete(
                        context,
                        "Delete Category",
                        "Are you sure you want to delete this category? Tasks in this category will become Uncategorized.",
                        () => _categoryRepository.removeCategory(category),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        final allTasks = _taskRepository.getAllTasks();

        List<TaskItem> getTasksForDay(DateTime day) {
          return allTasks.where((task) {
            final date = task.deadline ?? task.dateAdded;
            return date.year == day.year &&
                date.month == day.month &&
                date.day == day.day &&
                !task.isFinished;
          }).toList();
        }

        final selectedDate = _selectedDay ?? DateTime.now();
        final selectedDayTasks = getTasksForDay(selectedDate);
        final overdueTasks = allTasks.where((task) {
          final due = task.deadline;
          if (due == null || task.isFinished) return false;
          final today = DateTime.now();
          return DateTime(
            due.year,
            due.month,
            due.day,
          ).isBefore(DateTime(today.year, today.month, today.day));
        }).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event_available_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedDayTasks.length} task${selectedDayTasks.length == 1 ? '' : 's'} selected",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          overdueTasks == 0
                              ? "Your open schedule is up to date"
                              : "$overdueTasks overdue task${overdueTasks == 1 ? '' : 's'} need attention",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E1E24),
                    ),
                    icon: const Icon(Icons.add_task),
                    tooltip: "Add task for selected date",
                    onPressed: () => _showAddTaskModal(context, selectedDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TableCalendar<TaskItem>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: getTasksForDay,
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1E24),
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: CoreState().themeColor,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: CoreState().themeColor,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w800,
                  ),
                  weekendStyle: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: CoreState().themeColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: CoreState().themeColor.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: CoreState().themeColor,
                    fontWeight: FontWeight.w900,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  defaultTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E24),
                  ),
                  weekendTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, tasks) {
                    if (tasks.isEmpty) return null;
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "${tasks.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Tasks for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (selectedDayTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                child: const Text(
                  "No open tasks on this date.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              ...selectedDayTasks.map((task) {
                return WidgetTask(
                  task: task,
                  onToggle: (value) {
                    if (value != null) {
                      final updated = task..isFinished = value;
                      if (value) updated.progress = 100;
                      _taskRepository.updateTask(updated);
                    }
                  },
                  onDelete: () {
                    _confirmDelete(
                      context,
                      "Delete Task",
                      "Are you sure you want to delete this task?",
                      () => _taskRepository.removeTask(task),
                    );
                  },
                  onEdit: () => _showEditTaskModal(context, task),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildBottomDock() {
    return Positioned(
      bottom: 16,
      left: 20,
      right: 20,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDockIcon(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              isSelected:
                  _currentView == HomeView.todo ||
                  _currentView == HomeView.allTasks,
              onTap: () => setState(() => _currentView = HomeView.todo),
            ),
            _buildDockIcon(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              isSelected: _currentView == HomeView.dashboard,
              onTap: () => setState(() => _currentView = HomeView.dashboard),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/create'),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF1E1E24),
                  size: 24,
                ),
              ),
            ),
            _buildDockIcon(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              isSelected: _currentView == HomeView.calendar,
              onTap: () => setState(() => _currentView = HomeView.calendar),
            ),
            _buildDockIcon(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              isSelected: _currentView == HomeView.settings,
              onTap: () => setState(() => _currentView = HomeView.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockIcon({
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.white : Colors.white54,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CoreState(),
      builder: (context, child) {
        String title;
        Widget body;

        switch (_currentView) {
          case HomeView.dashboard:
            title = "Summary";
            body = const DashboardPage();
            break;
          case HomeView.todo:
            title = "TaskTrack";
            body = _buildTaskListView(true);
            break;
          case HomeView.allTasks:
            title = "All Tasks";
            body = _buildTaskListView(false);
            break;
          case HomeView.categories:
            title = "Categories";
            body = _buildCategoryListView();
            break;
          case HomeView.calendar:
            title = "Calendar";
            body = _buildCalendarView();
            break;
          case HomeView.settings:
            title = "Settings";
            body = SettingsPage();
            break;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: CoreState().themeColor,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_currentView == HomeView.categories)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: "Add Category",
                  onPressed: () => _showAddCategoryModal(context),
                ),
              if (_currentView == HomeView.calendar)
                IconButton(
                  icon: const Icon(Icons.add_task, color: Colors.white),
                  tooltip: "Add Task for Date",
                  onPressed: () => _showAddTaskModal(
                    context,
                    _selectedDay ?? DateTime.now(),
                  ),
                ),
            ],
          ),
          drawer: Drawer(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: CoreState().themeColor,
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Task Track",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.home_outlined),
                        title: const Text("Home Tasks"),
                        selected: _currentView == HomeView.todo,
                        onTap: () {
                          setState(() => _currentView = HomeView.todo);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.bar_chart_outlined),
                        title: const Text("Summary & Activity"),
                        selected: _currentView == HomeView.dashboard,
                        onTap: () {
                          setState(() => _currentView = HomeView.dashboard);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.list),
                        title: const Text("All Tasks"),
                        selected: _currentView == HomeView.allTasks,
                        onTap: () {
                          setState(() => _currentView = HomeView.allTasks);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: const Text("Categories"),
                        selected: _currentView == HomeView.categories,
                        onTap: () {
                          setState(() => _currentView = HomeView.categories);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text("Calendar"),
                        selected: _currentView == HomeView.calendar,
                        onTap: () {
                          setState(() => _currentView = HomeView.calendar);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.settings_outlined,
                        color: CoreState().themeColor,
                      ),
                      title: Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CoreState().themeColor,
                        ),
                      ),
                      selected: _currentView == HomeView.settings,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        setState(() => _currentView = HomeView.settings);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: RotatingGradientBackground(
            child: Stack(children: [body, _buildBottomDock()]),
          ),
        );
      },
    );
  }
}
