import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';
import '../../../services/music_service.dart';
import '../../../services/daily_challenge_service.dart';

class JavaLevel3Hard extends StatefulWidget {
  const JavaLevel3Hard({super.key});

  @override
  State<JavaLevel3Hard> createState() => _JavaLevel3HardState();
}

class _JavaLevel3HardState extends State<JavaLevel3Hard> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool levelCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 300; // 5 minutes for advanced level
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  String? currentlyDraggedBlock;
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  Map<String, dynamic>? gameConfig;
  bool isLoading = true;
  String? errorMessage;

  // HINT SYSTEM
  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  // Configurable elements from database
  String _codePreviewTitle = '💻 Advanced Code Preview:';
  String _instructionText = '🧩 Arrange the blocks to implement binary search algorithm in Java';
  List<String> _codeStructure = [];
  String _expectedOutput = 'Element found at index: 4';

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

      final response = await ApiService.getGameConfigWithDifficulty('Java', 'Hard', 3);

      print('🔍 JAVA HARD LEVEL 3 GAME CONFIG RESPONSE:');
      print('   Success: ${response['success']}');
      print('   Message: ${response['message']}');

      if (response['success'] == true && response['game'] != null) {
        setState(() {
          gameConfig = response['game'];
          _initializeGameFromConfig();
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load hard level 3 game configuration';
        });
      }
    } catch (e) {
      print('❌ Error loading hard level 3 game config: $e');
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
      print('🔄 INITIALIZING JAVA HARD LEVEL 3 GAME FROM CONFIG');

      // Load timer duration from database
      if (gameConfig!['timer_duration'] != null) {
        int timerDuration = int.tryParse(gameConfig!['timer_duration'].toString()) ?? 300;
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

      // ✅ FIXED: Improved blocks parsing
      List<String> correctBlocks = _parseBlocksImproved(gameConfig!['correct_blocks'], 'correct');
      List<String> incorrectBlocks = _parseBlocksImproved(gameConfig!['incorrect_blocks'], 'incorrect');

      print('✅ Correct Blocks: $correctBlocks');
      print('✅ Incorrect Blocks: $incorrectBlocks');

      // Combine and shuffle blocks
      allBlocks = [
        ...correctBlocks,
        ...incorrectBlocks,
      ]..shuffle();

      print('🎮 All Blocks Final: $allBlocks');

    } catch (e) {
      print('❌ Error parsing hard level 3 game config: $e');
      _initializeDefaultBlocks();
    }
  }

  // ✅ FIXED: Improved blocks parsing method
  List<String> _parseBlocksImproved(dynamic blocksData, String type) {
    List<String> blocks = [];

    if (blocksData == null) {
      print('⚠️ $type blocks are NULL in database, using defaults');
      return _getDefaultBlocks(type);
    }

    try {
      if (blocksData is List) {
        // Direct list from database
        blocks = List<String>.from(blocksData);
        print('✅ $type blocks parsed as direct List: $blocks');
      } else if (blocksData is String) {
        String blocksStr = blocksData.trim();
        print('🔍 Raw $type blocks string: "$blocksStr"');

        // Try JSON parsing first
        if (blocksStr.startsWith('[') && blocksStr.endsWith(']')) {
          try {
            List<dynamic> parsedJson = json.decode(blocksStr);
            blocks = parsedJson.map((item) => item.toString()).toList();
            print('✅ $type blocks parsed as JSON: $blocks');
          } catch (e) {
            print('❌ JSON parsing failed, trying manual parsing: $e');
            blocks = _parseManual(blocksStr);
          }
        } else {
          // Manual parsing for non-JSON strings
          blocks = _parseManual(blocksStr);
        }
      }
    } catch (e) {
      print('❌ Error parsing $type blocks: $e');
      blocks = _getDefaultBlocks(type);
    }

    // Remove any empty strings and trim
    blocks = blocks.map((block) => block.trim()).where((block) => block.isNotEmpty).toList();

    print('🎯 Final $type blocks: $blocks');
    return blocks;
  }

  // ✅ FIXED: Manual parsing for various formats
  List<String> _parseManual(String input) {
    // Remove brackets if present
    String cleaned = input.replaceAll('[', '').replaceAll(']', '').trim();

    // Handle different separators
    List<String> items = [];

    if (cleaned.contains('","')) {
      // JSON-like format: "item1","item2","item3"
      items = cleaned.split('","').map((item) => item.replaceAll('"', '').trim()).toList();
    } else if (cleaned.contains(',')) {
      // Comma-separated format
      items = cleaned.split(',').map((item) => item.trim()).toList();
    } else {
      // Single item or other format
      items = [cleaned];
    }

    // Clean up quotes
    items = items.map((item) {
      String cleanedItem = item;
      if (cleanedItem.startsWith('"') && cleanedItem.endsWith('"')) {
        cleanedItem = cleanedItem.substring(1, cleanedItem.length - 1);
      }
      return cleanedItem.trim();
    }).where((item) => item.isNotEmpty).toList();

    print('✅ Manual parsing result: $items');
    return items;
  }

  List<String> _getDefaultCodeStructure() {
    return [
      "public class BinarySearch {",
      "    public static void main(String[] args) {",
      "        int[] arr = {2, 3, 4, 10, 40};",
      "        int target = 10;",
      "        // Your code here",
      "    }",
      "    ",
      "    // Binary search method implementation",
      "    // Your code here",
      "}"
    ];
  }

  List<String> _getDefaultBlocks(String type) {
    if (type == 'correct') {
      return [
        'int result = binarySearch(arr, target);',
        'if (result == -1)',
        '    System.out.println(\"Element not found\");',
        'else',
        '    System.out.println(\"Element found at index: \" + result);',
        'int binarySearch(int[] arr, int target) {',
        '    int left = 0, right = arr.length - 1;',
        '    while (left <= right) {',
        '        int mid = left + (right - left) / 2;',
        '        if (arr[mid] == target)',
        '            return mid;',
        '        if (arr[mid] < target)',
        '            left = mid + 1;',
        '        else',
        '            right = mid - 1;',
        '    }',
        '    return -1;',
        '}'
      ];
    } else {
      return [
        'int result = linearSearch(arr, target);',
        'for (int i = 0; i < arr.length; i++) {',
        '    if (arr[i] == target)',
        '        return i;',
        '}',
        'int left = 0, right = arr.length;',
        'while (left < right) {',
        '    int mid = (left + right) / 2;',
        '    if (arr[mid] == target)',
        '        return mid;',
        '    else if (arr[mid] > target)',
        '        left = mid;',
        '    else',
        '        right = mid;',
        '}',
        'System.out.println(\"Found: \" + target);',
        'return result;'
      ];
    }
  }

  String _getDefaultHint() {
    return "💡 Hint: Binary search requires sorted array. Use left and right pointers, calculate mid index, and compare with target. Move pointers based on comparison.";
  }

  void _initializeDefaultBlocks() {
    allBlocks = [
      'int result = binarySearch(arr, target);',
      'if (result == -1)',
      '    System.out.println(\"Element not found\");',
      'else',
      '    System.out.println(\"Element found at index: \" + result);',
      'int binarySearch(int[] arr, int target) {',
      '    int left = 0, right = arr.length - 1;',
      '    while (left <= right) {',
      '        int mid = left + (right - left) / 2;',
      '        if (arr[mid] == target)',
      '            return mid;',
      '        if (arr[mid] < target)',
      '            left = mid + 1;',
      '        else',
      '            right = mid - 1;',
      '    }',
      '    return -1;',
      '}',
      'int result = linearSearch(arr, target);',
      'for (int i = 0; i < arr.length; i++) {',
      '    if (arr[i] == target)',
      '        return i;',
      '}',
      'int left = 0, right = arr.length;',
      'while (left < right) {',
      '    int mid = (left + right) / 2;',
      '    if (arr[mid] == target)',
      '        return mid;',
      '    else if (arr[mid] > target)',
      '        left = mid;',
      '    else',
      '        right = mid;',
      '}',
      'System.out.println(\"Found: \" + target);',
      'return result;'
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
          backgroundColor: Colors.purple,
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
    musicService.playSoundEffect('level_start.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 300
        : 300;

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

    print('🎮 JAVA HARD LEVEL 3 GAME STARTED - Initial Score: $score, Timer: $timerDuration seconds');
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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 20), (timer) {
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
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 300
        : 300;

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
      print('❌ Cannot save score: No user ID');
      return;
    }

    try {
      print('💾 SAVING JAVA HARD LEVEL 3 SCORE:');
      print('   User ID: ${currentUser!['id']}');
      print('   Language: Java');
      print('   Level: 3');
      print('   Difficulty: Hard');
      print('   Score: $score/3');
      print('   Completed: ${score == 3}');

      final response = await ApiService.saveScoreWithDifficulty(
        currentUser!['id'],
        'Java',
        'Hard',
        3,
        score,
        score == 3,
      );

      print('📡 SERVER RESPONSE: $response');

      if (response['success'] == true) {
        setState(() {
          levelCompleted = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('✅ JAVA HARD LEVEL 3 SCORE SAVED SUCCESSFULLY TO DATABASE');
      } else {
        print('❌ FAILED TO SAVE SCORE: ${response['message']}');
      }
    } catch (e) {
      print('❌ ERROR SAVING JAVA HARD LEVEL 3 SCORE: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScoresWithDifficulty(currentUser!['id'], 'Java', 'Hard');

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
      print('Error loading Java hard level 3 score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    if (gameConfig != null) {
      try {
        List<String> incorrectBlocks = _parseBlocksImproved(gameConfig!['incorrect_blocks'], 'incorrect');
        bool isIncorrect = incorrectBlocks.contains(block);
        if (isIncorrect) {
          print('❌ Block "$block" is in incorrect blocks list');
        }
        return isIncorrect;
      } catch (e) {
        print('Error checking incorrect block: $e');
      }
    }

    // Default incorrect blocks for Java Hard Level 3
    List<String> incorrectBlocks = [
      'int result = linearSearch(arr, target);',
      'for (int i = 0; i < arr.length; i++) {',
      '    if (arr[i] == target)',
      '        return i;',
      '}',
      'int left = 0, right = arr.length;',
      'while (left < right) {',
      '    int mid = (left + right) / 2;',
      '    if (arr[mid] == target)',
      '        return mid;',
      '    else if (arr[mid] > target)',
      '        left = mid;',
      '    else',
      '        right = mid;',
      '}',
      'System.out.println(\"Found: \" + target);',
      'return result;'
    ];
    return incorrectBlocks.contains(block);
  }

  // ✅ FIXED: Improved answer checking logic
  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // DEBUG: Print what we're checking
    print('🔍 CHECKING JAVA HARD LEVEL 3 ANSWER:');
    print('   Dropped blocks: $droppedBlocks');
    print('   All blocks: $allBlocks');

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      print('❌ HAS INCORRECT BLOCK');
      musicService.playSoundEffect('error.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ You used incorrect code! -1 point. Current score: $score"),
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
            content: Text("You used incorrect code and lost all points!"),
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

    // ✅ FIXED: IMPROVED ANSWER CHECKING LOGIC
    bool isCorrect = false;

    if (gameConfig != null) {
      // Get expected correct blocks from database
      List<String> expectedCorrectBlocks = _parseBlocksImproved(gameConfig!['correct_blocks'], 'correct');

      print('🎯 EXPECTED CORRECT BLOCKS: $expectedCorrectBlocks');
      print('🎯 USER DROPPED BLOCKS: $droppedBlocks');

      // METHOD 1: Check if user has all correct blocks and no extra correct blocks
      bool hasAllCorrectBlocks = expectedCorrectBlocks.every((block) => droppedBlocks.contains(block));
      bool noExtraCorrectBlocks = droppedBlocks.every((block) => expectedCorrectBlocks.contains(block));

      // METHOD 2: Check string comparison (normalized)
      String userAnswer = droppedBlocks.join(' ');
      String normalizedUserAnswer = userAnswer.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();

      if (gameConfig!['correct_answer'] != null) {
        String expectedAnswer = gameConfig!['correct_answer'].toString();
        String normalizedExpected = expectedAnswer.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();

        print('📝 USER ANSWER: $userAnswer');
        print('📝 NORMALIZED USER: $normalizedUserAnswer');
        print('🎯 EXPECTED ANSWER: $expectedAnswer');
        print('🎯 NORMALIZED EXPECTED: $normalizedExpected');

        bool stringMatch = normalizedUserAnswer == normalizedExpected;

        // Use both methods for verification
        isCorrect = (hasAllCorrectBlocks && noExtraCorrectBlocks) || stringMatch;

        print('✅ BLOCK CHECK: hasAllCorrectBlocks=$hasAllCorrectBlocks, noExtraCorrectBlocks=$noExtraCorrectBlocks');
        print('✅ STRING CHECK: stringMatch=$stringMatch');
        print('✅ FINAL RESULT: $isCorrect');
      } else {
        // Fallback: only use block comparison
        isCorrect = hasAllCorrectBlocks && noExtraCorrectBlocks;
        print('⚠️ No correct_answer in DB, using block comparison only: $isCorrect');
      }
    } else {
      // Fallback check for basic requirements
      print('⚠️ No game config, using fallback check');
      bool hasMethodCall = droppedBlocks.any((block) => block.toLowerCase().contains('binarysearch(arr, target)'));
      bool hasMethodDefinition = droppedBlocks.any((block) => block.toLowerCase().contains('int binarysearch'));
      bool hasWhileLoop = droppedBlocks.any((block) => block.toLowerCase().contains('while (left <= right)'));
      bool hasMidCalculation = droppedBlocks.any((block) => block.toLowerCase().contains('mid = left + (right - left) / 2'));
      bool hasReturnStatements = droppedBlocks.any((block) => block.toLowerCase().contains('return mid')) &&
          droppedBlocks.any((block) => block.toLowerCase().contains('return -1'));

      isCorrect = hasMethodCall && hasMethodDefinition && hasWhileLoop && hasMidCalculation && hasReturnStatements;
      print('✅ FALLBACK CHECK: $isCorrect');
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
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Excellent work Java Algorithm Master!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🏆 Legendary! You've conquered the ultimate Java Hard Level 3!",
                  style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚡ Get a perfect score (3/3) to prove your algorithm mastery!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Code Output:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  _expectedOutput,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "🎯 Binary Search Complexity: O(log n)",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/levels', arguments: {
                  'language': 'Java',
                  'difficulty': 'Hard'
                });
              },
              child: Text("Back to Levels"),
            )
          ],
        ),
      );
    } else {
      print('❌ ANSWER INCORRECT');
      musicService.playSoundEffect('wrong.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Incorrect arrangement. -1 point. Current score: $score"),
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
          color: Colors.purple.withOpacity(0.95),
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
                Icon(Icons.lightbulb, color: Colors.white, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  '💡 Hint Activated!',
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
            color: _availableHintCards > 0 ? Colors.purple : Colors.grey,
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

  // Code Preview Widget
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
                  'BinarySearch.java',
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

      if (line.contains('// Your code here')) {
        // Add user's dragged code in the correct position
        codeLines.add(_buildUserCodeSection());
      } else if (line.trim().isEmpty) {
        codeLines.add(SizedBox(height: 16 * _scaleFactor));
      } else {
        codeLines.add(_buildSyntaxHighlightedLine(line, i + 1));
      }
    }

    return codeLines;
  }

  Widget _buildUserCodeSection() {
    if (droppedBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          '        // Your code here',
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

  Widget _buildSyntaxHighlightedLine(String code, int lineNumber) {
    Color textColor = Colors.white;
    String displayCode = code;

    // Java syntax highlighting rules
    if (code.trim().startsWith('public class') || code.contains('public static void main')) {
      textColor = Color(0xFF569CD6); // Keywords - blue
    } else if (code.trim().startsWith('//')) {
      textColor = Color(0xFF6A9955); // Comments - green
    } else if (code.contains('"') || code.contains("'")) {
      textColor = Color(0xFFCE9178); // Strings - orange
    } else if (code.contains('{') || code.contains('}')) {
      textColor = Colors.white; // Braces - white
    } else if (code.contains('int[]') || code.contains('int ')) {
      textColor = Color(0xFF4EC9B0); // Types - teal
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
          title: Text("☕ Java - Level 3 Hard", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.purple,
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
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 20),
                Text(
                  "Loading Java Hard Level 3 Configuration...",
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
          title: Text("☕ Java - Level 3 Hard", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.purple,
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
                  Icon(Icons.warning_amber, color: Colors.purple, size: 50),
                  SizedBox(height: 20),
                  Text(
                    "Configuration Warning",
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: Text("Retry Loading"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/levels', arguments: {
                        'language': 'Java',
                        'difficulty': 'Hard'
                      });
                    },
                    child: Text("Back to Levels", style: TextStyle(color: Colors.purple)),
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
        title: Text("☕ Java - Level 3 Hard", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.purple,
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
              label: Text(gameConfig != null ? "Start Hard Level 3" : "Config Missing", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: gameConfig != null ? Colors.purple : Colors.grey,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            // Display available hint cards in start screen
            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.purple, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Use hint cards during the game for help!',
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
                      "🏆 Hard Level 3 completed with perfect score!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "You are a Java Algorithm Master!",
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      "📊 Your previous score: $previousScore/3",
                      style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Try again to conquer the ultimate hard level 3!",
                      style: TextStyle(color: Colors.purple, fontSize: 14 * _scaleFactor),
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
                        "💀 Your previous score: $previousScore/3",
                        style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "Algorithm challenge! Give it your best shot!",
                        style: TextStyle(color: Colors.purple, fontSize: 14 * _scaleFactor),
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
                color: Colors.purple[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    gameConfig?['objective'] ?? "🎯 Java Level 3 Hard Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    gameConfig?['objective'] ?? "Implement binary search algorithm to efficiently find elements in sorted array",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "💀 Ultimate Hard Difficulty: Algorithm implementation, method calls, and complex logic!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "⏰ Time: 5 minutes | 🔥 Penalty: Every 20 seconds",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
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
                child: Text('📖 Short Story', style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
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
                ? (gameConfig?['story_tagalog'] ?? 'Ito ay Hard Level 3 ng Java programming! Gamit ang binary search algorithm, hanapin ang elemento sa sorted array nang mas mabilis.')
                : (gameConfig?['story_english'] ?? 'This is Java Hard Level 3! Using binary search algorithm, find the element in sorted array efficiently.'),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text(_instructionText,
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
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
              border: Border.all(color: Colors.purple, width: 2.5 * _scaleFactor),
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
                          child: puzzleBlock(block, Colors.purpleAccent),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.purpleAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.purpleAccent),
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
                    child: puzzleBlock(block, Colors.purple),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.purple),
                  ),
                  child: puzzleBlock(block, Colors.purple),
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
            label: Text("Run", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
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