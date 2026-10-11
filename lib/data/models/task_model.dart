class TaskItem {
  final int id;
  String name;
  String content;
  String category;
  DateTime dateAdded;
  DateTime? deadline; 
  bool isFinished; 
  String priority; // Added priority string

  TaskItem({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.dateAdded,
    this.deadline,
    this.isFinished = false,
    this.priority = 'Medium',
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
      "priority": priority, // Added to map
    };
  }
}