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
  // DAILY CHALLENGES - MAS MADALI NA
  final List<Map<String, dynamic>> dailyChallenges = [
    {
      'id': '1',
      'question': 'Complete the function to return the sum of two numbers',
      'incompleteCode': 'def add_numbers(a, b):\n    ______\n    return result',
      'solution': 'def add_numbers(a, b):\n    result = a + b\n    return result',
      'requiredBlocks': ['result = a + b'],
      'optionalBlocks': ['print("Hello")', '# comment'],
      'testCases': [
        {'input': [2, 3], 'expected': 5},
        {'input': [1, 1], 'expected': 2},
      ],
      'language': 'Python',
      'difficulty': 'Easy',
      'expectedOutput': '5\n2',
    },
    {
      'id': '2',
      'question': 'Complete function to return "Hello World"',
      'incompleteCode': 'function hello() {\n    ______\n    return result;\n}',
      'solution': 'function hello() {\n    result = "Hello World"\n    return result;\n}',
      'requiredBlocks': ['result = "Hello World"'],
      'optionalBlocks': ['console.log(result)', '// comment'],
      'testCases': [
        {'input': [], 'expected': 'Hello World'},
      ],
      'language': 'JavaScript',
      'difficulty': 'Easy',
      'expectedOutput': 'Hello World',
    },
    {
      'id': '3',
      'question': 'Complete method to return double the number',
      'incompleteCode': 'public int doubleNumber(int n) {\n    ______\n    return result;\n}',
      'solution': 'public int doubleNumber(int n) {\n    result = n * 2;\n    return result;\n}',
      'requiredBlocks': ['result = n * 2;'],
      'optionalBlocks': ['System.out.println(n);', '// comment'],
      'testCases': [
        {'input': [2], 'expected': 4},
        {'input': [5], 'expected': 10},
      ],
      'language': 'Java',
      'difficulty': 'Easy',
      'expectedOutput': '4\n10',
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

  // Falling blocks game variables
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
          block.top += 3; // PABILISIN
        }
        _fallingBlocks.removeWhere((block) => block.top > 180); // BETTER CLEANUP
      });
    });
  }

  void _spawnFallingBlock() {
    final allBlocks = [..._requiredBlocks, ..._optionalBlocks];
    if (allBlocks.isEmpty) return;

    final randomIndex = _random.nextInt(allBlocks.length);
    final randomBlock = allBlocks[randomIndex];

    // LIMIT NUMBER OF BLOCKS ON SCREEN
    if (_fallingBlocks.length < 5) {
      setState(() {
        _fallingBlocks.add(FallingBlock(
          id: DateTime.now().millisecondsSinceEpoch,
          text: randomBlock,
          left: _random.nextDouble() * 250, // LIMITED HORIZONTAL RANGE
          top: 0,
          color: _getBlockColor(randomBlock),
        ));
      });
    }
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
      height: 200, // FIXED HEIGHT PARA DI MAG-OVERFLOW
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
                // RESET BUTTON
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

          // Code Area with Line Numbers and Syntax Highlighting - FIXED HEIGHT
          Expanded(
            child: Container(
              color: Color(0xFF1E1E1E),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line Numbers - FIXED WIDTH
                  Container(
                    width: 40, // MAS MALIIT NA WIDTH
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4), // MAS MALIIT NA PADDING
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      border: Border(right: BorderSide(color: Colors.grey[800]!)),
                    ),
                    child: SingleChildScrollView( // ADD SCROLL FOR LINE NUMBERS
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(8, (index) => // LESS LINES
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10, // MAS MALIIT NA FONT
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        ),
                      ),
                    ),
                  ),

                  // Code Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // MAS MALIIT NA PADDING
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
          padding: EdgeInsets.symmetric(vertical: 1), // MAS MALIIT NA VERTICAL PADDING
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
          fontSize: 12, // MAS MALIIT NA FONT SIZE
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
            padding: const EdgeInsets.all(16.0), // MAS MALIIT NA PADDING
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _remainingTime <= 60 ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _remainingTime <= 60 ? Colors.red : Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.tealAccent),
                      ),
                      child: Text(
                        'Reward: Hint Card',
                        style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.tealAccent),
                      ),
                      child: Text(
                        currentChallenge['language'],
                        style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(currentChallenge['difficulty']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getDifficultyColor(currentChallenge['difficulty'])),
                      ),
                      child: Text(
                        currentChallenge['difficulty'],
                        style: TextStyle(
                          color: _getDifficultyColor(currentChallenge['difficulty']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Text(
                  currentChallenge['question'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 16),

                // Falling Blocks Game Area
                if (!_hasCompletedToday && !_isCompleted) ...[
                  Text(
                    'Tap the falling code blocks to complete your solution:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  _buildFallingBlocksArea(),
                  SizedBox(height: 16),
                ],

                Expanded(
                  child: _hasCompletedToday ? _buildAlreadyCompletedView() : _buildCodeEditor(),
                ),

                SizedBox(height: 16),

                if (!_isCompleted && !_hasCompletedToday) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 45,
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
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        'SUBMIT CODE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_showResult && !_hasCompletedToday) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.tealAccent, size: 18),
                              onPressed: _testResults.every((result) => result == 'PASSED')
                                  ? _showSuccessDialog
                                  : _showFailureDialog,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Time: $_completionTime',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: _testResults.asMap().entries.map((entry) {
                            int index = entry.key;
                            String result = entry.value;
                            return Chip(
                              label: Text(
                                'Test ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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