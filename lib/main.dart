import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // ADD THIS IMPORT
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/select_language_screen.dart';
import 'screens/level_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/game_screen.dart';
import 'screens/forgot_password_page.dart';

// Import per-language level screens
import 'levels/python/level1.dart';
import 'levels/python/level2.dart';
import 'levels/python/level3.dart';

import 'levels/java/level1.dart';
import 'levels/java/level2.dart';
import 'levels/java/level3.dart';

import 'levels/cpp/level1.dart';
import 'levels/cpp/level2.dart';
import 'levels/cpp/level3.dart';

import 'levels/php/level1.dart';
import 'levels/php/level2.dart';
import 'levels/php/level3.dart';

import 'levels/sql/level1.dart';
import 'levels/sql/level2.dart';
import 'levels/sql/level3.dart';

void main() {
  runApp(const CodeSnapApp());
}

class CodeSnapApp extends StatelessWidget {
  const CodeSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeSnap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      initialRoute: '/splash', // CHANGE INITIAL ROUTE
      routes: {
        '/splash': (context) => const SplashScreen(), // ADD SPLASH SCREEN ROUTE
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/select_language': (context) => const SelectLanguageScreen(),
        '/levels': (context) => const LevelSelectionScreen(),
        '/game': (context) => const GameScreen(),
        '/forgot_password': (context) => const ForgotPasswordPage(),

        // Python levels
        '/python_level1': (context) => const PythonLevel1(),
        '/python_level2': (context) => const PythonLevel2(),
        '/python_level3': (context) => const PythonLevel3(),

        // Java levels
        '/java_level1': (context) => const JavaLevel1(),
        '/java_level2': (context) => const JavaLevel2(),
        '/java_level3': (context) => const JavaLevel3(),

        // C++ levels
        '/cpp_level1': (context) => const CppLevel1(),
        '/cpp_level2': (context) => const CppLevel2(),
        '/cpp_level3': (context) => const CppLevel3(),

        // PHP levels
        '/php_level1': (context) => const PhpLevel1(),
        '/php_level2': (context) => const PhpLevel2(),
        '/php_level3': (context) => const PhpLevel3(),

        // SQL levels
        '/sql_level1': (context) => const SqlLevel1(),
        '/sql_level2': (context) => const SqlLevel2(),
        '/sql_level3': (context) => const SqlLevel3(),
      },
    );
  }
}
