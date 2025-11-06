import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../services/api_service.dart';
import '../../../../services/user_preferences.dart';
import '../../../../services/music_service.dart';
import '../../../../services/daily_challenge_service.dart';

class PhpLevel3Hard extends StatefulWidget {
  const PhpLevel3Hard({super.key});

  @override
  State<PhpLevel3Hard> createState() => _PhpLevel3HardState();
}

class _PhpLevel3HardState extends State<PhpLevel3Hard> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool levelCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 360; // 6 minutes for expert level
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

  String _codePreviewTitle = '💻 Expert PHP OOP & Database Challenge:';
  String _instructionText = '🧩 Create a PHP class that handles database operations with PDO and error handling';
  List<String> _codeStructure = [];
  String _expectedOutput = '';

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

      final response = await ApiService.getGameConfigWithDifficulty('PHP', 'Hard', 3);

      print('🔍 PHP HARD LEVEL 3 GAME CONFIG RESPONSE:');
      print('   Success: ${response['success']}');
      print('   Message: ${response['message']}');

      if (response['success'] == true && response['game'] != null) {
        setState(() {
          gameConfig = response['game'];
          _initializeGameFromConfig();
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load PHP Hard Level 3 configuration from database';
        });
      }
    } catch (e) {
      print('❌ Error loading PHP Hard Level 3 game config: $e');
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
      print('🔄 INITIALIZING PHP HARD LEVEL 3 GAME FROM CONFIG');

      // Load timer duration from database
      if (gameConfig!['timer_duration'] != null) {
        int timerDuration = int.tryParse(gameConfig!['timer_duration'].toString()) ?? 360;
        setState(() {
          remainingSeconds = timerDuration;
        });
        print('⏰ Hard Level 3 Timer duration loaded: $timerDuration seconds');
      }

      // Load instruction text from database
      if (gameConfig!['instruction_text'] != null) {
        setState(() {
          _instructionText = gameConfig!['instruction_text'].toString();
        });
        print('📝 Hard Level 3 Instruction text loaded: $_instructionText');
      }

      // Load code preview title from database
      if (gameConfig!['code_preview_title'] != null) {
        setState(() {
          _codePreviewTitle = gameConfig!['code_preview_title'].toString();
        });
        print('💻 Hard Level 3 Code preview title loaded: $_codePreviewTitle');
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
            print('❌ Error parsing PHP Hard Level 3 code structure: $e');
            setState(() {
              _codeStructure = _getDefaultCodeStructure();
            });
          }
        }
        print('📝 PHP Hard Level 3 Code structure loaded: $_codeStructure');
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
        print('🎯 Hard Level 3 Expected output loaded: $_expectedOutput');
      }

      // Load hint from database
      if (gameConfig!['hint_text'] != null) {
        setState(() {
          _currentHint = gameConfig!['hint_text'].toString();
        });
        print('💡 PHP Hard Level 3 Hint loaded from database: $_currentHint');
      } else {
        setState(() {
          _currentHint = _getDefaultHint();
        });
        print('💡 Using default PHP Hard Level 3 hint');
      }

      // Parse blocks with improved error handling
      List<String> correctBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');
      List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');

      print('✅ PHP Hard Level 3 Correct Blocks from DB: $correctBlocks');
      print('✅ PHP Hard Level 3 Incorrect Blocks from DB: $incorrectBlocks');

      // Combine and shuffle blocks
      allBlocks = [
        ...correctBlocks,
        ...incorrectBlocks,
      ]..shuffle();

      print('🎮 PHP Hard Level 3 All Blocks Final: $allBlocks');

      // DEBUG: Print the expected correct answer from database
      if (gameConfig!['correct_answer'] != null) {
        print('🎯 PHP Hard Level 3 Expected Correct Answer from DB: ${gameConfig!['correct_answer']}');
      }

    } catch (e) {
      print('❌ Error parsing PHP Hard Level 3 game config: $e');
      _initializeDefaultBlocks();
    }
  }

  List<String> _getDefaultCodeStructure() {
    return [
      "<?php",
      "",
      "class DatabaseHandler {",
      "    private \$pdo;",
      "    ",
      "    public function __construct(\$host, \$dbname, \$username, \$password) {",
      "        // Your constructor code here",
      "    }",
      "    ",
      "    public function getUserById(\$id) {",
      "        // Your method code here",
      "    }",
      "    ",
      "    public function closeConnection() {",
      "        // Your cleanup code here",
      "    }",
      "}",
      "",
      "// Usage example:",
      "// \$db = new DatabaseHandler('localhost', 'myapp', 'user', 'pass');",
      "// \$user = \$db->getUserById(1);",
      "// \$db->closeConnection();",
      "",
      "?>"
    ];
  }

  List<String> _parseBlocks(dynamic blocksData, String type) {
    List<String> blocks = [];

    if (blocksData == null) {
      print('⚠️ PHP Hard Level 3 $type blocks are NULL in database');
      return _getDefaultBlocks(type);
    }

    try {
      if (blocksData is List) {
        // Direct list handling
        blocks = List<String>.from(blocksData.map((item) => item.toString().trim()));
        print('✅ PHP Hard Level 3 $type blocks parsed as List: $blocks');
      } else if (blocksData is String) {
        String blocksStr = blocksData.trim();
        print('🔍 Raw PHP Hard Level 3 $type blocks string: "$blocksStr"');

        // Try JSON parsing first
        if (blocksStr.startsWith('[') && blocksStr.endsWith(']')) {
          try {
            List<dynamic> blocksJson = json.decode(blocksStr);
            blocks = List<String>.from(blocksJson.map((item) => item.toString().trim()));
            print('✅ PHP Hard Level 3 $type blocks parsed as JSON: $blocks');
          } catch (e) {
            print('❌ JSON parsing failed for PHP Hard Level 3 $type blocks: $e');
            // Fallback to manual parsing
            blocks = _parseManual(blocksStr);
          }
        } else {
          // Manual parsing for comma-separated or other formats
          blocks = _parseManual(blocksStr);
        }
      }
    } catch (e) {
      print('❌ Error parsing PHP Hard Level 3 $type blocks: $e');
      print('🔄 Using default PHP Hard Level 3 blocks for $type');
      blocks = _getDefaultBlocks(type);
    }

    // Remove any empty strings and ensure proper formatting
    blocks = blocks
        .where((block) => block.trim().isNotEmpty)
        .map((block) => block.trim())
        .toList();

    print('🎯 Final PHP Hard Level 3 $type blocks (${blocks.length}): $blocks');
    return blocks;
  }

  List<String> _parseManual(String input) {
    try {
      // Clean the input - remove brackets and extra quotes
      String cleaned = input.replaceAll('[', '').replaceAll(']', '').trim();

      // Handle both quoted and unquoted strings
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      // Split by comma but be careful with commas inside quotes
      List<String> items = [];
      StringBuffer current = StringBuffer();
      bool inQuotes = false;
      bool escapeNext = false;

      for (int i = 0; i < cleaned.length; i++) {
        String char = cleaned[i];

        if (escapeNext) {
          current.write(char);
          escapeNext = false;
        } else if (char == '\\') {
          escapeNext = true;
        } else if (char == '"') {
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

      print('✅ Manual parsing result: $items');
      return items;
    } catch (e) {
      print('❌ Manual parsing failed: $e');
      // Ultimate fallback: simple split and clean
      List<String> fallback = input.split(',')
          .map((item) => item.trim().replaceAll('"', ''))
          .where((item) => item.isNotEmpty)
          .toList();
      print('🔄 Using simple split fallback: $fallback');
      return fallback;
    }
  }

  List<String> _getDefaultBlocks(String type) {
    if (type == 'correct') {
      return [
        'try {',
        '\$this->pdo = new PDO("mysql:host=\$host;dbname=\$dbname", \$username, \$password);',
        '\$this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);',
        '} catch (PDOException \$e) {',
        'throw new Exception("Database connection failed: " . \$e->getMessage());',
        '}',
        '\$stmt = \$this->pdo->prepare("SELECT * FROM users WHERE id = :id");',
        '\$stmt->bindParam(\':id\', \$id, PDO::PARAM_INT);',
        '\$stmt->execute();',
        'return \$stmt->fetch(PDO::FETCH_ASSOC);',
        'if (\$this->pdo !== null) {',
        '\$this->pdo = null;',
        '}'
      ];
    } else {
      return [
        'mysql_connect(\$host, \$username, \$password);',
        'mysql_select_db(\$dbname);',
        '\$result = mysql_query("SELECT * FROM users WHERE id = \$id");',
        'return mysql_fetch_array(\$result);',
        '\$this->pdo->query("SELECT * FROM users WHERE id = \$id");',
        'mysql_close();',
        'echo "Connection closed";'
      ];
    }
  }

  String _getDefaultHint() {
    return "💡 PHP Hard Level 3 Hint: Use PDO for database connections with try-catch blocks. Always use prepared statements to prevent SQL injection. Implement proper error handling and connection cleanup.";
  }

  void _initializeDefaultBlocks() {
    allBlocks = [
      'try {',
      '\$this->pdo = new PDO("mysql:host=\$host;dbname=\$dbname", \$username, \$password);',
      '\$this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);',
      '} catch (PDOException \$e) {',
      'throw new Exception("Database connection failed: " . \$e->getMessage());',
      '}',
      '\$stmt = \$this->pdo->prepare("SELECT * FROM users WHERE id = :id");',
      '\$stmt->bindParam(\':id\', \$id, PDO::PARAM_INT);',
      '\$stmt->execute();',
      'return \$stmt->fetch(PDO::FETCH_ASSOC);',
      'if (\$this->pdo !== null) {',
      '\$this->pdo = null;',
      '}',
      'mysql_connect(\$host, \$username, \$password);',
      'mysql_select_db(\$dbname);',
      '\$result = mysql_query("SELECT * FROM users WHERE id = \$id");',
      'return mysql_fetch_array(\$result);',
      '\$this->pdo->query("SELECT * FROM users WHERE id = \$id");',
      'mysql_close();',
      'echo "Connection closed";'
    ]..shuffle();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('expert_music.mp3');
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
          backgroundColor: Colors.deepPurple,
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
          content: Text('PHP Hard Level 3 configuration not loaded. Please retry.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 360
        : 360;

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

    print('🎮 PHP HARD LEVEL 3 GAME STARTED - Initial Score: $score, Timer: $timerDuration seconds');
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

    // More frequent score reduction for expert level
    scoreReductionTimer = Timer.periodic(Duration(seconds: 45), (timer) {
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
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 360
        : 360;

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
      print('❌ Cannot save PHP Hard Level 3 score: No user ID');
      return;
    }

    try {
      print('💾 SAVING PHP HARD LEVEL 3 SCORE:');
      print('   User ID: ${currentUser!['id']}');
      print('   Language: PHP_Hard');
      print('   Level: 3');
      print('   Score: $score/3');

      final response = await ApiService.saveScoreWithDifficulty(
        currentUser!['id'],
        'PHP',
        'Hard',
        3,
        score,
        score == 3,
      );

      print('📡 PHP HARD LEVEL 3 SERVER RESPONSE: $response');

      if (response['success'] == true) {
        setState(() {
          levelCompleted = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('✅ PHP HARD LEVEL 3 SCORE SAVED SUCCESSFULLY');
      } else {
        print('❌ FAILED TO SAVE PHP HARD LEVEL 3 SCORE: ${response['message']}');
      }
    } catch (e) {
      print('❌ ERROR SAVING PHP HARD LEVEL 3 SCORE: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScoresWithDifficulty(currentUser!['id'], 'PHP', 'Hard');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level3Data = scoresData['3'];

        if (level3Data != null) {
          setState(() {
            previousScore = level3Data['score'] ?? 0;
            levelCompleted = level3Data['completed'] ?? false;
            hasPreviousScore = true;
          });
        }
      }
    } catch (e) {
      print('Error loading PHP Hard Level 3 score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    if (gameConfig != null) {
      try {
        List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');
        bool isIncorrect = incorrectBlocks.contains(block);
        if (isIncorrect) {
          print('❌ PHP Hard Level 3 Block "$block" is in incorrect blocks list');
        }
        return isIncorrect;
      } catch (e) {
        print('Error checking PHP Hard Level 3 incorrect block: $e');
      }
    }

    // Default PHP Hard Level 3 incorrect blocks
    List<String> incorrectBlocks = [
      'mysql_connect(\$host, \$username, \$password);',
      'mysql_select_db(\$dbname);',
      '\$result = mysql_query("SELECT * FROM users WHERE id = \$id");',
      'return mysql_fetch_array(\$result);',
      '\$this->pdo->query("SELECT * FROM users WHERE id = \$id");',
      'mysql_close();',
      'echo "Connection closed";'
    ];
    return incorrectBlocks.contains(block);
  }

  // EXPERT ANSWER CHECKING LOGIC FOR PHP HARD LEVEL 3
  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    print('🔍 CHECKING PHP HARD LEVEL 3 ANSWER:');
    print('   Dropped blocks: $droppedBlocks');
    print('   All blocks: $allBlocks');

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      print('❌ PHP HARD LEVEL 3 HAS INCORRECT BLOCK');
      musicService.playSoundEffect('error.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ You used deprecated or insecure PHP code! -1 point. Current score: $score"),
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
            content: Text("You used deprecated mysql_* functions or SQL injection vulnerable code!"),
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

    // EXPERT ANSWER CHECKING LOGIC FOR PHP HARD LEVEL 3
    bool isCorrect = false;

    if (gameConfig != null) {
      // Get expected correct blocks from database
      List<String> expectedCorrectBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');

      print('🎯 PHP HARD LEVEL 3 EXPECTED CORRECT BLOCKS: $expectedCorrectBlocks');
      print('🎯 PHP HARD LEVEL 3 USER DROPPED BLOCKS: $droppedBlocks');

      // METHOD 1: Check if user has all correct blocks and no extra correct blocks
      bool hasAllCorrectBlocks = expectedCorrectBlocks.every((block) => droppedBlocks.contains(block));
      bool noExtraCorrectBlocks = droppedBlocks.every((block) => expectedCorrectBlocks.contains(block));

      // METHOD 2: Check expert OOP and security requirements
      bool hasTryCatch = droppedBlocks.any((block) => block.contains('try {'));
      bool hasPDOConnection = droppedBlocks.any((block) => block.contains('new PDO'));
      bool hasErrorMode = droppedBlocks.any((block) => block.contains('PDO::ATTR_ERRMODE'));
      bool hasPreparedStatement = droppedBlocks.any((block) => block.contains('prepare('));
      bool hasBindParam = droppedBlocks.any((block) => block.contains('bindParam'));
      bool hasExecute = droppedBlocks.any((block) => block.contains('execute()'));
      bool hasFetch = droppedBlocks.any((block) => block.contains('fetch('));
      bool hasConnectionCleanup = droppedBlocks.any((block) => block.contains('\$this->pdo = null'));

      // METHOD 3: Check string comparison (normalized)
      String userAnswer = droppedBlocks.join(' ');
      String normalizedUserAnswer = userAnswer
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .replaceAll('\t', '')
          .toLowerCase();

      if (gameConfig!['correct_answer'] != null) {
        String expectedAnswer = gameConfig!['correct_answer'].toString();
        String normalizedExpected = expectedAnswer
            .replaceAll(' ', '')
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .toLowerCase();

        print('📝 PHP HARD LEVEL 3 USER ANSWER: $userAnswer');
        print('📝 PHP HARD LEVEL 3 NORMALIZED USER: $normalizedUserAnswer');
        print('🎯 PHP HARD LEVEL 3 EXPECTED ANSWER: $expectedAnswer');
        print('🎯 PHP HARD LEVEL 3 NORMALIZED EXPECTED: $normalizedExpected');

        bool stringMatch = normalizedUserAnswer == normalizedExpected;

        // Use multiple methods for verification - expert level 3 requires security and OOP
        isCorrect = (hasAllCorrectBlocks && noExtraCorrectBlocks) ||
            (stringMatch && hasTryCatch && hasPDOConnection && hasPreparedStatement && hasBindParam);

        print('✅ PHP HARD LEVEL 3 BLOCK CHECK: hasAllCorrectBlocks=$hasAllCorrectBlocks, noExtraCorrectBlocks=$noExtraCorrectBlocks');
        print('✅ PHP HARD LEVEL 3 SECURITY CHECK: tryCatch=$hasTryCatch, PDO=$hasPDOConnection, prepared=$hasPreparedStatement, bind=$hasBindParam');
        print('✅ PHP HARD LEVEL 3 STRING CHECK: stringMatch=$stringMatch');
        print('✅ PHP HARD LEVEL 3 FINAL RESULT: $isCorrect');

        // DEBUG: If still incorrect, show what's missing
        if (!isCorrect) {
          List<String> missingBlocks = expectedCorrectBlocks.where((block) => !droppedBlocks.contains(block)).toList();
          List<String> extraBlocks = droppedBlocks.where((block) => !expectedCorrectBlocks.contains(block)).toList();
          print('🔍 DEBUG - Missing blocks: $missingBlocks');
          print('🔍 DEBUG - Extra blocks: $extraBlocks');
        }
      } else {
        // Fallback: use security and OOP structure check for hard level 3
        isCorrect = hasTryCatch && hasPDOConnection && hasErrorMode && hasPreparedStatement &&
            hasBindParam && hasExecute && hasFetch && hasConnectionCleanup;
        print('⚠️ No PHP Hard Level 3 correct_answer in DB, using security comparison only: $isCorrect');
      }
    } else {
      // Fallback check for expert PHP Level 3 requirements
      print('⚠️ No PHP Hard Level 3 game config, using expert fallback check');
      bool hasTryCatch = droppedBlocks.any((block) => block.contains('try {'));
      bool hasPDOConnection = droppedBlocks.any((block) => block.contains('new PDO'));
      bool hasErrorMode = droppedBlocks.any((block) => block.contains('PDO::ATTR_ERRMODE'));
      bool hasPreparedStatement = droppedBlocks.any((block) => block.contains('prepare('));
      bool hasBindParam = droppedBlocks.any((block) => block.contains('bindParam'));
      bool hasExecute = droppedBlocks.any((block) => block.contains('execute()'));
      bool hasFetch = droppedBlocks.any((block) => block.contains('fetch('));
      bool hasConnectionCleanup = droppedBlocks.any((block) => block.contains('\$this->pdo = null'));

      isCorrect = hasTryCatch && hasPDOConnection && hasErrorMode && hasPreparedStatement &&
          hasBindParam && hasExecute && hasFetch && hasConnectionCleanup;
      print('✅ PHP HARD LEVEL 3 FALLBACK CHECK: $isCorrect');
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
          title: Text("🏆 PHP Expert Achieved!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Database OOP Mastery Completed!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've mastered PHP Hard Level 3!",
                  style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to complete the PHP Hard track!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Security Features Implemented:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("✓ PDO with prepared statements", style: TextStyle(color: Colors.green, fontSize: 12)),
                    Text("✓ SQL injection protection", style: TextStyle(color: Colors.green, fontSize: 12)),
                    Text("✓ Proper error handling", style: TextStyle(color: Colors.green, fontSize: 12)),
                    Text("✓ Connection cleanup", style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "🎯 You are now a PHP Security & OOP Expert!",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
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
                    'language': 'PHP',
                    'difficulty': 'Hard',
                    'completed': true
                  });
                } else {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: {
                    'language': 'PHP',
                    'difficulty': 'Hard'
                  });
                }
              },
              child: Text(score == 3 ? "Complete PHP Hard" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      print('❌ PHP HARD LEVEL 3 ANSWER INCORRECT');
      musicService.playSoundEffect('wrong.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Insecure or incomplete database implementation. -1 point. Current score: $score"),
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
            title: Text("💀 Security Risk Detected"),
            content: Text("Your database implementation has security vulnerabilities or missing error handling!"),
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
          color: Colors.deepPurple.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.purpleAccent, width: 2 * _scaleFactor),
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
                Icon(Icons.security, color: Colors.white, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  '🔒 PHP Security Expert Hint Activated!',
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
              'Security hint will disappear in 5 seconds...',
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
            color: _availableHintCards > 0 ? Colors.deepPurple : Colors.grey,
            borderRadius: BorderRadius.circular(20 * _scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4 * _scaleFactor,
                offset: Offset(0, 2 * _scaleFactor),
              )
            ],
            border: Border.all(
              color: _availableHintCards > 0 ? Colors.purpleAccent : Colors.grey,
              width: 2 * _scaleFactor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security, color: Colors.white, size: 20 * _scaleFactor),
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

  // Expert PHP OOP code preview for hard level 3
  Widget getCodePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8 * _scaleFactor),
        border: Border.all(color: Colors.deepPurple),
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
                Icon(Icons.storage, color: Colors.purpleAccent, size: 16 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  'database_handler.php',
                  style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 12 * _scaleFactor,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12 * _scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildExpertCodePreview(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpertCodePreview() {
    List<Widget> codeLines = [];

    for (int i = 0; i < _codeStructure.length; i++) {
      String line = _codeStructure[i];

      if (line.contains('// Your constructor code here')) {
        // Add user's dragged constructor code
        codeLines.add(_buildUserConstructorCodeSection());
      } else if (line.contains('// Your method code here')) {
        // Add user's dragged method code
        codeLines.add(_buildUserMethodCodeSection());
      } else if (line.contains('// Your cleanup code here')) {
        // Add user's dragged cleanup code
        codeLines.add(_buildUserCleanupCodeSection());
      } else if (line.trim().isEmpty) {
        codeLines.add(SizedBox(height: 16 * _scaleFactor));
      } else {
        codeLines.add(_buildExpertPHPSyntaxHighlightedLine(line, i + 1));
      }
    }

    return codeLines;
  }

  Widget _buildUserConstructorCodeSection() {
    List<String> constructorBlocks = droppedBlocks.where((block) =>
    block.contains('PDO') || block.contains('try') || block.contains('catch')).toList();

    if (constructorBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          '        // Drag PDO connection code here',
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
          for (String block in constructorBlocks)
            Container(
              margin: EdgeInsets.only(bottom: 4 * _scaleFactor),
              child: Text(
                '        $block',
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

  Widget _buildUserMethodCodeSection() {
    List<String> methodBlocks = droppedBlocks.where((block) =>
    block.contains('prepare') || block.contains('bindParam') ||
        block.contains('execute') || block.contains('fetch')).toList();

    if (methodBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          '        // Drag database query code here',
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
          for (String block in methodBlocks)
            Container(
              margin: EdgeInsets.only(bottom: 4 * _scaleFactor),
              child: Text(
                '        $block',
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

  Widget _buildUserCleanupCodeSection() {
    List<String> cleanupBlocks = droppedBlocks.where((block) =>
        block.contains('pdo = null')).toList();

    if (cleanupBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          '        // Drag connection cleanup code here',
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
          for (String block in cleanupBlocks)
            Container(
              margin: EdgeInsets.only(bottom: 4 * _scaleFactor),
              child: Text(
                '        $block',
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

  Widget _buildExpertPHPSyntaxHighlightedLine(String code, int lineNumber) {
    Color textColor = Colors.white;
    String displayCode = code;

    // Expert PHP OOP Syntax highlighting rules
    if (code.trim().startsWith('<?php') || code.trim().startsWith('?>')) {
      textColor = Color(0xFF569CD6); // PHP tags - blue
    } else if (code.trim().startsWith('class')) {
      textColor = Color(0xFF4EC9B0); // Class declaration - teal
    } else if (code.trim().contains('private') || code.trim().contains('public')) {
      textColor = Color(0xFF569CD6); // Access modifiers - blue
    } else if (code.trim().startsWith('function')) {
      textColor = Color(0xFFDCDCAA); // Function declaration - yellow
    } else if (code.trim().contains('__construct')) {
      textColor = Color(0xFF4EC9B0); // Constructor - teal
    } else if (code.contains('try') || code.contains('catch')) {
      textColor = Color(0xFFC586C0); // Exception handling - pink
    } else if (code.contains('PDO') || code.contains('new PDO')) {
      textColor = Color(0xFF4EC9B0); // PDO classes - teal
    } else if (code.contains('prepare') || code.contains('bindParam') || code.contains('execute')) {
      textColor = Color(0xFFDCDCAA); // Database methods - yellow
    } else if (code.trim().startsWith('//')) {
      textColor = Color(0xFF6A9955); // Comments - green
    } else if (code.contains('\$this')) {
      textColor = Color(0xFF9CDCFE); // This reference - light blue
    } else if (code.contains('throw')) {
      textColor = Color(0xFFC586C0); // Throw statement - pink
    } else if (code.contains('return')) {
      textColor = Color(0xFF569CD6); // Return statement - blue
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
          title: Text("⚡ PHP Hard - Level 3", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.deepPurple,
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
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 20),
                Text(
                  "Loading PHP Hard Level 3 Configuration...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Expert OOP & Database Security Challenge",
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
          title: Text("⚡ PHP Hard - Level 3", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.deepPurple,
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
                  Icon(Icons.warning_amber, color: Colors.deepPurple, size: 50),
                  SizedBox(height: 20),
                  Text(
                    "PHP Hard Level 3 Configuration Warning",
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: Text("Retry Loading"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/levels', arguments: {
                        'language': 'PHP',
                        'difficulty': 'Hard'
                      });
                    },
                    child: Text("Back to Levels", style: TextStyle(color: Colors.deepPurple)),
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
        title: Text("⚡ PHP Hard - Level 3", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.deepPurple,
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
                musicService.playSoundEffect('challenge_start.mp3');
                startGame();
              } : null,
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text(gameConfig != null ? "Start Expert Challenge" : "Config Missing", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: gameConfig != null ? Colors.deepPurple : Colors.grey,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: Colors.purpleAccent, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Security Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 16 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Use hint cards for PHP security & OOP guidance!',
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
                      "🏆 PHP Hard Track Completed!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "You've mastered PHP OOP & Security!",
                      style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      "📊 Your previous PHP Hard Level 3 score: $previousScore/3",
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Complete perfectly to finish the PHP Hard track!",
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 14 * _scaleFactor),
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
                        "🔒 Ultimate PHP Security Challenge!",
                        style: TextStyle(color: Colors.orange, fontSize: 16 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "OOP, PDO, and SQL injection protection!",
                        style: TextStyle(color: Colors.purpleAccent, fontSize: 14 * _scaleFactor),
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
                color: Colors.deepPurple[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.deepPurple[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    gameConfig?['objective'] ?? "🎯 PHP Hard Level 3: OOP & Database Security Mastery",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.deepPurple[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    gameConfig?['objective'] ?? "Create a secure PHP database handler class using PDO, prepared statements, and proper error handling to prevent SQL injection",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.deepPurple[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🔒 SECURITY-FOCUSED CHALLENGE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 5 * _scaleFactor),
                  Text(
                    "⏰ Extended Time: 6 Minutes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "⚠️ Using deprecated mysql_* functions will fail the challenge!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.red,
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
                child: Text('🔒 PHP Security & OOP Master Challenge', style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
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
                ? (gameConfig?['story_tagalog'] ?? 'Ito ay Hard Level 3 ng PHP programming! Hamon sa OOP, database security, at SQL injection protection.')
                : (gameConfig?['story_english'] ?? 'This is PHP Hard Level 3! Master OOP principles, PDO database connections, and SQL injection protection with prepared statements.'),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text(_instructionText,
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 180 * _scaleFactor,
              maxHeight: 250 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.deepPurple, width: 3 * _scaleFactor),
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
                          child: puzzleBlock(block, Colors.deepPurpleAccent),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.deepPurpleAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.deepPurpleAccent),
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
              minHeight: 140 * _scaleFactor,
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
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
                    child: puzzleBlock(block, Colors.deepPurple),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.deepPurple),
                  ),
                  child: puzzleBlock(block, Colors.deepPurple),
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
            icon: Icon(Icons.security, size: 18 * _scaleFactor),
            label: Text("Validate Security Implementation", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
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
            child: Text("🔄 Restart Challenge", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
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
          fontSize: 11 * _scaleFactor,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout();

    final textWidth = textPainter.width;
    final minWidth = 80 * _scaleFactor;
    final maxWidth = 280 * _scaleFactor;

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
          fontSize: 11 * _scaleFactor,
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