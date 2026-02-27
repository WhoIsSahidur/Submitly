import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class UserService {
  Future<Map<String, dynamic>?> createUser(String name, String email) async {
    try {
      final response = await ApiService.post(
        '/users',
        body: {'name': name, 'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('Failed to create user: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> findByEmail(String email) async {
    try {
      final response = await ApiService.get(
        '/users',
        queryParams: {'email': email},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        if (body != null && body is Map<String, dynamic>) {
          return body;
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Error finding user: $e');
      return null;
    }
  }

  /// Get or create a user by email. Returns the user map.
  Future<Map<String, dynamic>?> getOrCreateUser(
    String name,
    String email,
  ) async {
    final existing = await findByEmail(email);
    if (existing != null) return existing;
    return createUser(name, email);
  }
}
