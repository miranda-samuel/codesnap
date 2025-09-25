import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _securityCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;
  int? _userId;
  String _generatedSecurityCode = '';
  bool _showSecurityCode = false;
  DateTime? _codeExpiry;
  Timer? _countdownTimer;

  void _requestPasswordReset() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSecurityCode = false;
    });

    try {
      final response = await ApiService.requestPasswordReset(username);

      if (response['success'] == true) {
        setState(() {
          _userId = response['user_id'];
          _generatedSecurityCode = response['security_code'];
          _showSecurityCode = true;
          _currentStep = 1;
          _isLoading = false;
          _codeExpiry = DateTime.now().add(const Duration(minutes: 10));
        });

        _startCountdownTimer();
        _securityCodeController.text = _generatedSecurityCode;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final securityCode = _securityCodeController.text;

    if (securityCode.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) return;
    if (newPassword.length < 4) return;
    if (newPassword != confirmPassword) return;
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.resetPassword(
        _userId.toString(),
        newPassword,
        securityCode,
      );

      if (response['success'] == true) {
        _countdownTimer?.cancel();
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {});

      if (_codeExpiry != null && DateTime.now().isAfter(_codeExpiry!)) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _showSecurityCode = false;
          });
        }
      }
    });
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void _restartProcess() {
    _countdownTimer?.cancel();

    setState(() {
      _currentStep = 0;
      _userId = null;
      _usernameController.clear();
      _securityCodeController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSecurityCode = false;
      _generatedSecurityCode = '';
      _codeExpiry = null;
    });
  }

  Widget _buildSecurityCodeDisplay() {
    if (!_showSecurityCode) return const SizedBox();

    final remainingTime = _codeExpiry != null
        ? _codeExpiry!.difference(DateTime.now())
        : const Duration();

    if (remainingTime.isNegative) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Security code has expired',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.teal.shade700),
              const SizedBox(width: 10),
              const Text(
                'Your Security Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _generatedSecurityCode,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Expires in: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _currentStep == 0 ? _requestPasswordReset :
                _currentStep == 1 ? _resetPassword : null,
                onStepCancel: _currentStep > 0 ? _restartProcess : null,
                steps: [
                  Step(
                    title: const Text('Step 1: Get Security Code'),
                    subtitle: const Text('Verify your account'),
                    content: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Enter your username to generate a security code',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Step 2: Reset Password'),
                    subtitle: const Text('Enter code and new password'),
                    content: Column(
                      children: [
                        _buildSecurityCodeDisplay(),

                        TextField(
                          controller: _securityCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Security Code',
                            prefixIcon: Icon(Icons.code),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Step 3: Complete'),
                    subtitle: const Text('Password reset successful'),
                    content: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 80),
                        const SizedBox(height: 20),
                        const Text(
                          'Password Reset Successful!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text('You can now login with your new password.'),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _goToLogin,
                          child: const Text('Go to Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                    state: StepState.complete,
                  ),
                ],
                controlsBuilder: (context, details) {
                  // Hide buttons on the last step
                  if (_currentStep == 2) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Back'),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : details.onStepContinue,
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _usernameController.dispose();
    _securityCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
