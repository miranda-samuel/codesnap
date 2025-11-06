import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../services/api_service.dart';
import '../../../../services/user_preferences.dart';
import '../../../../services/music_service.dart';
import '../../../../services/daily_challenge_service.dart';

class SqlLevel2Medium extends StatefulWidget {
  const SqlLevel2Medium({super.key});

  @override
  State<SqlLevel2Medium> createState() => _SqlLevel2MediumState();
}

class _SqlLevel2MediumState extends State<SqlLevel2Medium> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool levelCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 180;
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  String? currentlyDraggedBlock;
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  Map<String, dynamic>? gameConfig;
  bool isLoading = true;
  String? errorMessage;

  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  String _codePreviewTitle = '💻 SQL Query Preview:';
  String _instructionText = '🧩 Arrange the blocks to form the correct SQL query with JOIN and aggregation';
  List<String> _codeStructure = [];
  String _expectedOutput = '';

  // Database tables preview for Medium Level 2 with JOIN
  List<Map<String, dynamic>> _employeesTable = [];
  List<Map<String, dynamic>> _departmentsTable = [];
  String _employeesTableName = 'employees';
  String _departmentsTableName = 'departments';

  @override
  void initState() {
    super.initState();
    _loadGameConfig();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
    _loadHintCards();
  }

  Future<void> _loadGameConfig() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService.getGameConfigWithDifficulty('SQL', 'Medium', 2);

      print('🔍 SQL MEDIUM LEVEL 2 GAME CONFIG RESPONSE:');
      print('   Success: ${response['success']}');
      print('   Message: ${response['message']}');

      if (response['success'] == true && response['game'] != null) {
        setState(() {
          gameConfig = response['game'];
          _initializeGameFromConfig();
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load SQL Level 2 configuration from database';
        });
      }
    } catch (e) {
      print('❌ Error loading SQL Level 2 game config: $e');
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
      print('🔄 INITIALIZING SQL MEDIUM LEVEL 2 GAME FROM CONFIG');

      // Load timer duration from database
      if (gameConfig!['timer_duration'] != null) {
        int timerDuration = int.tryParse(gameConfig!['timer_duration'].toString()) ?? 180;
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
            print('❌ Error parsing SQL Level 2 code structure: $e');
            setState(() {
              _codeStructure = _getDefaultCodeStructure();
            });
          }
        }
        print('📝 SQL Level 2 code structure loaded: $_codeStructure');
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

      // Load tables data from database
      _loadTablesData();

      // Load hint from database
      if (gameConfig!['hint_text'] != null) {
        setState(() {
          _currentHint = gameConfig!['hint_text'].toString();
        });
        print('💡 SQL Level 2 hint loaded from database: $_currentHint');
      } else {
        setState(() {
          _currentHint = _getDefaultHint();
        });
        print('💡 Using default SQL Level 2 hint');
      }

      // Parse blocks with better error handling
      List<String> correctBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');
      List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');

      print('✅ SQL Level 2 Correct Blocks from DB: $correctBlocks');
      print('✅ SQL Level 2 Incorrect Blocks from DB: $incorrectBlocks');

      // Combine and shuffle blocks
      allBlocks = [
        ...correctBlocks,
        ...incorrectBlocks,
      ]..shuffle();

      print('🎮 SQL Level 2 All Blocks Final: $allBlocks');

      // DEBUG: Print the expected correct answer from database
      if (gameConfig!['correct_answer'] != null) {
        print('🎯 SQL Level 2 Expected Correct Answer from DB: ${gameConfig!['correct_answer']}');
      }

    } catch (e) {
      print('❌ Error parsing SQL Level 2 game config: $e');
      _initializeDefaultBlocks();
    }
  }

  void _loadTablesData() {
    // Load employees table data
    if (gameConfig!['employees_table'] != null) {
      try {
        String employeesTableStr = gameConfig!['employees_table'].toString();
        List<dynamic> employeesTableJson = json.decode(employeesTableStr);
        setState(() {
          _employeesTable = List<Map<String, dynamic>>.from(employeesTableJson);
        });
        print('📊 Employees table data loaded: ${_employeesTable.length} rows');
      } catch (e) {
        print('❌ Error parsing employees table data: $e');
        setState(() {
          _employeesTable = _getDefaultEmployeesTable();
        });
      }
    } else {
      setState(() {
        _employeesTable = _getDefaultEmployeesTable();
      });
    }

    // Load departments table data
    if (gameConfig!['departments_table'] != null) {
      try {
        String departmentsTableStr = gameConfig!['departments_table'].toString();
        List<dynamic> departmentsTableJson = json.decode(departmentsTableStr);
        setState(() {
          _departmentsTable = List<Map<String, dynamic>>.from(departmentsTableJson);
        });
        print('📊 Departments table data loaded: ${_departmentsTable.length} rows');
      } catch (e) {
        print('❌ Error parsing departments table data: $e');
        setState(() {
          _departmentsTable = _getDefaultDepartmentsTable();
        });
      }
    } else {
      setState(() {
        _departmentsTable = _getDefaultDepartmentsTable();
      });
    }

    // Load table names
    if (gameConfig!['employees_table_name'] != null) {
      setState(() {
        _employeesTableName = gameConfig!['employees_table_name'].toString();
      });
    }
    if (gameConfig!['departments_table_name'] != null) {
      setState(() {
        _departmentsTableName = gameConfig!['departments_table_name'].toString();
      });
    }
  }

  List<String> _getDefaultCodeStructure() {
    return [
      "-- SQL Query to calculate average salary by department",
      "-- Complete the query using JOIN and aggregation",
      "",
      "SELECT d.department_name, AVG(e.salary) as avg_salary",
      "FROM employees e",
      "JOIN departments d ON e.department_id = d.department_id",
      "GROUP BY d.department_name",
      "ORDER BY avg_salary DESC;"
    ];
  }

  List<Map<String, dynamic>> _getDefaultEmployeesTable() {
    return [
      {'employee_id': 1, 'name': 'Juan Dela Cruz', 'department_id': 1, 'salary': 55000},
      {'employee_id': 2, 'name': 'Maria Santos', 'department_id': 2, 'salary': 45000},
      {'employee_id': 3, 'name': 'Pedro Reyes', 'department_id': 1, 'salary': 60000},
      {'employee_id': 4, 'name': 'Ana Lopez', 'department_id': 3, 'salary': 52000},
      {'employee_id': 5, 'name': 'Luis Garcia', 'department_id': 1, 'salary': 48000},
      {'employee_id': 6, 'name': 'Sofia Martinez', 'department_id': 2, 'salary': 47000},
      {'employee_id': 7, 'name': 'Carlos Lim', 'department_id': 3, 'salary': 58000},
    ];
  }

  List<Map<String, dynamic>> _getDefaultDepartmentsTable() {
    return [
      {'department_id': 1, 'department_name': 'Sales'},
      {'department_id': 2, 'department_name': 'HR'},
      {'department_id': 3, 'department_name': 'IT'},
    ];
  }

  List<String> _parseBlocks(dynamic blocksData, String type) {
    List<String> blocks = [];

    if (blocksData == null) {
      print('⚠️ SQL Level 2 $type blocks are NULL in database');
      return _getDefaultBlocks(type);
    }

    try {
      if (blocksData is List) {
        blocks = List<String>.from(blocksData);
        print('✅ SQL Level 2 $type blocks parsed as List: $blocks');
      } else if (blocksData is String) {
        String blocksStr = blocksData.trim();
        print('🔍 Raw SQL Level 2 $type blocks string: $blocksStr');

        if (blocksStr.startsWith('[') && blocksStr.endsWith(']')) {
          // Parse as JSON array
          try {
            List<dynamic> blocksJson = json.decode(blocksStr);
            blocks = List<String>.from(blocksJson);
            print('✅ SQL Level 2 $type blocks parsed as JSON: $blocks');
          } catch (e) {
            print('❌ JSON parsing failed for SQL Level 2 $type blocks: $e');
            // Fallback: try comma separation
            blocks = _parseCommaSeparated(blocksStr);
          }
        } else {
          // Parse as comma-separated string
          blocks = _parseCommaSeparated(blocksStr);
        }
      }
    } catch (e) {
      print('❌ Error parsing SQL Level 2 $type blocks: $e');
      blocks = _getDefaultBlocks(type);
    }

    // Remove any empty strings
    blocks = blocks.where((block) => block.trim().isNotEmpty).toList();

    print('🎯 Final SQL Level 2 $type blocks: $blocks');
    return blocks;
  }

  List<String> _parseCommaSeparated(String input) {
    try {
      // Remove brackets if present
      String cleaned = input.replaceAll('[', '').replaceAll(']', '').trim();

      // Split by comma but handle quoted strings
      List<String> items = [];
      StringBuffer current = StringBuffer();
      bool inQuotes = false;

      for (int i = 0; i < cleaned.length; i++) {
        String char = cleaned[i];

        if (char == '"') {
          inQuotes = !inQuotes;
          current.write(char);
        } else if (char == ',' && !inQuotes) {
          String item = current.toString().trim();
          if (item.isNotEmpty) {
            // Remove surrounding quotes if present
            if (item.startsWith('"') && item.endsWith('"')) {
              item = item.substring(1, item.length - 1);
            }
            items.add(item);
          }
          current.clear();
        } else {
          current.write(char);
        }
      }

      // Add the last item
      String lastItem = current.toString().trim();
      if (lastItem.isNotEmpty) {
        if (lastItem.startsWith('"') && lastItem.endsWith('"')) {
          lastItem = lastItem.substring(1, lastItem.length - 1);
        }
        items.add(lastItem);
      }

      print('✅ SQL Level 2 Comma-separated parsing result: $items');
      return items;
    } catch (e) {
      print('❌ SQL Level 2 Comma-separated parsing failed: $e');
      // Ultimate fallback: simple split
      List<String> fallback = input.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
      print('🔄 Using simple split fallback: $fallback');
      return fallback;
    }
  }

  List<String> _getDefaultBlocks(String type) {
    if (type == 'correct') {
      return [
        'SELECT d.department_name, AVG(e.salary) as avg_salary',
        'FROM employees e',
        'JOIN departments d ON e.department_id = d.department_id',
        'GROUP BY d.department_name',
        'ORDER BY avg_salary DESC;'
      ];
    } else {
      return [
        'SELECT department_name, AVG(salary)',
        'FROM employees',
        'INNER JOIN departments',
        'WHERE e.department_id = d.department_id',
        'GROUP BY department',
        'ORDER BY AVG(salary) DESC',
        'SORT BY avg_salary',
        'AGGREGATE salary BY department'
      ];
    }
  }

  String _getDefaultHint() {
    return "💡 SQL Level 2 Hint: Use JOIN to combine tables, AVG() for average calculation, GROUP BY for aggregation, and ORDER BY for sorting results.";
  }

  void _initializeDefaultBlocks() {
    allBlocks = [
      'SELECT d.department_name, AVG(e.salary) as avg_salary',
      'FROM employees e',
      'JOIN departments d ON e.department_id = d.department_id',
      'GROUP BY d.department_name',
      'ORDER BY avg_salary DESC;',
      'SELECT department_name, AVG(salary)',
      'FROM employees',
      'INNER JOIN departments',
      'WHERE e.department_id = d.department_id',
      'GROUP BY department',
      'ORDER BY AVG(salary) DESC',
      'SORT BY avg_salary',
      'AGGREGATE salary BY department'
    ]..shuffle();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('game_music.mp3');
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
          content: Text('SQL Level 2 configuration not loaded. Please retry.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 180
        : 180;

    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = timerDuration;
      droppedBlocks.clear();
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      resetBlocks();
    });

    print('🎮 SQL MEDIUM LEVEL 2 GAME STARTED - Initial Score: $score, Timer: $timerDuration seconds');
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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 60), (timer) {
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
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 180
        : 180;

    setState(() {
      score = 3;
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
      print('❌ Cannot save SQL Level 2 score: No user ID');
      return;
    }

    try {
      print('💾 SAVING SQL MEDIUM LEVEL 2 SCORE:');
      print('   User ID: ${currentUser!['id']}');
      print('   Language: SQL_Medium');
      print('   Level: 2');
      print('   Score: $score/3');

      final response = await ApiService.saveScoreWithDifficulty(
        currentUser!['id'],
        'SQL',
        'Medium',
        2,
        score,
        score == 3,
      );

      print('📡 SQL LEVEL 2 SERVER RESPONSE: $response');

      if (response['success'] == true) {
        setState(() {
          levelCompleted = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('✅ SQL MEDIUM LEVEL 2 SCORE SAVED SUCCESSFULLY');
      } else {
        print('❌ FAILED TO SAVE SQL LEVEL 2 SCORE: ${response['message']}');
      }
    } catch (e) {
      print('❌ ERROR SAVING SQL MEDIUM LEVEL 2 SCORE: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScoresWithDifficulty(currentUser!['id'], 'SQL', 'Medium');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level2Data = scoresData['2'];

        if (level2Data != null) {
          setState(() {
            previousScore = level2Data['score'] ?? 0;
            levelCompleted = level2Data['completed'] ?? false;
            hasPreviousScore = true;
          });
        }
      }
    } catch (e) {
      print('Error loading SQL medium level 2 score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    if (gameConfig != null) {
      try {
        List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');
        bool isIncorrect = incorrectBlocks.contains(block);
        if (isIncorrect) {
          print('❌ SQL Level 2 Block "$block" is in incorrect blocks list');
        }
        return isIncorrect;
      } catch (e) {
        print('Error checking SQL Level 2 incorrect block: $e');
      }
    }

    // Default incorrect blocks for SQL Medium Level 2
    List<String> incorrectBlocks = [
      'SELECT department_name, AVG(salary)',
      'FROM employees',
      'INNER JOIN departments',
      'WHERE e.department_id = d.department_id',
      'GROUP BY department',
      'ORDER BY AVG(salary) DESC',
      'SORT BY avg_salary',
      'AGGREGATE salary BY department'
    ];
    return incorrectBlocks.contains(block);
  }

  // IMPROVED: SQL Level 2 answer checking logic
  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // DEBUG: Print what we're checking
    print('🔍 CHECKING SQL MEDIUM LEVEL 2 ANSWER:');
    print('   Dropped blocks: $droppedBlocks');
    print('   All blocks: $allBlocks');

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      print('❌ SQL LEVEL 2 HAS INCORRECT BLOCK');
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
            title: Text("💀 Game Over"),
            content: Text("You used incorrect SQL syntax and lost all points!"),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Retry"),
              )
            ],
          ),
        );
      }
      return;
    }

    // IMPROVED SQL LEVEL 2 ANSWER CHECKING LOGIC
    bool isCorrect = false;

    if (gameConfig != null) {
      // Get expected correct blocks from database
      List<String> expectedCorrectBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');

      print('🎯 SQL LEVEL 2 EXPECTED CORRECT BLOCKS: $expectedCorrectBlocks');
      print('🎯 SQL LEVEL 2 USER DROPPED BLOCKS: $droppedBlocks');

      // METHOD 1: Check if user has all correct blocks and no extra correct blocks
      bool hasAllCorrectBlocks = expectedCorrectBlocks.every((block) => droppedBlocks.contains(block));
      bool noExtraCorrectBlocks = droppedBlocks.every((block) => expectedCorrectBlocks.contains(block));

      // METHOD 2: Check string comparison (normalized for SQL)
      String userAnswer = droppedBlocks.join(' ');
      String normalizedUserAnswer = userAnswer
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .replaceAll('"', "'")
          .toLowerCase();

      if (gameConfig!['correct_answer'] != null) {
        String expectedAnswer = gameConfig!['correct_answer'].toString();
        String normalizedExpected = expectedAnswer
            .replaceAll(' ', '')
            .replaceAll('\n', '')
            .replaceAll('"', "'")
            .toLowerCase();

        print('📝 SQL LEVEL 2 USER ANSWER: $userAnswer');
        print('📝 SQL LEVEL 2 NORMALIZED USER: $normalizedUserAnswer');
        print('🎯 SQL LEVEL 2 EXPECTED ANSWER: $expectedAnswer');
        print('🎯 SQL LEVEL 2 NORMALIZED EXPECTED: $normalizedExpected');

        bool stringMatch = normalizedUserAnswer == normalizedExpected;

        // Use both methods for verification
        isCorrect = (hasAllCorrectBlocks && noExtraCorrectBlocks) || stringMatch;

        print('✅ SQL LEVEL 2 BLOCK CHECK: hasAllCorrectBlocks=$hasAllCorrectBlocks, noExtraCorrectBlocks=$noExtraCorrectBlocks');
        print('✅ SQL LEVEL 2 STRING CHECK: stringMatch=$stringMatch');
        print('✅ SQL LEVEL 2 FINAL RESULT: $isCorrect');
      } else {
        // Fallback: only use block comparison
        isCorrect = hasAllCorrectBlocks && noExtraCorrectBlocks;
        print('⚠️ No correct_answer in DB, using block comparison only: $isCorrect');
      }
    } else {
      // Fallback check for SQL Level 2 requirements
      print('⚠️ No SQL Level 2 game config, using fallback check');
      bool hasSelect = droppedBlocks.any((block) => block.toLowerCase().contains('select'));
      bool hasFrom = droppedBlocks.any((block) => block.toLowerCase().contains('from'));
      bool hasJoin = droppedBlocks.any((block) => block.toLowerCase().contains('join'));
      bool hasGroupBy = droppedBlocks.any((block) => block.toLowerCase().contains('group by'));
      bool hasOrderBy = droppedBlocks.any((block) => block.toLowerCase().contains('order by'));

      isCorrect = hasSelect && hasFrom && hasJoin && hasGroupBy && hasOrderBy;
      print('✅ SQL LEVEL 2 FALLBACK CHECK: $isCorrect');
    }

    if (isCorrect) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      if (score == 3) {
        musicService.playSoundEffect('perfect.mp3');
      } else {
        musicService.playSoundEffect('success.mp3');
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct SQL Query!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Excellent work SQL Intermediate Level 2!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've completed SQL Medium Level 2!",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to complete the level!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Query Result:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: _buildQueryResultPreview(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                if (score == 3) {
                  musicService.playSoundEffect('level_complete.mp3');
                  Navigator.pushReplacementNamed(context, '/levels', arguments: {
                    'language': 'SQL',
                    'difficulty': 'Medium'
                  });
                } else {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: {
                    'language': 'SQL',
                    'difficulty': 'Medium'
                  });
                }
              },
              child: Text(score == 3 ? "Back to Levels" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      print('❌ SQL LEVEL 2 ANSWER INCORRECT');
      musicService.playSoundEffect('wrong.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Incorrect SQL arrangement. -1 point. Current score: $score"),
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
            title: Text("💀 Game Over"),
            content: Text("You lost all your points."),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Retry"),
              )
            ],
          ),
        );
      }
    }
  }

  Widget _buildQueryResultPreview() {
    // Calculate average salary by department using JOIN
    Map<String, List<int>> departmentSalaries = {};

    for (var employee in _employeesTable) {
      int? departmentId = employee['department_id'];
      int salary = employee['salary'];

      // Find department name
      String departmentName = "Unknown";
      for (var dept in _departmentsTable) {
        if (dept['department_id'] == departmentId) {
          departmentName = dept['department_name'].toString();
          break;
        }
      }

      if (!departmentSalaries.containsKey(departmentName)) {
        departmentSalaries[departmentName] = [];
      }
      departmentSalaries[departmentName]!.add(salary);
    }

    // Calculate averages and sort by average salary DESC
    List<Map<String, dynamic>> resultData = [];
    departmentSalaries.forEach((deptName, salaries) {
      double avgSalary = salaries.reduce((a, b) => a + b) / salaries.length;
      resultData.add({
        'department_name': deptName,
        'avg_salary': avgSalary.toStringAsFixed(2)
      });
    });

    resultData.sort((a, b) => double.parse(b['avg_salary']).compareTo(double.parse(a['avg_salary'])));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Department', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Avg Salary', style: TextStyle(color: Colors.white))),
        ],
        rows: resultData.map((row) {
          return DataRow(cells: [
            DataCell(Text(row['department_name'].toString(), style: TextStyle(color: Colors.white))),
            DataCell(Text('₱${row['avg_salary']}', style: TextStyle(color: Colors.greenAccent))),
          ]);
        }).toList(),
      ),
    );
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
          color: Colors.orange.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.orangeAccent, width: 2 * _scaleFactor),
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
                Icon(Icons.lightbulb, color: Colors.white, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  '💡 SQL Level 2 Hint Activated!',
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
              'Hint will disappear in 5 seconds...',
              style: TextStyle(
                color: Colors.white,
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
            color: _availableHintCards > 0 ? Colors.orange : Colors.grey,
            borderRadius: BorderRadius.circular(20 * _scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4 * _scaleFactor,
                offset: Offset(0, 2 * _scaleFactor),
              )
            ],
            border: Border.all(
              color: _availableHintCards > 0 ? Colors.orangeAccent : Colors.grey,
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

  // Database Tables Preview Widget for Level 2
  Widget getDatabasePreview() {
    return Column(
      children: [
        // Employees Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8 * _scaleFactor),
            border: Border.all(color: Colors.grey[700]!),
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
                    Icon(Icons.storage, color: Colors.grey[400], size: 16 * _scaleFactor),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                      'Table: $_employeesTableName',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 32 * _scaleFactor,
                    headingRowHeight: 40 * _scaleFactor,
                    columns: [
                      DataColumn(
                        label: Text('employee_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('name', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('department_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('salary', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: _employeesTable.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['employee_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['name'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['department_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['salary'].toString(), style: TextStyle(color: Colors.greenAccent))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * _scaleFactor),

        // Departments Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8 * _scaleFactor),
            border: Border.all(color: Colors.grey[700]!),
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
                    Icon(Icons.storage, color: Colors.grey[400], size: 16 * _scaleFactor),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                      'Table: $_departmentsTableName',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 32 * _scaleFactor,
                    headingRowHeight: 40 * _scaleFactor,
                    columns: [
                      DataColumn(
                        label: Text('department_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('department_name', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: _departmentsTable.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['department_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['department_name'].toString(), style: TextStyle(color: Colors.white))),
                      ]);
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

  // Organized SQL code preview for Level 2
  Widget getCodePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8 * _scaleFactor),
        border: Border.all(color: Colors.grey[700]!),
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
                  'query_level2.sql',
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
              children: _buildOrganizedSQLPreview(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrganizedSQLPreview() {
    List<Widget> codeLines = [];

    for (int i = 0; i < _codeStructure.length; i++) {
      String line = _codeStructure[i];

      if (line.contains('-- Complete the query using JOIN and aggregation')) {
        // Add user's dragged SQL code in the correct position
        codeLines.add(_buildUserSQLSection());
      } else if (line.trim().isEmpty) {
        codeLines.add(SizedBox(height: 16 * _scaleFactor));
      } else {
        codeLines.add(_buildSQLSyntaxHighlightedLine(line, i + 1));
      }
    }

    return codeLines;
  }

  Widget _buildUserSQLSection() {
    if (droppedBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          '-- Drag SQL blocks here to build your JOIN query...',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (String block in droppedBlocks)
            Container(
              margin: EdgeInsets.only(bottom: 4 * _scaleFactor),
              child: Text(
                block,
                style: TextStyle(
                  color: Colors.greenAccent[400],
                  fontSize: 12 * _scaleFactor,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSQLSyntaxHighlightedLine(String code, int lineNumber) {
    Color textColor = Colors.white;
    String displayCode = code;

    // SQL Syntax highlighting rules for Level 2
    if (code.trim().startsWith('--')) {
      textColor = Color(0xFF6A9955); // Comments - green
    } else if (code.toUpperCase().contains('SELECT') ||
        code.toUpperCase().contains('FROM') ||
        code.toUpperCase().contains('JOIN') ||
        code.toUpperCase().contains('ON') ||
        code.toUpperCase().contains('GROUP BY') ||
        code.toUpperCase().contains('ORDER BY') ||
        code.toUpperCase().contains('DESC') ||
        code.toUpperCase().contains('AVG')) {
      textColor = Color(0xFF569CD6); // SQL Keywords - blue
    } else if (code.contains('"') || code.contains("'")) {
      textColor = Color(0xFFCE9178); // Strings - orange
    } else if (code.contains('.')) {
      textColor = Color(0xFFDCDCAA); // Table aliases - yellow
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
          title: Text("⚡ SQL Medium - Level 2", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.orange,
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
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  "Loading SQL Medium Level 2 Configuration...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "From Database",
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
          title: Text("⚡ SQL Medium - Level 2", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.orange,
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
                  Icon(Icons.warning_amber, color: Colors.orange, size: 50),
                  SizedBox(height: 20),
                  Text(
                    "SQL Level 2 Configuration Warning",
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text("Retry Loading"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/levels', arguments: {
                        'language': 'SQL',
                        'difficulty': 'Medium'
                      });
                    },
                    child: Text("Back to Levels", style: TextStyle(color: Colors.orange)),
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
        title: Text("⚡ SQL Medium - Level 2", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.orange,
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
            ElevatedButton.icon(
              onPressed: gameConfig != null ? () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                startGame();
              } : null,
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text(gameConfig != null ? "Start" : "Config Missing", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: gameConfig != null ? Colors.orange : Colors.grey,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Use hint cards during the game for SQL help!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * _scaleFactor,
              ),
            ),

            if (levelCompleted)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ SQL Level 2 Medium completed with perfect score!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "You've mastered SQL Medium difficulty!",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (hasPreviousScore && previousScore > 0)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "📊 Your previous SQL Level 2 score: $previousScore/3",
                      style: TextStyle(color: Colors.orange, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Try again to get a perfect score and complete the level!",
                      style: TextStyle(color: Colors.orange, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (hasPreviousScore && previousScore == 0)
                Padding(
                  padding: EdgeInsets.only(top: 10 * _scaleFactor),
                  child: Column(
                    children: [
                      Text(
                        "😅 Your previous SQL Level 2 score: $previousScore/3",
                        style: TextStyle(color: Colors.red, fontSize: 16 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "Don't give up! You can do better this time!",
                        style: TextStyle(color: Colors.orange, fontSize: 14 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

            SizedBox(height: 30 * _scaleFactor),
            Container(
              padding: EdgeInsets.all(16 * _scaleFactor),
              margin: EdgeInsets.all(16 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.orange[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 SQL Medium Level 2 Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn to write SQL queries with JOIN operations, aggregate functions (AVG), GROUP BY, and complex sorting",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.orange[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🎁 Get a perfect score (3/3) to complete SQL Medium Level 2!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🏆 2× POINTS MULTIPLIER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
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
                child: Text('📖 SQL Level 2 Short Story', style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
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
                ? (gameConfig?['story_tagalog'] ?? 'Ito ay Medium Level 2 ng SQL! Hamon sa JOIN operations, aggregate functions, at complex queries.')
                : (gameConfig?['story_english'] ?? 'This is SQL Medium Level 2! Challenge yourself with JOIN operations, aggregate functions, and complex queries.'),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text(_instructionText,
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // Database Tables Preview
          Text("📊 Database Tables Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getDatabasePreview(),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 140 * _scaleFactor,
              maxHeight: 200 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.orange, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
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
                          child: puzzleBlock(block, Colors.orangeAccent),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.orangeAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.orangeAccent),
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
              minHeight: 100 * _scaleFactor,
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
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
                    child: puzzleBlock(block, Colors.orange),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.orange),
                  ),
                  child: puzzleBlock(block, Colors.orange),
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
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Execute Query", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * _scaleFactor,
                vertical: 16 * _scaleFactor,
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
            child: Text("🔁 Retry", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget puzzleBlock(String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 12 * _scaleFactor,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout();

    final textWidth = textPainter.width;
    final minWidth = 80 * _scaleFactor;
    final maxWidth = 240 * _scaleFactor;

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
          fontSize: 12 * _scaleFactor,
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