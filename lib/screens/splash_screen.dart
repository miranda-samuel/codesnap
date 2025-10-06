import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart'; // ADD THIS IMPORT
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: const Color(0xFF2193b0),
      end: const Color(0xFF6dd5ed),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // START BACKGROUND MUSIC AND NAVIGATE
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start background music
    final musicService = Provider.of<MusicService>(context, listen: false);
    await musicService.playBackgroundMusic();

    // Navigate after delay
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorAnimation.value!,
                  const Color(0xFF1e3c72),
                  const Color(0xFF2a5298),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Background elements matching your app design
                Positioned(
                  top: -50,
                  left: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Name with exact same styling as your app
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Code',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: 'S',
                                style: TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.tealAccent.shade400,
                                  fontFamily: 'monospace',
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15,
                                      color: Colors.tealAccent.withOpacity(0.6),
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: 'nap',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tagline matching your app's style
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Drag • Learn • Code',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator matching your app's theme
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.tealAccent.shade400,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Initializing Code Environment...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom section matching your app's footer style
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          '🚀 Ready to start your coding journey!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'v1.0.0 • © 2025 CodeSnap',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}