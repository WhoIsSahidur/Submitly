import 'dart:io' show Platform;

class ApiConstants {
  // Set to true when testing on a physical device,
  // false when using the Android emulator.
  static const bool usePhysicalDevice = true;

  // Your computer's Wi-Fi IP (run `ipconfig` to find it).
  // Update this if your IP changes.
  static const String _lanIp = '10.96.146.128';

  static String get baseUrl {
    if (Platform.isAndroid) {
      return usePhysicalDevice
          ? 'http://$_lanIp:3000'
          : 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}