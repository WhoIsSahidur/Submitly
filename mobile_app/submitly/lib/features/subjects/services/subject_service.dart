import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/subject_model.dart';

class SubjectService {
  Future<List<Subject>> getSubjects(String userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/subjects?userId=$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Subject.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<void> addSubject({
    required String name,
    required String semester,
    required String color,
    required String userId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/subjects');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "semester": semester,
        "color": color,
        "userId": userId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create subject: ${response.statusCode} ${response.body}',
      );
    }
  }
}
