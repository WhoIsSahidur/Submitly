import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/login_screen.dart';
import 'shared/services/session_service.dart';
import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Check saved session
  final savedUser = await SessionService.getUser();

  runApp(SubmitlyApp(savedUser: savedUser));
}

class SubmitlyApp extends StatelessWidget {
  final Map<String, dynamic>? savedUser;

  const SubmitlyApp({super.key, this.savedUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Submitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: savedUser != null ? const MainNavigation() : const LoginScreen(),
    );
  }
}
