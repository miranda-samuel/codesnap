import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';
import 'levels/java/level4.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/select_language_screen.dart';
import 'screens/level_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/game_screen.dart';
import 'screens/forgot_password_page.dart';
import 'screens/settings_screen.dart';

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
import 'levels/cpp/level4.dart';
import 'levels/cpp/level5.dart';

import 'levels/php/level1.dart';
import 'levels/php/level2.dart';
import 'levels/php/level3.dart';

import 'levels/sql/level1.dart';
import 'levels/sql/level2.dart';
import 'levels/sql/level3.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // SET ORIENTATION TO PORTRAIT ONLY
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CodeSnapApp());
}

class CodeSnapApp extends StatefulWidget {
  const CodeSnapApp({super.key});

  @override
  State<CodeSnapApp> createState() => _CodeSnapAppState();
}

class _CodeSnapAppState extends State<CodeSnapApp> with WidgetsBindingObserver {
  late MusicService _musicService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _musicService = MusicService();
    print('🎵 App initialized with Music Service');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('💀 APP DISPOSING - KILLING ALL MUSIC');
    _musicService.stopAllMusic();

    // Start music after a short delay to ensure everything is initialized
    Future.delayed(Duration(milliseconds: 500), () {
      _musicService.playBackgroundMusic();
    });

    print('🎵 App initialized with Music Service');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 App Lifecycle State: $state');

    // ULTIMATE MUSIC KILLER - SIMPLE AND EFFECTIVE
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {

      print('🛑 KILLING MUSIC - App going to background');
      _musicService.stopBackgroundMusic();

      // DOUBLE STOP - just to be sure
      Future.delayed(const Duration(milliseconds: 50), () {
        _musicService.stopAllMusic();
      });
    }

    // Optional: Resume music when app comes back (if you want)
    if (state == AppLifecycleState.resumed) {
      print('📱 App returned to foreground');
      // _musicService.resumeBackgroundMusic(); // UNCOMMENT IF YOU WANT AUTO-RESUME
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MusicService>.value(value: _musicService),
      ],
      child: MaterialApp(
        title: 'CodeSnap',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/select_language': (context) => const SelectLanguageScreen(),
          '/levels': (context) => const LevelSelectionScreen(),
          '/game': (context) => const GameScreen(),
          '/forgot_password': (context) => const ForgotPasswordPage(),
          '/settings': (context) => const SettingsScreen(),

          // Python levels
          '/python_level1': (context) => const PythonLevel1(),
          '/python_level2': (context) => const PythonLevel2(),
          '/python_level3': (context) => const PythonLevel3(),

          // Java levels
          '/java_level1': (context) => const JavaLevel1(),
          '/java_level2': (context) => const JavaLevel2(),
          '/java_level3': (context) => const JavaLevel3(),
          '/java_level4': (context) => const JavaLevel4(),

          // C++ levels
          '/cpp_level1': (context) => const CppLevel1(),
          '/cpp_level2': (context) => const CppLevel2(),
          '/cpp_level3': (context) => const CppLevel3(),
          '/cpp_level4': (context) => const CppLevel4(),
          '/cpp_level5': (context) => const CppLevel5(),

          // PHP levels
          '/php_level1': (context) => const PhpLevel1(),
          '/php_level2': (context) => const PhpLevel2(),
          '/php_level3': (context) => const PhpLevel3(),

          // SQL levels
          '/sql_level1': (context) => const SqlLevel1(),
          '/sql_level2': (context) => const SqlLevel2(),
          '/sql_level3': (context) => const SqlLevel3(),
        },
      ),
    );
  }
}