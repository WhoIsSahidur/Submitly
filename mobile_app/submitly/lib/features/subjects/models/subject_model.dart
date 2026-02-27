class Subject {
  final String id;
  final String name;
  final String? semester;
  final String? color;
  final String userId;

  Subject({
    required this.id,
    required this.name,
    this.semester,
    this.color,
    required this.userId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      semester: json['semester'],
      color: json['color'],
      userId: json['userId'],
    );
  }
}