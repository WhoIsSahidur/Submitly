import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  static bool _initialized = false;

  // Web client ID from google-services.json (client_type: 3)
  static const String _serverClientId =
      '924059171872-j36791ddc76vj6toqo5vaptvoj7m0jm1.apps.googleusercontent.com';

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
      );
      _initialized = true;
    }
  }

  /// Sign in with Google and send user to backend.
  /// Returns user map on success, or throws on failure.
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      final account = await GoogleSignIn.instance.authenticate();
      final email = account.email;
      final name = account.displayName ?? '';

      // Send to backend
      final url = Uri.parse('${ApiConstants.baseUrl}/users/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = jsonDecode(response.body) as Map<String, dynamic>;

        // Save session locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user['id']);

        return user;
      }

      throw 'Backend error ${response.statusCode}: ${response.body}';
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In failed: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Get saved userId from local storage.
  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Sign out: clear local session and Google session.
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}