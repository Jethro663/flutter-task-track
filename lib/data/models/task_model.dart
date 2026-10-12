class TaskItem {
  final int id;
  String name;
  String content;
  String category;
  DateTime dateAdded;
  DateTime? deadline;
  bool isFinished;
  String priority;
  int progress;
  String assignee;
  String colorTheme;
  int participantsCount;

  TaskItem({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.dateAdded,
    this.deadline,
    this.isFinished = false,
    this.priority = 'Medium',
    this.progress = 50,
    this.assignee = '',
    this.colorTheme = 'mint',
    this.participantsCount = 0,
  });

  Map<dynamic, dynamic> get map {
    return {
      "id": id,
      "name": name,
      "content": content,
      "category": category,
      "dateAdded": dateAdded.toIso8601String(),
      "deadline": deadline?.toIso8601String(),
      "isFinished": isFinished,
      "priority": priority,
      "progress": progress,
      "assignee": assignee,
      "colorTheme": colorTheme,
      "participantsCount": participantsCount,
    };
  }
}
