class Assignment {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime dueDate;
  final String subjectName;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.dueDate,
    required this.subjectName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      subjectName: json['subject']['name'],
    );
  }
}