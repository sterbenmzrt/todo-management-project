class Task {
  final int id;
  final String title;
  final String description;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        status: json["status"],
      );
}