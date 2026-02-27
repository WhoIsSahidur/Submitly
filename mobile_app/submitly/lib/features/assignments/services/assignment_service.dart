import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  Future<List<Assignment>> getAssignments(String userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/assignments?userId=$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Assignment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load assignments');
    }
  }

  Future<void> updateStatus(String id, String status) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/assignments/$id/status');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update status: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> createAssignment({
    required String title,
    String? description,
    required DateTime dueDate,
    required String userId,
    required String subjectId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/assignments');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": title,
        "description": description,
        "dueDate": dueDate.toIso8601String(),
        "userId": userId,
        "subjectId": subjectId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create assignment: ${response.statusCode} ${response.body}',
      );
    }
  }
}
