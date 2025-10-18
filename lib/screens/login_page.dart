import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Sound effects method
  void _playSound(String soundType) {
    try {
      switch (soundType) {
        case 'success':
          SystemSound.play(SystemSoundType.click);
          break;
        case 'error':
        // Play two quick clicks for error
          SystemSound.play(SystemSoundType.click);
          Future.delayed(const Duration(milliseconds: 100), () {
            SystemSound.play(SystemSoundType.click);
          });
          break;
        case 'warning':
        // Play three clicks for warning
          for (int i = 0; i < 3; i++) {
            Future.delayed(Duration(milliseconds: i * 150), () {
              SystemSound.play(SystemSoundType.click);
            });
          }
          break;
        case 'click':
        default:
          SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _playSound('error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(username, password);

      if (response['success'] == true) {
        _playSound('success');

        await UserPreferences.saveUser(response['user']);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${response['user']['full_name']}'),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _playSound('error');

        // Check if it's a session conflict (user already logged in elsewhere)
        if (response['message']?.toLowerCase().contains('already logged in') == true ||
            response['message']?.toLowerCase().contains('another device') == true) {
          _showSessionConflictDialog(response['user_id'] ?? 0);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      _playSound('error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSessionConflictDialog(int userId) {
    _playSound('warning');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 10),
              Text('Already Logged In'),
            ],
          ),
          content: const Text(
            'This account is already active on another device. You can only be logged in on one device at a time.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playSound('click');
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToForgotPassword() {
    _playSound('click');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _navigateToSignUp() {
    _playSound('click');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.blueGrey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with sound on tap
                  GestureDetector(
                    onTap: () => _playSound('click'),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Code',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                              fontFamily: 'monospace',
                            ),
                          ),
                          TextSpan(
                            text: 'S',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                              fontFamily: 'monospace',
                              shadows: [
                                Shadow(
                                  offset: const Offset(1, 2),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                )
                              ],
                            ),
                          ),
                          TextSpan(
                            text: 'nap',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Welcome Text
                  Text(
                    'Welcome Back, Coder!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username Field
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      _playSound('click');
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _playSound('click');
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),

                  // Login Button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Link
                  TextButton(
                    onPressed: _navigateToSignUp,
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}