import 'package:flutter/material.dart';
import 'package:hello_world/screens/SelectionLogin_SignUp.dart';
import 'package:hello_world/screens/dashboard.dart';
import 'screens/splash_screen.dart';
import 'constants/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zuno',
      theme: ThemeData(
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const SelectionLogin_SignUp(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
