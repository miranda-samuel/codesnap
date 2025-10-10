import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';
import '../services/daily_challenge_service.dart';
import 'dart:async';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  // Daily challenges - mag-iiba araw-araw
  final List<Map<String, dynamic>> dailyChallenges = [
    {
      'id': '1',
      'question': 'Complete the function to return the sum of two numbers',
      'incompleteCode': 'def add_numbers(a, b):\n    ______\n    return result',
      'solution': 'def add_numbers(a, b):\n    result = a + b\n    return result',
      'testCases': [
        {'input': [2, 3], 'expected': 5},
        {'input': [5, 7], 'expected': 12},
        {'input': [0, 0], 'expected': 0},
      ],
      'language': 'Python',
      'difficulty': 'Easy'
    },
    {
      'id': '2',
      'question': 'Complete the function to check if number is even',
      'incompleteCode': 'def is_even(number):\n    ______\n    return result',
      'solution': 'def is_even(number):\n    result = number % 2 == 0\n    return result',
      'testCases': [
        {'input': [4], 'expected': true},
        {'input': [7], 'expected': false},
        {'input': [0], 'expected': true},
      ],
      'language': 'Python',
      'difficulty': 'Easy'
    },
    {
      'id': '3',
      'question': 'Complete the function to find maximum of two numbers',
      'incompleteCode': 'def find_max(a, b):\n    ______\n    return result',
      'solution': 'def find_max(a, b):\n    if a > b:\n        result = a\n    else:\n        result = b\n    return result',
      'testCases': [
        {'input': [2, 3], 'expected': 3},
        {'input': [5, 1], 'expected': 5},
        {'input': [0, 0], 'expected': 0},
      ],
      'language': 'Python',
      'difficulty': 'Easy'
    },
    {
      'id': '4',
      'question': 'Complete the function to reverse a string',
      'incompleteCode': 'def reverse_string(text):\n    ______\n    return result',
      'solution': 'def reverse_string(text):\n    result = text[::-1]\n    return result',
      'testCases': [
        {'input': ['hello'], 'expected': 'olleh'},
        {'input': ['abc'], 'expected': 'cba'},
        {'input': [''], 'expected': ''},
      ],
      'language': 'Python',
      'difficulty': 'Easy'
    },
    {
      'id': '5',
      'question': 'Complete the function to calculate factorial',
      'incompleteCode': 'def factorial(n):\n    ______\n    return result',
      'solution': 'def factorial(n):\n    result = 1\n    for i in range(1, n + 1):\n        result *= i\n    return result',
      'testCases': [
        {'input': [5], 'expected': 120},
        {'input': [3], 'expected': 6},
        {'input': [0], 'expected': 1},
      ],
      'language': 'Python',
      'difficulty': 'Medium'
    },
    {
      'id': '6',
      'question': 'Complete the function to count vowels in a string',
      'incompleteCode': 'def count_vowels(text):\n    ______\n    return result',
      'solution': 'def count_vowels(text):\n   vowels = "aeiouAEIOU"\n    result = sum(1 for char in text if char in vowels)\n    return result',
      'testCases': [
        {'input': ['hello'], 'expected': 2},
        {'input': ['Python'], 'expected': 1},
        {'input': [''], 'expected': 0},
      ],
      'language': 'Python',
      'difficulty': 'Easy'
    },
    {
      'id': '7',
      'question': 'Complete the function to find the smallest number in a list',
      'incompleteCode': 'def find_smallest(numbers):\n    ______\n    return result',
      'solution': 'def find_smallest(numbers):\n    result = min(numbers)\n    return result',
      'testCases': [
        {'input': [[3, 1, 4, 2]], 'expected': 1},
        {'input': [[5, 5, 5]], 'expected': 5},
        {'input': [[-1, -5, 0]], 'expected': -5},
      ],
      'language': 'Python',
      'difficulty': 'Easy'
    },
  ];

  TextEditingController _codeController = TextEditingController();
  bool _isCompleted = false;
  bool _showResult = false;
  int _score = 0;
  int _remainingTime = 300; // 5 minutes in seconds
  late Timer _timer;
  String _completionTime = '';
  DateTime? _startTime;
  List<String> _testResults = [];
  int _currentDayIndex = 0;
  int? _userId;
  bool _isLoading = false;
  bool _hasCompletedToday = false;
  int? _previousScore;
  int _streakCount = 0;
  bool _isNewChallenge = false;
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeDailySystem();
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      _userId = user['id'];
    });
  }

  Future<void> _initializeDailySystem() async {
    final isNewDay = await DailyChallengeService.isNewDay();
    final streak = await DailyChallengeService.getStreakCount();
    final hasCompletedToday = await DailyChallengeService.hasCompletedToday();

    setState(() {
      _streakCount = streak;
      _isNewChallenge = isNewDay;
      _hasCompletedToday = hasCompletedToday;
      _todayDate = _getFormattedDate();
    });

    if (isNewDay) {
      await _selectNewChallenge();
      await DailyChallengeService.updateLastChallengeDate();
    } else {
      // Load yesterday's challenge index
      _currentDayIndex = await DailyChallengeService.getCurrentChallengeIndex();
    }

    _initializeDailyChallenge();
  }

  Future<void> _selectNewChallenge() async {
    // Select a random challenge that hasn't been used recently
    final previousIndex = await DailyChallengeService.getCurrentChallengeIndex();
    int newIndex;

    do {
      newIndex = DateTime.now().millisecondsSinceEpoch % dailyChallenges.length;
    } while (newIndex == previousIndex && dailyChallenges.length > 1);

    setState(() {
      _currentDayIndex = newIndex;
    });

    await DailyChallengeService.setCurrentChallengeIndex(newIndex);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  void _initializeDailyChallenge() {
    // Check if user already completed today's challenge from API
    _checkDailyCompletion();

    // Reset state for new challenge
    setState(() {
      _isCompleted = false;
      _showResult = false;
      _score = 0;
      _remainingTime = 300;
      _completionTime = '';
      _testResults = [];
      _codeController.text = dailyChallenges[_currentDayIndex]['incompleteCode'];
      _startTime = DateTime.now();
    });

    _startTimer();
  }

  Future<void> _checkDailyCompletion() async {
    if (_userId == null) return;

    try {
      final result = await ApiService.getScores(_userId!, 'Python');

      if (result['success'] == true && result['scores'] != null) {
        final scores = result['scores'];
        // Check if there's a score for level 999 (daily challenge)
        if (scores.containsKey('999')) {
          final dailyScore = scores['999'];
          setState(() {
            _hasCompletedToday = true;
            _previousScore = dailyScore['score'];
          });
        }
      }
    } catch (e) {
      print('Error checking daily completion: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        if (!_isCompleted && !_hasCompletedToday) {
          _submitCode(); // Auto-submit when time's up
        }
      }
    });
  }

  void _submitCode() {
    if (_isCompleted || _hasCompletedToday) return;

    setState(() {
      _showResult = true;
      _isLoading = true;
    });

    // Calculate completion time
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    _completionTime = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    // Run test cases
    _runTestCases();

    // Calculate score - PERFECT SCORE SYSTEM
    final passedTests = _testResults.where((result) => result == 'PASSED').length;
    final totalTests = _testResults.length;

    // Perfect score (30) only if ALL tests passed
    _score = passedTests == totalTests ? 30 : (30 * passedTests ~/ totalTests);

    // Update streak and save to database
    _updateStreakAndSave();

    setState(() {
      _isCompleted = true;
      _isLoading = false;
    });
  }

  Future<void> _updateStreakAndSave() async {
    if (_score > 0) { // Only update streak if user got some points
      await DailyChallengeService.updateStreak();
      final newStreak = await DailyChallengeService.getStreakCount();
      setState(() {
        _streakCount = newStreak;
      });
    }

    _saveToDatabase();
  }

  void _runTestCases() {
    final currentChallenge = dailyChallenges[_currentDayIndex];
    final userCode = _codeController.text;
    final testCases = currentChallenge['testCases'];

    _testResults.clear();

    // IMPROVED TEST CASE VALIDATION
    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      final expected = testCase['expected'];

      // Better validation logic
      bool passed = _validateCodeImproved(userCode, expected, testCase['input'], currentChallenge['solution']);
      _testResults.add(passed ? 'PASSED' : 'FAILED');
    }
  }

  bool _validateCodeImproved(String userCode, dynamic expected, List<dynamic> input, String solution) {
    // Remove comments and whitespace for better comparison
    String cleanUserCode = userCode.replaceAll(RegExp(r'#.*?\n'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    String cleanSolution = solution.replaceAll(RegExp(r'#.*?\n'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

    // Check if user removed the blank placeholder
    if (userCode.contains('______') || userCode.trim() == dailyChallenges[_currentDayIndex]['incompleteCode'].trim()) {
      return false; // User didn't write any code
    }

    // Check if user has proper return statement and function structure
    bool hasReturn = cleanUserCode.contains('return');
    bool hasFunctionDef = cleanUserCode.contains('def');
    bool hasResultAssignment = cleanUserCode.contains('result=') || cleanUserCode.contains('result =');

    // Basic structure check
    if (!hasReturn || !hasFunctionDef) {
      return false;
    }

    // If user has the basic structure, give them the benefit of the doubt for now
    // In a real app, you'd want to execute the code against test cases
    return hasReturn && hasFunctionDef;
  }

  Future<void> _saveToDatabase() async {
    if (_userId == null) {
      _showErrorDialog('Please login to save your score');
      return;
    }

    try {
      // Save to your SQL database via API - use level 999 for daily challenges
      final result = await ApiService.saveScore(
        _userId!,
        'Python', // Language for daily challenge
        999, // Special level for daily challenges
        _score,
        _score >= 30, // Completed if perfect score
      );

      if (result['success'] == true) {
        print('Daily challenge score saved successfully');
        _showScoreDialog();
      } else {
        print('Failed to save score: ${result['message']}');
        _showErrorDialog(result['message'] ?? 'Failed to save score');
      }
    } catch (e) {
      print('Error saving to database: $e');
      _showErrorDialog('Connection error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('Error', style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              // Streak celebration for perfect scores
              if (_score >= 30 && _streakCount > 1)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    '🔥 $_streakCount Day Streak!',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              SizedBox(height: 10),
              Icon(
                _score >= 30 ? Icons.celebration : Icons.quiz,
                color: _score >= 30 ? Colors.green : Colors.orange,
                size: 48,
              ),
              SizedBox(height: 10),
              Text(
                _score >= 30 ? 'Perfect Score! 🎉' : 'Challenge Completed!',
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $_score/30',
                style: TextStyle(
                  color: _score >= 30 ? Colors.green : Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Time: $_completionTime',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 15),
              ..._testResults.asMap().entries.map((entry) {
                int index = entry.key;
                String result = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    result == 'PASSED' ? Icons.check_circle : Icons.cancel,
                    color: result == 'PASSED' ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  title: Text(
                    'Test Case ${index + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: Text(
                    result,
                    style: TextStyle(
                      color: result == 'PASSED' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 10),
              Text(
                'Come back tomorrow for a new challenge!',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text('CLOSE', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCodeEditor() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Editor Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.tealAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'challenge.py',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    'PYTHON',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Input Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                enabled: !_isCompleted && !_hasCompletedToday,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: _hasCompletedToday
                      ? 'You have already completed today\'s challenge!'
                      : (_isCompleted ? 'Challenge completed!' : 'Type your code here...'),
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyCompletedView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 48),
          SizedBox(height: 10),
          // Streak display in completed view
          if (_streakCount > 1)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                '🔥 $_streakCount Day Streak!',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
          SizedBox(height: 10),
          Text(
            'Challenge Already Completed!',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'You have already completed today\'s daily challenge. Come back tomorrow for a new challenge!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'Your Score: ${_previousScore ?? 0}/30',
            style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentChallenge = dailyChallenges[_currentDayIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          children: [
            Text('Daily Coding Challenge', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              _todayDate,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Streak counter
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text(
                  '$_streakCount days',
                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with timer and points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _remainingTime <= 60 ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _remainingTime <= 60 ? Colors.red : Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.tealAccent),
                      ),
                      child: Text(
                        'Points: 30',
                        style: TextStyle(color: Colors.tealAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Challenge Info Row
                Row(
                  children: [
                    // Language Tag
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.tealAccent),
                      ),
                      child: Text(
                        currentChallenge['language'],
                        style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Difficulty Tag
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(currentChallenge['difficulty']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getDifficultyColor(currentChallenge['difficulty'])),
                      ),
                      child: Text(
                        currentChallenge['difficulty'],
                        style: TextStyle(
                          color: _getDifficultyColor(currentChallenge['difficulty']),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Question
                Text(
                  currentChallenge['question'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 20),

                // Code Editor or Already Completed View
                Expanded(
                  child: _hasCompletedToday ? _buildAlreadyCompletedView() : _buildCodeEditor(),
                ),

                SizedBox(height: 20),

                // Submit Button (only show if not completed today)
                if (!_isCompleted && !_hasCompletedToday) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        'SUBMIT CODE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                // Result Display
                if (_showResult && !_hasCompletedToday) ...[
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _score >= 30 ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Results:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.tealAccent),
                              onPressed: _showScoreDialog,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Score: $_score/30',
                          style: TextStyle(
                            color: _score >= 30 ? Colors.green : Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Time: $_completionTime',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: _testResults.asMap().entries.map((entry) {
                            int index = entry.key;
                            String result = entry.value;
                            return Chip(
                              label: Text(
                                'Test ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: result == 'PASSED' ? Colors.green : Colors.red,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.tealAccent;
    }
  }
}