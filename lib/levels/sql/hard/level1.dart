import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';
import '../../../services/music_service.dart';
import '../../../services/daily_challenge_service.dart';

class SqlLevel1Hard extends StatefulWidget {
  const SqlLevel1Hard({super.key});

  @override
  State<SqlLevel1Hard> createState() => _SqlLevel1HardState();
}

class _SqlLevel1HardState extends State<SqlLevel1Hard> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool levelCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 8; // Increased for hard level
  int remainingSeconds = 240; // 4 minutes for hard level
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  // Track currently dragged block
  String? currentlyDraggedBlock;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  // Game configuration from database
  Map<String, dynamic>? gameConfig;
  bool isLoading = true;
  String? errorMessage;

  // HINT SYSTEM
  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  // Configurable elements from database
  String _codePreviewTitle = '💾 Advanced SQL Query:';
  String _instructionText = '🧩 Build a complex SQL query with JOIN, WHERE, and ORDER BY';
  List<String> _codeStructure = [];
  String _expectedOutput = 'Name    | Department | Salary | Project\nJohn    | IT         | 50000  | Website\nCarlos  | IT         | 52000  | Mobile App\nSarah   | IT         | 48000  | Database';

  // Table data for visualization
  List<Map<String, dynamic>> _employeesTable = [];
  List<Map<String, dynamic>> _departmentsTable = [];
  List<Map<String, dynamic>> _queryResult = [];

  @override
  void initState() {
    super.initState();
    _loadGameConfig();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
    _loadHintCards();
    _initializeTableData();
  }

  void _initializeTableData() {
    // Employees table
    _employeesTable = [
      {'id': 1, 'name': 'John', 'age': 25, 'department_id': 1, 'salary': 50000},
      {'id': 2, 'name': 'Maria', 'age': 30, 'department_id': 2, 'salary': 45000},
      {'id': 3, 'name': 'Carlos', 'age': 28, 'department_id': 1, 'salary': 52000},
      {'id': 4, 'name': 'Anna', 'age': 22, 'department_id': 2, 'salary': 42000},
      {'id': 5, 'name': 'Mike', 'age': 35, 'department_id': 3, 'salary': 60000},
      {'id': 6, 'name': 'Sarah', 'age': 29, 'department_id': 1, 'salary': 48000},
    ];

    // Departments table
    _departmentsTable = [
      {'id': 1, 'name': 'IT', 'manager': 'Mr. Smith', 'budget': 200000},
      {'id': 2, 'name': 'HR', 'manager': 'Ms. Johnson', 'budget': 150000},
      {'id': 3, 'name': 'Finance', 'manager': 'Mr. Brown', 'budget': 180000},
    ];
  }

  void _updateQueryResult() {
    // Simulate JOIN query result for IT department employees
    _queryResult = [
      {'name': 'John', 'department': 'IT', 'salary': 50000, 'project': 'Website'},
      {'name': 'Carlos', 'department': 'IT', 'salary': 52000, 'project': 'Mobile App'},
      {'name': 'Sarah', 'department': 'IT', 'salary': 48000, 'project': 'Database'},
    ];
  }

  Future<void> _loadGameConfig() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService.getGameConfig('SQL', 3); // Level 3 for hard

      print('🔍 SQL HARD GAME CONFIG RESPONSE:');
      print('   Success: ${response['success']}');
      print('   Message: ${response['message']}');

      if (response['success'] == true && response['game'] != null) {
        setState(() {
          gameConfig = response['game'];
          _initializeGameFromConfig();
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load game configuration from database';
        });
      }
    } catch (e) {
      print('❌ Error loading game config: $e');
      setState(() {
        errorMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeGameFromConfig() {
    if (gameConfig == null) return;

    try {
      print('🔄 INITIALIZING SQL HARD GAME FROM CONFIG');

      // Load timer duration from database
      if (gameConfig!['timer_duration'] != null) {
        int timerDuration = int.tryParse(gameConfig!['timer_duration'].toString()) ?? 240;
        setState(() {
          remainingSeconds = timerDuration;
        });
        print('⏰ Timer duration loaded: $timerDuration seconds');
      }

      // Load instruction text from database
      if (gameConfig!['instruction_text'] != null) {
        setState(() {
          _instructionText = gameConfig!['instruction_text'].toString();
        });
        print('📝 Instruction text loaded: $_instructionText');
      }

      // Load code preview title from database
      if (gameConfig!['code_preview_title'] != null) {
        setState(() {
          _codePreviewTitle = gameConfig!['code_preview_title'].toString();
        });
        print('💻 Code preview title loaded: $_codePreviewTitle');
      }

      // Load code structure from database
      if (gameConfig!['code_structure'] != null) {
        if (gameConfig!['code_structure'] is List) {
          setState(() {
            _codeStructure = List<String>.from(gameConfig!['code_structure']);
          });
        } else {
          String codeStructureStr = gameConfig!['code_structure']?.toString() ?? '[]';
          try {
            List<dynamic> codeStructureJson = json.decode(codeStructureStr);
            setState(() {
              _codeStructure = List<String>.from(codeStructureJson);
            });
          } catch (e) {
            print('❌ Error parsing code structure: $e');
            setState(() {
              _codeStructure = _getDefaultCodeStructure();
            });
          }
        }
        print('📝 Code structure loaded: $_codeStructure');
      } else {
        setState(() {
          _codeStructure = _getDefaultCodeStructure();
        });
      }

      // Load expected output from database
      if (gameConfig!['expected_output'] != null) {
        setState(() {
          _expectedOutput = gameConfig!['expected_output'].toString();
        });
        print('🎯 Expected output loaded: $_expectedOutput');
      }

      // Load hint from database
      if (gameConfig!['hint_text'] != null) {
        setState(() {
          _currentHint = gameConfig!['hint_text'].toString();
        });
        print('💡 Hint loaded from database: $_currentHint');
      } else {
        setState(() {
          _currentHint = _getDefaultHint();
        });
        print('💡 Using default hint');
      }

      // Parse blocks with better error handling
      List<String> correctBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');
      List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');

      print('✅ Correct Blocks: $correctBlocks');
      print('✅ Incorrect Blocks: $incorrectBlocks');

      // Combine and shuffle blocks
      allBlocks = [
        ...correctBlocks,
        ...incorrectBlocks,
      ]..shuffle();

      print('🎮 All Blocks Final: $allBlocks');

    } catch (e) {
      print('❌ Error parsing game config: $e');
      _initializeDefaultBlocks();
    }
  }

  List<String> _getDefaultCodeStructure() {
    return [
      "-- Advanced SQL Query: Join employees with departments",
      "-- and filter IT department employees ordered by salary",
      "",
      "SELECT e.name, d.name AS department, e.salary",
      "FROM employees e",
      "INNER JOIN departments d ON e.department_id = d.id",
      "WHERE d.name = 'IT'",
      "ORDER BY e.salary DESC;"
    ];
  }

  List<String> _parseBlocks(dynamic blocksData, String type) {
    List<String> blocks = [];

    if (blocksData == null) {
      return _getDefaultBlocks(type);
    }

    try {
      if (blocksData is List) {
        blocks = List<String>.from(blocksData);
      } else if (blocksData is String) {
        String blocksStr = blocksData.trim();

        if (blocksStr.startsWith('[') && blocksStr.endsWith(']')) {
          // Parse as JSON array
          List<dynamic> blocksJson = json.decode(blocksStr);
          blocks = List<String>.from(blocksJson);
        } else {
          // Parse as comma-separated string
          blocks = blocksStr.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
        }
      }
    } catch (e) {
      print('❌ Error parsing $type blocks: $e');
      blocks = _getDefaultBlocks(type);
    }

    return blocks;
  }

  List<String> _getDefaultBlocks(String type) {
    if (type == 'correct') {
      return [
        'SELECT',
        'e.name, d.name AS department, e.salary',
        'FROM',
        'employees e',
        'INNER JOIN',
        'departments d',
        'ON e.department_id = d.id',
        'WHERE',
        "d.name = 'IT'",
        'ORDER BY',
        'e.salary DESC',
        ';'
      ];
    } else {
      return [
        'SELECT *', // Too broad
        'FROM employees', // Missing JOIN
        'JOIN departments', // Missing JOIN type
        'LEFT JOIN departments', // Wrong JOIN type
        'ON id = department_id', // Wrong join condition
        "WHERE department = 'IT'", // Wrong table reference
        "WHERE e.department = 'IT'", // Wrong column name
        'ORDER BY salary', // Missing table alias
        'ORDER BY e.salary ASC', // Wrong sort order
        'GROUP BY department', // Unnecessary clause
        'HAVING salary > 45000', // Unnecessary clause
        'e.name, d.department_name', // Wrong column name
        'name, department, salary', // Missing table aliases
        "d.name = IT", // Missing quotes
        "WHERE name = 'IT'", // Ambiguous column
        'LIMIT 10', // Unnecessary clause
      ];
    }
  }

  String _getDefaultHint() {
    return "💡 Expert Hint: Use INNER JOIN to combine tables. Specify table aliases (e, d). Use ON for join conditions. ORDER BY for sorting. Remember table aliases in SELECT and WHERE.";
  }

  void _initializeDefaultBlocks() {
    allBlocks = [
      // Correct blocks
      'SELECT',
      'e.name, d.name AS department, e.salary',
      'FROM',
      'employees e',
      'INNER JOIN',
      'departments d',
      'ON e.department_id = d.id',
      'WHERE',
      "d.name = 'IT'",
      'ORDER BY',
      'e.salary DESC',
      ';',
      // Incorrect blocks
      'SELECT *',
      'FROM employees',
      'JOIN departments',
      'LEFT JOIN departments',
      'ON id = department_id',
      "WHERE department = 'IT'",
      "WHERE e.department = 'IT'",
      'ORDER BY salary',
      'ORDER BY e.salary ASC',
      'GROUP BY department',
      'HAVING salary > 45000',
      'e.name, d.department_name',
      'name, department, salary',
      "d.name = IT",
      "WHERE name = 'IT'",
      'LIMIT 10',
    ]..shuffle();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('challenge_music.mp3');
    });
  }

  void _calculateScaleFactor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;

      setState(() {
        if (screenWidth < _baseScreenWidth) {
          _scaleFactor = screenWidth / _baseScreenWidth;
        } else {
          _scaleFactor = 1.0;
        }
      });
    });
  }

  Future<void> _loadHintCards() async {
    final user = await UserPreferences.getUser();
    if (user['id'] != null) {
      final hintCards = await DailyChallengeService.getUserHintCards(user['id']);
      setState(() {
        _availableHintCards = hintCards;
      });
    }
  }

  void _useHintCard() async {
    if (_availableHintCards > 0 && !_isUsingHint) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('hint_use.mp3');

      setState(() {
        _isUsingHint = true;
        _showHint = true;
        _availableHintCards--;
      });

      final user = await UserPreferences.getUser();
      if (user['id'] != null) {
        await DailyChallengeService.useHintCard(user['id']);
      }

      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showHint = false;
            _isUsingHint = false;
          });
        }
      });
    } else if (_availableHintCards <= 0) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hint cards available! Complete daily challenges to earn more.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      currentUser = user;
    });
    loadScoreFromDatabase();
    _loadHintCards();
  }

  void resetBlocks() {
    if (gameConfig != null) {
      _initializeGameFromConfig();
    } else {
      _initializeDefaultBlocks();
    }
    setState(() {});
  }

  void startGame() {
    if (gameConfig == null) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Game configuration not loaded. Please retry.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('challenge_start.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 240
        : 240;

    setState(() {
      gameStarted = true;
      score = 8;
      remainingSeconds = timerDuration;
      droppedBlocks.clear();
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      resetBlocks();
      _updateQueryResult();
    });

    print('🎮 SQL HARD GAME STARTED - Initial Score: $score, Timer: $timerDuration seconds');
    startTimers();
  }

  void startTimers() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isAnsweredCorrectly) {
        timer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          score = 0;
          timer.cancel();
          scoreReductionTimer?.cancel();
          saveScoreToDatabase(score);

          final musicService = Provider.of<MusicService>(context, listen: false);
          musicService.playSoundEffect('time_up.mp3');

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("⏰ Time's Up!"),
              content: Text("Score: $score"),
              actions: [
                TextButton(
                  onPressed: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('click.mp3');
                    resetGame();
                    Navigator.pop(context);
                  },
                  child: Text("Retry"),
                )
              ],
            ),
          );
        }
      });
    });

    // Score reduction every 30 seconds (faster than medium level)
    scoreReductionTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty.mp3');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⏰ Time penalty! -1 point. Current score: $score"),
          ),
        );
      });
    });
  }

  void resetGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 240
        : 240;

    setState(() {
      score = 8;
      remainingSeconds = timerDuration;
      gameStarted = false;
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      droppedBlocks.clear();
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();
      resetBlocks();
    });
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) {
      print('❌ Cannot save score: No user ID');
      return;
    }

    try {
      print('💾 SAVING SQL HARD SCORE:');
      print('   User ID: ${currentUser!['id']}');
      print('   Language: SQL');
      print('   Level: 3'); // Level 3 for hard
      print('   Score: $score/8');
      print('   Completed: ${score == 8}');

      final response = await ApiService.saveScore(
        currentUser!['id'],
        'SQL',
        3, // Level 3 for hard
        score,
        score == 8,
      );

      print('📡 SERVER RESPONSE: $response');

      if (response['success'] == true) {
        setState(() {
          levelCompleted = score == 8;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('✅ SQL HARD SCORE SAVED SUCCESSFULLY TO DATABASE');
      } else {
        print('❌ FAILED TO SAVE SCORE: ${response['message']}');
      }
    } catch (e) {
      print('❌ ERROR SAVING SQL HARD SCORE: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScores(currentUser!['id'], 'SQL');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level3Data = scoresData['3']; // Level 3 for hard

        if (level3Data != null) {
          setState(() {
            previousScore = level3Data['score'] ?? 0;
            levelCompleted = level3Data['completed'] ?? false;
            hasPreviousScore = true;
          });
        }
      }
    } catch (e) {
      print('Error loading SQL hard score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    if (gameConfig != null) {
      try {
        List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');
        return incorrectBlocks.contains(block);
      } catch (e) {
        print('Error checking incorrect block: $e');
      }
    }

    // Default incorrect blocks for SQL Hard
    List<String> incorrectBlocks = [
      'SELECT *',
      'FROM employees',
      'JOIN departments',
      'LEFT JOIN departments',
      'ON id = department_id',
      "WHERE department = 'IT'",
      "WHERE e.department = 'IT'",
      'ORDER BY salary',
      'ORDER BY e.salary ASC',
      'GROUP BY department',
      'HAVING salary > 45000',
      'e.name, d.department_name',
      'name, department, salary',
      "d.name = IT",
      "WHERE name = 'IT'",
      'LIMIT 10',
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      musicService.playSoundEffect('error.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ You used incorrect SQL syntax! -1 point. Current score: $score"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);

        musicService.playSoundEffect('game_over.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Challenge Failed"),
            content: Text("You used incorrect SQL syntax and lost all points!"),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Retry Challenge"),
              )
            ],
          ),
        );
      }
      return;
    }

    // Check correct answer - complex logic for hard level
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();

    bool isCorrect = false;

    if (gameConfig != null) {
      // Use configured correct answer
      String expectedAnswer = gameConfig!['correct_answer'] ?? '';
      String normalizedExpected = expectedAnswer.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();
      isCorrect = normalizedAnswer == normalizedExpected;
    } else {
      // Fallback check for SQL Hard Level
      // Should contain all required elements for the complex query
      bool hasSelect = droppedBlocks.contains('SELECT');
      bool hasCorrectColumns = droppedBlocks.any((block) =>
          block.contains('e.name, d.name AS department, e.salary'));
      bool hasFrom = droppedBlocks.contains('FROM');
      bool hasEmployeesAlias = droppedBlocks.contains('employees e');
      bool hasInnerJoin = droppedBlocks.contains('INNER JOIN');
      bool hasDepartmentsAlias = droppedBlocks.contains('departments d');
      bool hasOnClause = droppedBlocks.contains('ON e.department_id = d.id');
      bool hasWhere = droppedBlocks.contains('WHERE');
      bool hasCondition = droppedBlocks.any((block) =>
          block.contains("d.name = 'IT'"));
      bool hasOrderBy = droppedBlocks.contains('ORDER BY');
      bool hasSort = droppedBlocks.contains('e.salary DESC');
      bool hasSemicolon = droppedBlocks.contains(';');

      isCorrect = hasSelect && hasCorrectColumns && hasFrom && hasEmployeesAlias &&
          hasInnerJoin && hasDepartmentsAlias && hasOnClause && hasWhere &&
          hasCondition && hasOrderBy && hasSort && hasSemicolon;
    }

    if (isCorrect) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      // PLAY SUCCESS SOUND BASED ON SCORE
      if (score == 8) {
        musicService.playSoundEffect('perfect.mp3');
      } else {
        musicService.playSoundEffect('success.mp3');
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("🏆 Expert SQL Query Mastered!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Outstanding SQL Expertise!", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Your Score: $score/8", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 8)
                Text(
                  "🎉 SQL Expert Status Unlocked!",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (8/8) to become an SQL Expert!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Query Result:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  _expectedOutput,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "You've successfully built a complex query with:\n• Table JOINs\n• Column aliases\n• Conditional filtering\n• Result sorting",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('level_complete.mp3');
                Navigator.pop(context);
                if (score == 8) {
                  Navigator.pushReplacementNamed(context, '/sql_expert_levels');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: {
                    'language': 'SQL',
                    'difficulty': 'Hard'
                  });
                }
              },
              child: Text(score == 8 ? "Expert Levels" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      musicService.playSoundEffect('wrong.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Incorrect complex query. -1 point. Current score: $score"),
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);

        musicService.playSoundEffect('game_over.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Expert Challenge Failed"),
            content: Text("You lost all your points. Practice more complex queries!"),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Retry Challenge"),
              )
            ],
          ),
        );
      }
    }
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _buildHintDisplay() {
    if (!_showHint) return SizedBox();

    return Positioned(
      top: 60 * _scaleFactor,
      left: 20 * _scaleFactor,
      right: 20 * _scaleFactor,
      child: Container(
        padding: EdgeInsets.all(16 * _scaleFactor),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.tealAccent, width: 2 * _scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8 * _scaleFactor,
              offset: Offset(0, 4 * _scaleFactor),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  '💡 SQL Expert Hint Activated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * _scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              _currentHint,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * _scaleFactor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Expert hint will disappear in 5 seconds...',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 12 * _scaleFactor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintButton() {
    return Positioned(
      bottom: 20 * _scaleFactor,
      right: 20 * _scaleFactor,
      child: GestureDetector(
        onTap: _useHintCard,
        child: Container(
          padding: EdgeInsets.all(12 * _scaleFactor),
          decoration: BoxDecoration(
            color: _availableHintCards > 0 ? Colors.teal : Colors.grey,
            borderRadius: BorderRadius.circular(20 * _scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4 * _scaleFactor,
                offset: Offset(0, 2 * _scaleFactor),
              )
            ],
            border: Border.all(
              color: _availableHintCards > 0 ? Colors.tealAccent : Colors.grey,
              width: 2 * _scaleFactor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 20 * _scaleFactor),
              SizedBox(width: 6 * _scaleFactor),
              Text(
                '$_availableHintCards',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18 * _scaleFactor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Database Tables Visualization
  Widget _buildDatabaseTables() {
    return Column(
      children: [
        // Employees Table
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16 * _scaleFactor),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8 * _scaleFactor),
            border: Border.all(color: Colors.blue[700]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 6 * _scaleFactor),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8 * _scaleFactor),
                    topRight: Radius.circular(8 * _scaleFactor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue[400], size: 16 * _scaleFactor),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                      'employees table',
                      style: TextStyle(
                        color: Colors.blue[400],
                        fontSize: 12 * _scaleFactor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12 * _scaleFactor),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 28 * _scaleFactor,
                    headingRowHeight: 36 * _scaleFactor,
                    columns: [
                      DataColumn(label: Text('ID', style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Name', style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Age', style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Dept ID', style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Salary', style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold))),
                    ],
                    rows: _employeesTable.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(Text(data['id'].toString(), style: TextStyle(color: Colors.white))),
                          DataCell(Text(data['name'].toString(), style: TextStyle(color: Colors.white))),
                          DataCell(Text(data['age'].toString(), style: TextStyle(color: Colors.white))),
                          DataCell(Text(data['department_id'].toString(), style: TextStyle(color: Colors.white))),
                          DataCell(Text('\$${data['salary']}', style: TextStyle(color: Colors.white))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Departments Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8 * _scaleFactor),
            border: Border.all(color: Colors.green[700]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 6 * _scaleFactor),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8 * _scaleFactor),
                    topRight: Radius.circular(8 * _scaleFactor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Colors.green[400], size: 16 * _scaleFactor),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                      'departments table',
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: 12 * _scaleFactor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12 * _scaleFactor),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 28 * _scaleFactor,
                    headingRowHeight: 36 * _scaleFactor,
                    columns: [
                      DataColumn(label: Text('ID', style: TextStyle(color: Colors.green[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Name', style: TextStyle(color: Colors.green[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Manager', style: TextStyle(color: Colors.green[300], fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Budget', style: TextStyle(color: Colors.green[300], fontWeight: FontWeight.bold))),
                    ],
                    rows: _departmentsTable.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(Text(data['id'].toString(), style: TextStyle(color: Colors.white))),
                          DataCell(Text(data['name'].toString(),
                              style: TextStyle(
                                  color: data['name'] == 'IT' ? Colors.yellow : Colors.white,
                                  fontWeight: data['name'] == 'IT' ? FontWeight.bold : FontWeight.normal
                              ))),
                          DataCell(Text(data['manager'].toString(), style: TextStyle(color: Colors.white))),
                          DataCell(Text('\$${data['budget']}', style: TextStyle(color: Colors.white))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // SQL Query Preview Widget
  Widget getCodePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8 * _scaleFactor),
        border: Border.all(color: Colors.teal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 6 * _scaleFactor),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8 * _scaleFactor),
                topRight: Radius.circular(8 * _scaleFactor),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.grey[400], size: 16 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  'complex_join_query.sql',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12 * _scaleFactor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12 * _scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildOrganizedCodePreview(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrganizedCodePreview() {
    List<Widget> codeLines = [];

    for (int i = 0; i < _codeStructure.length; i++) {
      String line = _codeStructure[i];

      if (line.contains('SELECT e.name') ||
          line.contains('FROM employees e') ||
          line.contains('INNER JOIN departments d') ||
          line.contains('ON e.department_id = d.id') ||
          line.contains("WHERE d.name = 'IT'") ||
          line.contains('ORDER BY e.salary DESC')) {
        // Add user's dragged SQL query
        codeLines.add(_buildUserQuerySection(line));
      } else if (line.trim().isEmpty) {
        codeLines.add(SizedBox(height: 16 * _scaleFactor));
      } else {
        codeLines.add(_buildSyntaxHighlightedLine(line, i + 1));
      }
    }

    return codeLines;
  }

  Widget _buildUserQuerySection(String placeholder) {
    List<String> relevantBlocks = [];

    if (placeholder.contains('SELECT')) {
      relevantBlocks = droppedBlocks.where((block) =>
      block == 'SELECT' || block.contains('e.name, d.name AS department, e.salary')).toList();
    } else if (placeholder.contains('FROM')) {
      relevantBlocks = droppedBlocks.where((block) =>
      block == 'FROM' || block == 'employees e').toList();
    } else if (placeholder.contains('INNER JOIN')) {
      relevantBlocks = droppedBlocks.where((block) =>
      block == 'INNER JOIN' || block == 'departments d').toList();
    } else if (placeholder.contains('ON')) {
      relevantBlocks = droppedBlocks.where((block) =>
      block == 'ON e.department_id = d.id').toList();
    } else if (placeholder.contains('WHERE')) {
      relevantBlocks = droppedBlocks.where((block) =>
      block == 'WHERE' || block.contains("d.name = 'IT'")).toList();
    } else if (placeholder.contains('ORDER BY')) {
      relevantBlocks = droppedBlocks.where((block) =>
      block == 'ORDER BY' || block == 'e.salary DESC').toList();
    }

    if (relevantBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          placeholder,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12 * _scaleFactor,
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
      child: Wrap(
        spacing: 4 * _scaleFactor,
        runSpacing: 4 * _scaleFactor,
        children: relevantBlocks.map((block) {
          return Container(
            margin: EdgeInsets.only(right: 4 * _scaleFactor),
            child: Text(
              block,
              style: TextStyle(
                color: _getSqlKeywordColor(block),
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getSqlKeywordColor(String block) {
    if (block == 'SELECT' || block == 'FROM' || block == 'WHERE' || block == 'ORDER BY') {
      return Color(0xFF569CD6); // SQL keywords - blue
    } else if (block == 'INNER JOIN') {
      return Color(0xFFC586C0); // JOIN keyword - pink
    } else if (block == 'ON') {
      return Color(0xFFDCDCAA); // ON clause - yellow
    } else if (block.contains('e.name, d.name AS department, e.salary')) {
      return Color(0xFFD7BA7D); // Column list - gold
    } else if (block == 'employees e' || block == 'departments d') {
      return Color(0xFF4EC9B0); // Table aliases - teal
    } else if (block.contains("d.name = 'IT'")) {
      return Color(0xFFCE9178); // Condition - orange
    } else if (block == 'e.salary DESC') {
      return Color(0xFFD16969); // Sort - red
    } else if (block == ';') {
      return Colors.white; // Semicolon - white
    }
    return Colors.purpleAccent[400]!;
  }

  Widget _buildSyntaxHighlightedLine(String code, int lineNumber) {
    Color textColor = Colors.white;
    String displayCode = code;

    // SQL syntax highlighting rules for advanced code
    if (code.trim().startsWith('--')) {
      textColor = Color(0xFF6A9955); // Comments - green
    } else if (code.contains('SELECT') || code.contains('FROM') || code.contains('WHERE') || code.contains('ORDER BY')) {
      textColor = Color(0xFF569CD6); // SQL keywords - blue
    } else if (code.contains('INNER JOIN')) {
      textColor = Color(0xFFC586C0); // JOIN keyword - pink
    } else if (code.contains('ON')) {
      textColor = Color(0xFFDCDCAA); // ON clause - yellow
    } else if (code.contains('AS department')) {
      textColor = Color(0xFFD7BA7D); // Column alias - gold
    } else if (code.contains('employees e') || code.contains('departments d')) {
      textColor = Color(0xFF4EC9B0); // Table aliases - teal
    } else if (code.contains("'IT'")) {
      textColor = Color(0xFFCE9178); // String value - orange
    } else if (code.contains('DESC')) {
      textColor = Color(0xFFD16969); // Sort direction - red
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2 * _scaleFactor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30 * _scaleFactor,
            child: Text(
              lineNumber.toString().padLeft(2, ' '),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(width: 16 * _scaleFactor),
          Expanded(
            child: Text(
              displayCode,
              style: TextStyle(
                color: textColor,
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    scoreReductionTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.playBackgroundMusic();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("🗃️ SQL - Level 3 (Hard)", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.teal,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B2A),
                Color(0xFF1B263B),
                Color(0xFF415A77),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 20),
                Text(
                  "Loading SQL Expert Challenge...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Advanced Database Configuration",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage != null && !gameStarted) {
      return Scaffold(
        appBar: AppBar(
          title: Text("🗃️ SQL - Level 3 (Hard)", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.teal,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B2A),
                Color(0xFF1B263B),
                Color(0xFF415A77),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.teal, size: 50),
                  SizedBox(height: 20),
                  Text(
                    "Expert Challenge Warning",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadGameConfig,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text("Retry Loading"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/levels', arguments: {
                        'language': 'SQL',
                        'difficulty': 'Hard'
                      });
                    },
                    child: Text("Back to Levels", style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newScreenWidth = MediaQuery.of(context).size.width;
      final newScaleFactor = newScreenWidth < _baseScreenWidth
          ? newScreenWidth / _baseScreenWidth
          : 1.0;

      if (newScaleFactor != _scaleFactor) {
        setState(() {
          _scaleFactor = newScaleFactor;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("🗃️ SQL - Level 3 (Hard)", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.teal,
        actions: gameStarted
            ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18 * _scaleFactor),
                SizedBox(width: 4 * _scaleFactor),
                Text(formatTime(remainingSeconds), style: TextStyle(fontSize: 14 * _scaleFactor)),
                SizedBox(width: 16 * _scaleFactor),
                Icon(Icons.star, color: Colors.yellowAccent, size: 18 * _scaleFactor),
                Text(" $score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor)),
              ],
            ),
          ),
        ]
            : [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: Stack(
          children: [
            gameStarted ? buildGameUI() : buildStartScreen(),
            if (gameStarted && !isAnsweredCorrectly) ...[
              _buildHintDisplay(),
              _buildHintButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStartScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20 * _scaleFactor),
                border: Border.all(color: Colors.tealAccent, width: 3 * _scaleFactor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10 * _scaleFactor,
                    offset: Offset(0, 5 * _scaleFactor),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology, color: Colors.yellow, size: 50 * _scaleFactor),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "SQL EXPERT CHALLENGE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5 * _scaleFactor),
                  Text(
                    "Advanced Joins & Complex Queries",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16 * _scaleFactor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30 * _scaleFactor),

            ElevatedButton.icon(
              onPressed: gameConfig != null ? () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('challenge_accept.mp3');
                startGame();
              } : null,
              icon: Icon(Icons.play_arrow, size: 24 * _scaleFactor),
              label: Text(gameConfig != null ? "START EXPERT CHALLENGE" : "Config Missing",
                  style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32 * _scaleFactor, vertical: 16 * _scaleFactor),
                backgroundColor: gameConfig != null ? Colors.teal : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            // Display available hint cards in start screen
            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.teal),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Expert Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Use hint cards for advanced JOIN guidance!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * _scaleFactor,
              ),
            ),

            if (levelCompleted)
              Padding(
                padding: EdgeInsets.only(top: 20 * _scaleFactor),
                child: Container(
                  padding: EdgeInsets.all(16 * _scaleFactor),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * _scaleFactor),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "🏆 SQL EXPERT UNLOCKED!",
                        style: TextStyle(color: Colors.green, fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "Perfect Score: 8/8",
                        style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (hasPreviousScore && previousScore > 0)
              Padding(
                padding: EdgeInsets.only(top: 20 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "📊 Your previous expert score: $previousScore/8",
                      style: TextStyle(color: Colors.teal, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Master complex JOINs and queries to achieve perfection!",
                      style: TextStyle(color: Colors.teal, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (hasPreviousScore && previousScore == 0)
                Padding(
                  padding: EdgeInsets.only(top: 20 * _scaleFactor),
                  child: Column(
                    children: [
                      Text(
                        "💪 Ultimate SQL Challenge Awaits!",
                        style: TextStyle(color: Colors.teal, fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "This is the ultimate test of your SQL mastery!",
                        style: TextStyle(color: Colors.teal, fontSize: 14 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

            SizedBox(height: 30 * _scaleFactor),
            Container(
              padding: EdgeInsets.all(20 * _scaleFactor),
              margin: EdgeInsets.all(16 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.teal[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16 * _scaleFactor),
                border: Border.all(color: Colors.teal[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8 * _scaleFactor,
                    offset: Offset(0, 4 * _scaleFactor),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 EXPERT OBJECTIVE",
                    style: TextStyle(fontSize: 20 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.teal[900]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15 * _scaleFactor),
                  Text(
                    gameConfig?['objective'] ?? "Build a complex SQL query that:\n• Joins multiple tables using INNER JOIN\n• Uses table aliases for clarity\n• Selects specific columns with aliases\n• Filters data with WHERE clause\n• Sorts results with ORDER BY\n• Handles relational database relationships",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.teal[800], height: 1.5),
                  ),
                  SizedBox(height: 15 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(12 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      "🏆 Get perfect score (8/8) to unlock SQL Expert Status!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12 * _scaleFactor,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Database Preview
            SizedBox(height: 20 * _scaleFactor),
            Text(
              "📊 Multiple Database Tables:",
              style: TextStyle(color: Colors.white, fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10 * _scaleFactor),
            _buildDatabaseTables(),
          ],
        ),
      ),
    );
  }

  Widget buildGameUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * _scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('📖 Expert Challenge Story',
                    style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              TextButton.icon(
                onPressed: () {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('toggle.mp3');
                  setState(() {
                    isTagalog = !isTagalog;
                  });
                },
                icon: Icon(Icons.translate, size: 16 * _scaleFactor, color: Colors.white),
                label: Text(isTagalog ? 'English' : 'Tagalog', style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 10 * _scaleFactor),
          Text(
            isTagalog
                ? (gameConfig?['story_tagalog'] ?? 'Ito ay Hard Level ng SQL! Bumuo ng complex query na may JOINs, WHERE clause, at ORDER BY. Ipakita ang iyong mastery sa database programming!')
                : (gameConfig?['story_english'] ?? 'This is SQL Hard Level! Build complex queries with JOINs, WHERE clauses, and ORDER BY. Show your database programming mastery!'),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          // Database Tables Preview
          Text("📊 Multiple Database Tables:", style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          _buildDatabaseTables(),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(color: Colors.tealAccent),
            ),
            child: Text(_instructionText,
                style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 200 * _scaleFactor,
              maxHeight: 300 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.teal, width: 3.0 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.5),
                  blurRadius: 8 * _scaleFactor,
                  offset: Offset(0, 4 * _scaleFactor),
                )
              ],
            ),
            child: DragTarget<String>(
              onWillAccept: (data) {
                return !droppedBlocks.contains(data);
              },
              onAccept: (data) {
                if (!isAnsweredCorrectly) {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_drop.mp3');

                  setState(() {
                    droppedBlocks.add(data);
                    allBlocks.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8 * _scaleFactor,
                      runSpacing: 8 * _scaleFactor,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: droppedBlocks.map((block) {
                        return Draggable<String>(
                          data: block,
                          feedback: Material(
                            color: Colors.transparent,
                            child: puzzleBlock(block, _getSqlBlockColor(block)),
                          ),
                          childWhenDragging: puzzleBlock(block, _getSqlBlockColor(block).withOpacity(0.5)),
                          child: puzzleBlock(block, _getSqlBlockColor(block)),
                          onDragStarted: () {
                            final musicService = Provider.of<MusicService>(context, listen: false);
                            musicService.playSoundEffect('block_pickup.mp3');

                            setState(() {
                              currentlyDraggedBlock = block;
                            });
                          },
                          onDragEnd: (details) {
                            setState(() {
                              currentlyDraggedBlock = null;
                            });

                            if (!isAnsweredCorrectly && !details.wasAccepted) {
                              Future.delayed(Duration(milliseconds: 50), () {
                                if (mounted) {
                                  setState(() {
                                    if (!allBlocks.contains(block)) {
                                      allBlocks.add(block);
                                    }
                                    droppedBlocks.remove(block);
                                  });
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                );
              },
            ),
          ),

          SizedBox(height: 20 * _scaleFactor),
          Text(_codePreviewTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 150 * _scaleFactor,
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(color: Colors.teal.withOpacity(0.5)),
            ),
            child: Wrap(
              spacing: 8 * _scaleFactor,
              runSpacing: 10 * _scaleFactor,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: allBlocks.map((block) {
                return isAnsweredCorrectly
                    ? puzzleBlock(block, Colors.grey)
                    : Draggable<String>(
                  data: block,
                  feedback: Material(
                    color: Colors.transparent,
                    child: puzzleBlock(block, _getSqlBlockColor(block)),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, _getSqlBlockColor(block)),
                  ),
                  child: puzzleBlock(block, _getSqlBlockColor(block)),
                  onDragStarted: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('block_pickup.mp3');

                    setState(() {
                      currentlyDraggedBlock = block;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      currentlyDraggedBlock = null;
                    });

                    if (!isAnsweredCorrectly && !details.wasAccepted) {
                      Future.delayed(Duration(milliseconds: 50), () {
                        if (mounted) {
                          setState(() {
                            if (!allBlocks.contains(block)) {
                              allBlocks.add(block);
                            }
                          });
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 30 * _scaleFactor),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('compile.mp3');
              checkAnswer();
            },
            icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
            label: Text("EXECUTE COMPLEX QUERY", style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 32 * _scaleFactor,
                vertical: 18 * _scaleFactor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
              ),
            ),
          ),

          SizedBox(height: 10 * _scaleFactor),

          TextButton(
            onPressed: () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('button_click.mp3');
              resetGame();
            },
            child: Text("🔄 Restart Challenge", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getSqlBlockColor(String block) {
    if (block == 'SELECT' || block == 'FROM' || block == 'WHERE' || block == 'ORDER BY') {
      return Colors.blue; // SQL keywords
    } else if (block == 'INNER JOIN') {
      return Colors.purple; // JOIN keyword
    } else if (block == 'ON') {
      return Colors.orange; // ON clause
    } else if (block.contains('e.name, d.name AS department, e.salary')) {
      return Colors.amber; // Column list
    } else if (block == 'employees e' || block == 'departments d') {
      return Colors.green; // Table aliases
    } else if (block.contains("d.name = 'IT'")) {
      return Colors.red; // Condition
    } else if (block == 'e.salary DESC') {
      return Colors.deepOrange; // Sort
    } else if (block == ';') {
      return Colors.grey; // Semicolon
    } else if (isIncorrectBlock(block)) {
      return Colors.red[700]!; // Incorrect blocks
    }
    return Colors.teal; // Default
  }

  Widget puzzleBlock(String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 10 * _scaleFactor, // Smaller for complex blocks
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout();

    final textWidth = textPainter.width;
    final minWidth = 80 * _scaleFactor;
    final maxWidth = 300 * _scaleFactor;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      margin: EdgeInsets.symmetric(horizontal: 3 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scaleFactor,
        vertical: 10 * _scaleFactor,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * _scaleFactor),
          bottomRight: Radius.circular(20 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black87, width: 2.0 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6 * _scaleFactor,
            offset: Offset(3 * _scaleFactor, 3 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 10 * _scaleFactor,
          color: Colors.black,
          shadows: [
            Shadow(
              offset: Offset(1 * _scaleFactor, 1 * _scaleFactor),
              blurRadius: 2 * _scaleFactor,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        softWrap: true,
      ),
    );
  }
}