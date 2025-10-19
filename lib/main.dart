import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';
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
import 'levels/python/level4.dart';
import 'levels/python/level5.dart';
import 'levels/python/level6.dart';
import 'levels/python/level7.dart';
import 'levels/python/level8.dart';
import 'levels/python/level9.dart';
import 'levels/python/level10.dart';

import 'levels/java/level1.dart';
import 'levels/java/level2.dart';
import 'levels/java/level3.dart';
import 'levels/java/level4.dart';
import 'levels/java/level5.dart';
import 'levels/java/level6.dart';
import 'levels/java/level7.dart';
import 'levels/java/level8.dart';
import 'levels/java/level9.dart';
import 'levels/java/level10.dart';

import 'levels/cpp/level1.dart';
import 'levels/cpp/level2.dart';
import 'levels/cpp/level3.dart';
import 'levels/cpp/level4.dart';
import 'levels/cpp/level5.dart';
import 'levels/cpp/level6.dart';
import 'levels/cpp/level7.dart';
import 'levels/cpp/level8.dart';
import 'levels/cpp/level9.dart';
import 'levels/cpp/level10.dart';

import 'levels/php/level1.dart';
import 'levels/php/level2.dart';
import 'levels/php/level3.dart';
import 'levels/php/level4.dart';
import 'levels/php/level5.dart';
import 'levels/php/level6.dart';
import 'levels/php/level7.dart';
import 'levels/php/level8.dart';
import 'levels/php/level9.dart';
import 'levels/php/level10.dart';

import 'levels/sql/level1.dart';
import 'levels/sql/level2.dart';
import 'levels/sql/level3.dart';
import 'levels/sql/level4.dart';
import 'levels/sql/level5.dart';
import 'levels/sql/level6.dart';
import 'levels/sql/level7.dart';
import 'levels/sql/level8.dart';
import 'levels/sql/level9.dart';
import 'levels/sql/level10.dart';

// Import new module screens
import 'screens/php_modules_screen.dart';
import 'screens/cpp_modules_screen.dart';
import 'screens/python_modules_screen.dart';
import 'screens/java_modules_screen.dart';
import 'screens/sql_modules_screen.dart';

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

    // Start music after a short delay to ensure everything is initialized
    Future.delayed(Duration(milliseconds: 500), () {
      _musicService.playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    print('💀 APP DISPOSING - KILLING ALL MUSIC');
    _musicService.stopAllMusic();
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
        initialRoute: '/',
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

          // NEW: Programming Modules Screens
          '/php_modules': (context) => const PhpModulesScreen(),
          '/cpp_modules': (context) => const CppModulesScreen(),
          '/python_modules': (context) => const PythonModulesScreen(),
          '/java_modules': (context) => const JavaModulesScreen(),
          '/sql_modules': (context) => const SqlModulesScreen(),

          // Python levels
          '/python_level1': (context) => const PythonLevel1(),
          '/python_level2': (context) => const PythonLevel2(),
          '/python_level3': (context) => const PythonLevel3(),
          '/python_level4': (context) => const PythonLevel4(),
          '/python_level5': (context) => const PythonLevel5(),
          '/python_level6': (context) => const PythonLevel6(),
          '/python_level7': (context) => const PythonLevel7(),
          '/python_level8': (context) => const PythonLevel8(),
          '/python_level9': (context) => const PythonLevel9(),
          '/python_level10': (context) => const PythonLevel10(),

          // Java levels
          '/java_level1': (context) => const JavaLevel1(),
          '/java_level2': (context) => const JavaLevel2(),
          '/java_level3': (context) => const JavaLevel3(),
          '/java_level4': (context) => const JavaLevel4(),
          '/java_level5': (context) => const JavaLevel5(),
          '/java_level6': (context) => const JavaLevel6(),
          '/java_level7': (context) => const JavaLevel7(),
          '/java_level8': (context) => const JavaLevel8(),
          '/java_level9': (context) => const JavaLevel9(),
          '/java_level10': (context) => const JavaLevel10(),

          // C++ levels
          '/cpp_level1': (context) => const CppLevel1(),
          '/cpp_level2': (context) => const CppLevel2(),
          '/cpp_level3': (context) => const CppLevel3(),
          '/cpp_level4': (context) => const CppLevel4(),
          '/cpp_level5': (context) => const CppLevel5(),
          '/cpp_level6': (context) => const CppLevel6(),
          '/cpp_level7': (context) => const CppLevel7(),
          '/cpp_level8': (context) => const CppLevel8(),
          '/cpp_level9': (context) => const CppLevel9(),
          '/cpp_level10': (context) => const CppLevel10(),

          // PHP levels
          '/php_level1': (context) => const PhpLevel1(),
          '/php_level2': (context) => const PhpLevel2(),
          '/php_level3': (context) => const PhpLevel3(),
          '/php_level4': (context) => const PhpLevel4(),
          '/php_level5': (context) => const PhpLevel5(),
          '/php_level6': (context) => const PhpLevel6(),
          '/php_level7': (context) => const PhpLevel7(),
          '/php_level8': (context) => const PhpLevel8(),
          '/php_level9': (context) => const PhpLevel9(),
          '/php_level10': (context) => const PhpLevel10(),

          // SQL levels
          '/sql_level1': (context) => const SqlLevel1(),
          '/sql_level2': (context) => const SqlLevel2(),
          '/sql_level3': (context) => const SqlLevel3(),
          '/sql_level4': (context) => const SqlLevel4(),
          '/sql_level5': (context) => const SqlLevel5(),
          '/sql_level6': (context) => const SqlLevel6(),
          '/sql_level7': (context) => const SqlLevel7(),
          '/sql_level8': (context) => const SqlLevel8(),
          '/sql_level9': (context) => const SqlLevel9(),
          '/sql_level10': (context) => const SqlLevel10(),
        },
      ),
    );
  }
}