import 'dart:io' show Platform;

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.247.215.128";
    }
    return "http://localhost:3000";
  }
}