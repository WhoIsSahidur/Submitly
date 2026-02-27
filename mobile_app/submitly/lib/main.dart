import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'shared/services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check for saved session
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: savedUser != null
          ? DashboardScreen(user: savedUser!)
          : const LoginScreen(),
    );
  }
}