import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class SubjectService {
  Future<List<Map<String, dynamic>>> getSubjects(String userId) async {
    try {
      final response = await ApiService.get(
        '/subjects',
        queryParams: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createSubject({
    required String name,
    required String userId,
    String? semester,
    String? color,
  }) async {
    try {
      final response = await ApiService.post(
        '/subjects',
        body: {
          'name': name,
          'userId': userId,
          if (semester != null) 'semester': semester,
          if (color != null) 'color': color,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('Failed to create subject: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating subject: $e');
      return null;
    }
  }
}
