import 'package:flutter/material.dart';
import '../services/user_preferences.dart';
import '../services/daily_challenge_service.dart';
import '../services/music_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  // Daily challenges - multiple languages
  final List<Map<String, dynamic>> dailyChallenges = [
    {
      'id': '1',
      'question': 'Complete the function to return the sum of two numbers',
      'incompleteCode': 'def add_numbers(a, b):\n    ______\n    return result',
      'solution': 'def add_numbers(a, b):\n    result = a + b\n    return result',
      'requiredBlocks': ['result = a + b'],
      'optionalBlocks': ['if a > b:', 'for i in range:', 'print(result)'],
      'testCases': [
        {'input': [2, 3], 'expected': 5},
        {'input': [5, 7], 'expected': 12},
        {'input': [0, 0], 'expected': 0},
      ],
      'language': 'Python',
      'difficulty': 'Easy',
      'expectedOutput': '5\n12\n0',
    },
    {
      'id': '2',
      'question': 'Complete function to reverse a string',
      'incompleteCode': 'function reverseString(str) {\n    ______\n    return result;\n}',
      'solution': 'function reverseString(str) {\n    result = str.split("").reverse().join("")\n    return result;\n}',
      'requiredBlocks': ['result = str.split("").reverse().join("")'],
      'optionalBlocks': ['if (!str) return "";', 'let reversed = "";'],
      'testCases': [
        {'input': ['hello'], 'expected': 'olleh'},
        {'input': ['abc'], 'expected': 'cba'},
        {'input': [''], 'expected': ''},
      ],
      'language': 'JavaScript',
      'difficulty': 'Easy',
      'expectedOutput': 'olleh\ncba\n',
    },
    {
      'id': '3',
      'question': 'Complete method to calculate factorial',
      'incompleteCode': 'public int factorial(int n) {\n    ______\n    return result;\n}',
      'solution': 'public int factorial(int n) {\n    int result = 1;\n    for (int i = 1; i <= n; i++)\n        result *= i;\n    }\n    return result;\n}',
      'requiredBlocks': ['int result = 1;', 'for (int i = 1; i <= n; i++)', 'result *= i;', '}'],
      'optionalBlocks': ['if (n == 0) return 1;', 'while (n > 0)'],
      'testCases': [
        {'input': [5], 'expected': 120},
        {'input': [3], 'expected': 6},
        {'input': [0], 'expected': 1},
      ],
      'language': 'Java',
      'difficulty': 'Medium',
      'expectedOutput': '120\n6\n1',
    },
  ];

  TextEditingController _codeController = TextEditingController();
  bool _isCompleted = false;
  bool _showResult = false;
  int _remainingTime = 300;
  late Timer _timer;
  String _completionTime = '';
  DateTime? _startTime;
  List<String> _testResults = [];
  int _currentDayIndex = 0;
  int? _userId;
  bool _isLoading = false;
  bool _hasCompletedToday = false;
  int _streakCount = 0;
  bool _isNewChallenge = false;
  String _todayDate = '';

  // Falling blocks game variables - CODE BLOCKS (not hints)
  List<FallingBlock> _fallingBlocks = [];
  late Timer _blockSpawnTimer;
  late Timer _fallingAnimationTimer;
  Random _random = Random();
  List<String> _collectedBlocks = [];
  Set<String> _requiredBlocks = {};
  Set<String> _optionalBlocks = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeDailySystem();
    _startGameMusic();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('daily_challenge.mp3');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _blockSpawnTimer.cancel();
    _fallingAnimationTimer.cancel();
    _codeController.dispose();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.playBackgroundMusic();
    });

    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      _userId = user['id'];
    });
  }

  Future<void> _initializeDailySystem() async {
    if (_userId == null) {
      await _loadUserData();
    }

    final isNewDay = await DailyChallengeService.isNewDayForUser(_userId);
    final streak = await DailyChallengeService.getUserStreakCount(_userId);
    final hasCompletedToday = await DailyChallengeService.hasUserCompletedToday(_userId);

    setState(() {
      _streakCount = streak;
      _isNewChallenge = isNewDay;
      _hasCompletedToday = hasCompletedToday;
      _todayDate = _getFormattedDate();
    });

    if (isNewDay || _currentDayIndex >= dailyChallenges.length) {
      await _selectNewChallenge();
      await DailyChallengeService.updateUserLastChallengeDate(_userId);
    } else {
      _currentDayIndex = await DailyChallengeService.getUserCurrentChallengeIndex(_userId);
      if (_currentDayIndex >= dailyChallenges.length) {
        _currentDayIndex = 0;
      }
    }

    _initializeDailyChallenge();
    _initializeFallingBlocksGame();
  }

  void _initializeFallingBlocksGame() {
    if (_currentDayIndex >= dailyChallenges.length) {
      _currentDayIndex = 0;
    }

    final currentChallenge = dailyChallenges[_currentDayIndex];

    // BALIK SA CODE BLOCKS SYSTEM
    setState(() {
      _requiredBlocks = Set.from(currentChallenge['requiredBlocks'] ?? []);
      _optionalBlocks = Set.from(currentChallenge['optionalBlocks'] ?? []);
      _collectedBlocks.clear();
      _fallingBlocks.clear();
    });

    _blockSpawnTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (!_isCompleted && !_hasCompletedToday && _remainingTime > 0) {
        _spawnFallingBlock();
      } else {
        timer.cancel();
      }
    });

    _startFallingAnimation();
  }

  void _startFallingAnimation() {
    _fallingAnimationTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_isCompleted || _hasCompletedToday || _remainingTime <= 0) {
        timer.cancel();
        return;
      }

      setState(() {
        for (var block in _fallingBlocks) {
          block.top += 2;
        }
        _fallingBlocks.removeWhere((block) => block.top > 200);
      });
    });
  }

  void _spawnFallingBlock() {
    final allBlocks = [..._requiredBlocks, ..._optionalBlocks];
    if (allBlocks.isEmpty) return;

    final randomIndex = _random.nextInt(allBlocks.length);
    final randomBlock = allBlocks[randomIndex];

    setState(() {
      _fallingBlocks.add(FallingBlock(
        id: DateTime.now().millisecondsSinceEpoch,
        text: randomBlock,
        left: _random.nextDouble() * 300,
        color: _getBlockColor(randomBlock),
      ));
    });
  }

  Color _getBlockColor(String blockText) {
    if (_requiredBlocks.contains(blockText)) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  void _onBlockTap(FallingBlock block) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('block_collect.mp3');

    setState(() {
      _fallingBlocks.remove(block);
      _collectedBlocks.add(block.text);
      _updateCodeWithBlocks();
    });
  }

  void _updateCodeWithBlocks() {
    if (_currentDayIndex >= dailyChallenges.length) return;

    final currentChallenge = dailyChallenges[_currentDayIndex];
    String baseCode = currentChallenge['incompleteCode'];

    if (_collectedBlocks.isNotEmpty) {
      String newCode = baseCode.replaceFirst('______', _collectedBlocks.join('\n    '));
      _codeController.text = newCode;
    }
  }

  // NEW METHOD: Reset collected blocks and code
  void _resetCollectedBlocks() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    setState(() {
      _collectedBlocks.clear();
      _codeController.text = dailyChallenges[_currentDayIndex]['incompleteCode'];
    });
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Future<void> _selectNewChallenge() async {
    try {
      final previousIndex = await DailyChallengeService.getUserCurrentChallengeIndex(_userId);
      int newIndex;

      final userSeed = (_userId ?? 0) + DateTime.now().millisecondsSinceEpoch;
      final userRandom = Random(userSeed);

      newIndex = userRandom.nextInt(dailyChallenges.length);

      if (newIndex == previousIndex && dailyChallenges.length > 1) {
        newIndex = (newIndex + 1) % dailyChallenges.length;
      }

      if (newIndex >= dailyChallenges.length) {
        newIndex = 0;
      }

      setState(() {
        _currentDayIndex = newIndex;
      });

      await DailyChallengeService.setUserCurrentChallengeIndex(_userId, newIndex);
    } catch (e) {
      setState(() {
        _currentDayIndex = 0;
      });
    }
  }

  void _initializeDailyChallenge() {
    if (_currentDayIndex >= dailyChallenges.length) {
      _currentDayIndex = 0;
    }

    setState(() {
      _isCompleted = false;
      _showResult = false;
      _remainingTime = 300;
      _completionTime = '';
      _testResults = [];
      _collectedBlocks.clear();
      _fallingBlocks.clear();
      _codeController.text = dailyChallenges[_currentDayIndex]['incompleteCode'];
      _startTime = DateTime.now();
    });

    _startTimer();
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
          _submitCode();
        }
      }
    });
  }

  void _runTestCases() {
    if (_currentDayIndex >= dailyChallenges.length) return;

    final currentChallenge = dailyChallenges[_currentDayIndex];
    final userCode = _codeController.text;
    final testCases = currentChallenge['testCases'];
    final solution = currentChallenge['solution'];

    _testResults.clear();

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      final expected = testCase['expected'];

      bool passed = _validateCodeStrict(userCode, expected, testCase['input'], solution);
      _testResults.add(passed ? 'PASSED' : 'FAILED');
    }
  }

  bool _validateCodeStrict(String userCode, dynamic expected, List<dynamic> input, String solution) {
    // Check if user didn't modify the code
    if (userCode.contains('______') ||
        userCode.trim() == dailyChallenges[_currentDayIndex]['incompleteCode'].trim()) {
      return false;
    }

    // Basic syntax checks
    String cleanUserCode = userCode.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
    String cleanSolution = solution.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    // Check for essential components based on language
    final currentChallenge = dailyChallenges[_currentDayIndex];
    final language = currentChallenge['language'];

    switch (language) {
      case 'Python':
        if (!cleanUserCode.contains('return') || !cleanUserCode.contains('def')) {
          return false;
        }
        break;
      case 'JavaScript':
        if (!cleanUserCode.contains('return') || !cleanUserCode.contains('function')) {
          return false;
        }
        break;
      case 'Java':
        if (!cleanUserCode.contains('return') || !cleanUserCode.contains('public')) {
          return false;
        }
        break;
    }

    // Check if the logic is correct by comparing key components
    return _checkCodeLogic(userCode, solution);
  }

  bool _checkCodeLogic(String userCode, String solution) {
    // Extract the core logic from both codes
    String userLogic = _extractCoreLogic(userCode);
    String solutionLogic = _extractCoreLogic(solution);

    // Simple comparison - in real app you'd want more sophisticated checking
    return userLogic.contains(solutionLogic) || solutionLogic.contains(userLogic);
  }

  String _extractCoreLogic(String code) {
    // Remove comments, whitespace, and extract the main operation
    return code
        .replaceAll(RegExp(r'#.*?\n'), '')
        .replaceAll(RegExp(r'//.*?\n'), '')
        .replaceAll(RegExp(r'/\*.*?\*/'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  void _submitCode() {
    if (_isCompleted || _hasCompletedToday) return;

    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('compile.mp3');

    setState(() {
      _showResult = true;
      _isLoading = true;
    });

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    _completionTime = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    _runTestCases();

    final passedTests = _testResults.where((result) => result == 'PASSED').length;
    final totalTests = _testResults.length;

    // NEW: Only give reward if ALL tests pass
    bool allTestsPassed = passedTests == totalTests;

    if (allTestsPassed) {
      _updateUserStreakAndSave();
      _showSuccessDialog();
    } else {
      _showFailureDialog();
    }

    setState(() {
      _isCompleted = true;
      _isLoading = false;
    });

    _blockSpawnTimer.cancel();
    _fallingAnimationTimer.cancel();
  }

  Future<void> _updateUserStreakAndSave() async {
    // Mark daily challenge as completed and give hint card
    await DailyChallengeService.markDailyChallengeCompleted(_userId);

    // Update streak count display
    final newStreak = await DailyChallengeService.getUserStreakCount(_userId);
    setState(() {
      _streakCount = newStreak;
    });
  }

  void _showSuccessDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('perfect.mp3');

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
              Icon(Icons.celebration, color: Colors.green, size: 48),
              SizedBox(height: 10),
              Text('Challenge Completed! 🎉',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              SizedBox(height: 15),

              // HINT CARD REWARD
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.orange, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'You earned a Hint Card!',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use this in other levels for help',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),
              Text(
                'Time: $_completionTime',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
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
                musicService.playSoundEffect('click.mp3');
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

  void _showFailureDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('error.mp3');

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
              Icon(Icons.warning, color: Colors.orange, size: 48),
              SizedBox(height: 10),
              Text('Challenge Failed',
                  style: TextStyle(color: Colors.orange, fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Some test cases failed. Try again!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),

              // Test Results
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
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('click.mp3');
                Navigator.of(context).pop();
              },
              child: Text('TRY AGAIN', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallingBlocksArea() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: _fallingBlocks.map((block) {
          return Positioned(
            top: block.top,
            left: block.left,
            child: GestureDetector(
              onTap: () => _onBlockTap(block),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: block.color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Text(
                  block.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // REMOVED: _buildCollectedBlocks() method - tinanggal na yung preview

  Widget _buildCodeEditor() {
    if (_currentDayIndex >= dailyChallenges.length) {
      return Container(
        child: Text('Error: Challenge not found', style: TextStyle(color: Colors.white)),
      );
    }

    final currentChallenge = dailyChallenges[_currentDayIndex];
    final language = currentChallenge['language'] ?? 'Python';
    final fileName = _getFileName(language);

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
          // VS Code Style Header
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
                  fileName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Spacer(),
                // ADDED RESET BUTTON IN CODE EDITOR HEADER
                if (!_hasCompletedToday && !_isCompleted && _collectedBlocks.isNotEmpty)
                  InkWell(
                    onTap: _resetCollectedBlocks,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.red, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Reset Blocks',
                            style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    language.toUpperCase(),
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

          // Code Area with Line Numbers and Syntax Highlighting
          Expanded(
            child: Container(
              color: Color(0xFF1E1E1E),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line Numbers
                  Container(
                    width: 50,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      border: Border(right: BorderSide(color: Colors.grey[800]!)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(10, (index) =>
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                      ),
                    ),
                  ),

                  // Code Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: _buildCodeWithSyntaxHighlighting(),
                      ),
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

  Widget _buildCodeWithSyntaxHighlighting() {
    final currentChallenge = dailyChallenges[_currentDayIndex];
    final language = currentChallenge['language'];
    final code = _codeController.text;

    List<String> lines = code.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.asMap().entries.map((entry) {
        int lineNumber = entry.key;
        String line = entry.value;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: _buildSyntaxHighlightedLine(line, language),
        );
      }).toList(),
    );
  }

  Widget _buildSyntaxHighlightedLine(String line, String language) {
    List<TextSpan> spans = [];
    List<String> words = line.split(' ');

    for (String word in words) {
      Color color = Colors.white;

      if (_isKeyword(word, language)) {
        color = Color(0xFF569CD6);
      } else if (_isString(word)) {
        color = Color(0xFFCE9178);
      } else if (_isNumber(word)) {
        color = Color(0xFFB5CEA8);
      } else if (_isComment(word)) {
        color = Color(0xFF6A9955);
      } else if (_isFunction(word)) {
        color = Color(0xFFDCDCAA);
      }

      spans.add(TextSpan(
        text: '$word ',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  bool _isKeyword(String word, String language) {
    List<String> commonKeywords = ['def', 'function', 'public', 'class', 'return', 'if', 'else', 'for', 'while'];
    List<String> pythonKeywords = ['def', 'return', 'if', 'else', 'for', 'while', 'in', 'import'];
    List<String> jsKeywords = ['function', 'return', 'if', 'else', 'for', 'while', 'const', 'let', 'var'];
    List<String> javaKeywords = ['public', 'class', 'return', 'if', 'else', 'for', 'while', 'int', 'void'];

    switch (language) {
      case 'Python': return pythonKeywords.contains(word);
      case 'JavaScript': return jsKeywords.contains(word);
      case 'Java': return javaKeywords.contains(word);
      default: return commonKeywords.contains(word);
    }
  }

  bool _isString(String word) {
    return word.contains('"') || word.contains("'");
  }

  bool _isNumber(String word) {
    return double.tryParse(word) != null;
  }

  bool _isComment(String word) {
    return word.startsWith('#') || word.startsWith('//');
  }

  bool _isFunction(String word) {
    return word.contains('(') && word.contains(')');
  }

  String _getFileName(String language) {
    switch (language) {
      case 'Python': return 'challenge.py';
      case 'JavaScript': return 'challenge.js';
      case 'Java': return 'Challenge.java';
      case 'C++': return 'challenge.cpp';
      case 'SQL': return 'query.sql';
      case 'PHP': return 'challenge.php';
      default: return 'challenge.txt';
    }
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
            'You earned a Hint Card!',
            style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    if (_currentDayIndex >= dailyChallenges.length) {
      _currentDayIndex = 0;
    }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        'Reward: Hint Card',
                        style: TextStyle(color: Colors.tealAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  children: [
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

                // Falling Blocks Game Area - CODE BLOCKS
                if (!_hasCompletedToday && !_isCompleted) ...[
                  Text(
                    'Tap the falling code blocks to complete your solution:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  _buildFallingBlocksArea(),
                  SizedBox(height: 20),
                ],

                // REMOVED: Collected Blocks Preview - tinanggal na

                Expanded(
                  child: _hasCompletedToday ? _buildAlreadyCompletedView() : _buildCodeEditor(),
                ),

                SizedBox(height: 20),

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

                if (_showResult && !_hasCompletedToday) ...[
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _testResults.every((result) => result == 'PASSED') ? Colors.green : Colors.orange,
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
                              onPressed: _testResults.every((result) => result == 'PASSED')
                                  ? _showSuccessDialog
                                  : _showFailureDialog,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
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
}

class FallingBlock {
  final int id;
  final String text;
  double top;
  double left;
  final Color color;

  FallingBlock({
    required this.id,
    required this.text,
    required this.left,
    this.top = 0,
    required this.color,
  });
}