import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';
import '../../../services/music_service.dart';
import '../../../services/daily_challenge_service.dart';

class JavaLevel1Hard extends StatefulWidget {
  const JavaLevel1Hard({super.key});

  @override
  State<JavaLevel1Hard> createState() => _JavaLevel1HardState();
}

class _JavaLevel1HardState extends State<JavaLevel1Hard> {
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level1Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 300;
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  String? currentlyDraggedBlock;
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  // Track block instances with unique IDs
  List<BlockItem> allBlockItems = [];
  List<BlockItem> droppedBlockItems = [];

  @override
  void initState() {
    super.initState();
    resetBlocks();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
    _loadHintCards();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start_hard.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('game_music_hard.mp3');
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
      musicService.playSoundEffect('hint_use_hard.mp3');

      setState(() {
        _isUsingHint = true;
        _showHint = true;
        _currentHint = _getLevelHint();
        _availableHintCards--;
      });

      final user = await UserPreferences.getUser();
      if (user['id'] != null) {
        await DailyChallengeService.useHintCard(user['id']);
      }

      _autoDragCorrectBlocks();
    } else if (_availableHintCards <= 0) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error_hard.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hint cards! Complete challenges to earn more.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _autoDragCorrectBlocks() {
    List<String> correctBlocks = [
      'import java.util.Scanner;',
      'public class Main',
      '{',
      'public static void displayMessage(String msg)',
      '{',
      'System.out.println("Message: " + msg);',
      '}',
      'public static void main(String[] args)',
      '{',
      'String text = "Hello World";',
      'displayMessage(text);',
      '}',
      '}'
    ];

    setState(() {
      droppedBlockItems.clear();
    });

    int delay = 0;
    for (String block in correctBlocks) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() {
            // Find the block in allBlockItems and move it to droppedBlockItems
            var blockItem = allBlockItems.firstWhere(
                  (item) => item.text == block && !droppedBlockItems.contains(item),
              orElse: () => BlockItem(block, UniqueKey()),
            );

            if (!droppedBlockItems.contains(blockItem)) {
              droppedBlockItems.add(blockItem);
            }
            allBlockItems.remove(blockItem);
          });
        }
      });
      delay += 350;
    }

    Future.delayed(Duration(milliseconds: delay + 1000), () {
      if (mounted) {
        setState(() {
          _showHint = false;
          _isUsingHint = false;
        });
      }
    });
  }

  String _getLevelHint() {
    return "HARD: Create a Java program with custom method!\n\nCorrect code uses:\n• import java.util.Scanner\n• public class Main\n• Custom static method displayMessage()\n• String parameter\n• System.out.println for output\n• Method call from main()";
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
    List<String> correctBlocks = [
      'import java.util.Scanner;',
      'public class Main',
      '{',
      'public static void displayMessage(String msg)',
      '{',
      'System.out.println("Message: " + msg);',
      '}',
      'public static void main(String[] args)',
      '{',
      'String text = "Hello World";',
      'displayMessage(text);',
      '}',
      '}'
    ];

    List<String> incorrectBlocks = [
      'import java.util.*;',
      'class Main',
      'public class main',
      'public static void DisplayMessage(String msg)',
      'public void displayMessage(String msg)',
      'static void displayMessage(String msg)',
      'System.out.print("Message: " + msg)',
      'System.out.println(msg)',
      'Scanner input = new Scanner(System.in);',
      'String text = "Hello World"',
      'displayMessage("Hello World");',
      'scanner.close',
      'public static void main()',
      'public static void main(String args)',
      'Console.readLine()',
      'BufferedReader reader = ...',
      'text = "Hello World"',
      'var text = "Hello World"',
      'return;',
      'System.exit(0);'
    ];

    incorrectBlocks.shuffle();
    List<String> selectedIncorrectBlocks = incorrectBlocks.take(5).toList();

    // Create block items with unique keys
    allBlockItems.clear();
    droppedBlockItems.clear();

    // Add all blocks with unique identifiers
    for (String block in [...correctBlocks, ...selectedIncorrectBlocks]) {
      allBlockItems.add(BlockItem(block, UniqueKey()));
    }

    allBlockItems.shuffle();
  }

  void startGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start_hard.mp3');

    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = 300;
      droppedBlockItems.clear();
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      resetBlocks();
    });
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
          musicService.playSoundEffect('time_up_hard.mp3');

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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 180), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty_hard.mp3');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⏰ Time penalty! -1 point. Current score: $score")),
        );
      });
    });
  }

  void resetGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    setState(() {
      score = 3;
      remainingSeconds = 300;
      gameStarted = false;
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      droppedBlockItems.clear();
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();
      resetBlocks();
    });
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.saveScoreWithDifficulty(
        currentUser!['id'],
        'Java',
        'Hard',
        1,
        score,
        score == 3,
      );

      if (response['success'] == true) {
        setState(() {
          level1Completed = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('Score saved successfully: $score for Java Hard Level 1');
      } else {
        print('Failed to save score: ${response['message']}');
      }
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScoresWithDifficulty(
          currentUser!['id'],
          'Java',
          'Hard'
      );

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level1Data = scoresData['1'];

        if (level1Data != null) {
          setState(() {
            previousScore = level1Data['score'] ?? 0;
            level1Completed = level1Data['completed'] ?? false;
            hasPreviousScore = true;
            score = previousScore;
          });
          print('Loaded previous score: $previousScore for Java Hard Level 1');
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'import java.util.*;',
      'class Main',
      'public class main',
      'public static void DisplayMessage(String msg)',
      'public void displayMessage(String msg)',
      'static void displayMessage(String msg)',
      'System.out.print("Message: " + msg)',
      'System.out.println(msg)',
      'Scanner input = new Scanner(System.in);',
      'String text = "Hello World"',
      'displayMessage("Hello World");',
      'scanner.close',
      'public static void main()',
      'public static void main(String args)',
      'Console.readLine()',
      'BufferedReader reader = ...',
      'text = "Hello World"',
      'var text = "Hello World"',
      'return;',
      'System.exit(0);'
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlockItems.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // Convert to text for checking
    List<String> droppedBlocksText = droppedBlockItems.map((item) => item.text).toList();

    bool hasIncorrectBlock = droppedBlocksText.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      musicService.playSoundEffect('error_hard.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ You used incorrect Java code! -1 point. Current score: $score"),
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

        musicService.playSoundEffect('game_over_hard.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You used incorrect Java code and lost all points!"),
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

    String answer = droppedBlocksText.join(' ');
    String normalizedAnswer = answer.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();

    bool hasImport = normalizedAnswer.contains('importjava.util.scanner;');
    bool hasClass = normalizedAnswer.contains('publicclassmain');
    bool hasMethod = normalizedAnswer.contains('publicstaticvoiddisplaymessage(stringmsg)');
    bool hasMethodBody = normalizedAnswer.contains('system.out.println("message:"+msg);');
    bool hasMain = normalizedAnswer.contains('publicstaticvoidmain(string[]args)');
    bool hasVariable = normalizedAnswer.contains('stringtext="helloworld";');
    bool hasMethodCall = normalizedAnswer.contains('displaymessage(text);');

    if (hasImport && hasClass && hasMethod && hasMethodBody && hasMain && hasVariable && hasMethodCall) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      if (score == 3) {
        musicService.playSoundEffect('perfect_hard.mp3');
      } else {
        musicService.playSoundEffect('success_hard.mp3');
      }

      final gameScore = score;
      final leaderboardPoints = score * 30;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Excellent! You built an advanced Java program with custom methods!"),
              SizedBox(height: 10),
              Text("Game Score: $gameScore/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              Text("Leaderboard Points: $leaderboardPoints/90", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've mastered Java Hard Level!",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) for full completion!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  "🎯 Hard Difficulty: 30× Points Multiplier!",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Program Output:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  "Message: Hello World",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "💎 Advanced Feature: You created a custom static method!",
                style: TextStyle(color: Colors.cyan, fontSize: 12),
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
                  Navigator.pushReplacementNamed(context, '/java_level2_hard');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels',
                      arguments: {'language': 'Java', 'difficulty': 'hard'});
                }
              },
              child: Text(score == 3 ? "Next Level" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      musicService.playSoundEffect('wrong_hard.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Incomplete Java program. -1 point. Current score: $score")),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);

        musicService.playSoundEffect('game_over_hard.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("Remember to build the complete Java program with class, method, and all necessary parts."),
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
          color: Colors.red.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.redAccent, width: 2 * _scaleFactor),
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
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Correct blocks are being placed automatically...',
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
                  'Main.java',
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
            child: _buildCodeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContent() {
    if (droppedBlockItems.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// Drag blocks to build your advanced Java program',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12 * _scaleFactor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }

    List<Widget> codeLines = [];
    int lineNumber = 1;

    for (BlockItem blockItem in droppedBlockItems) {
      String block = blockItem.text;
      bool isImport = block.contains('import');
      bool isKeyword = block.contains('public class') ||
          block.contains('public static void') ||
          block.contains('String') ||
          block.contains('System.out.println') ||
          block.contains('Scanner');
      bool isIncorrect = isIncorrectBlock(block);

      Color textColor = Colors.white;
      if (isImport) {
        textColor = Color(0xFFCE9178);
      } else if (isKeyword && !isIncorrect) {
        textColor = Color(0xFF569CD6);
      } else if (isIncorrect) {
        textColor = Colors.red;
      }

      String displayCode = block;

      if (block != 'import java.util.Scanner;' &&
          block != 'public class Main' &&
          block != '{' &&
          block != '}') {
        displayCode = '    $block';
      }

      codeLines.add(_buildCodeLineWithNumber(lineNumber++, displayCode,
          textColor: textColor,
          isIncorrect: isIncorrect
      ));

      if (block == 'import java.util.Scanner;' || block == '}') {
        codeLines.add(SizedBox(height: 8 * _scaleFactor));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: codeLines,
    );
  }

  Widget _buildCodeLineWithNumber(int lineNumber, String code, {Color? textColor, bool isIncorrect = false}) {
    Color finalTextColor = textColor ?? Colors.white;

    if (isIncorrect) {
      finalTextColor = Colors.red;
    }

    return Container(
      height: 20 * _scaleFactor,
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
              code,
              style: TextStyle(
                color: finalTextColor,
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
                fontWeight: isIncorrect ? FontWeight.bold : FontWeight.normal,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newScreenWidth = MediaQuery.of(context).size.width;
      final newScaleFactor = newScreenWidth < _baseScreenWidth ? newScreenWidth / _baseScreenWidth : 1.0;

      if (newScaleFactor != _scaleFactor) {
        setState(() {
          _scaleFactor = newScaleFactor;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("⚡ Java - Level 1 (Hard)", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.red,
        actions: gameStarted ? [
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
        ] : [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B2A),
              Color(0xFF3B263B),
              Color(0xFF5A2A44),
            ],
          ),
        ),
        child: Stack(
          children: [
            gameStarted ? buildGameUI() : buildStartScreen(),
            if (gameStarted && !isAnsweredCorrectly) ...[
              _buildHintDisplay(),
              Positioned(
                bottom: 20 * _scaleFactor,
                right: 20 * _scaleFactor,
                child: GestureDetector(
                  onTap: _useHintCard,
                  child: Container(
                    padding: EdgeInsets.all(12 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: _availableHintCards > 0 ? Colors.red : Colors.grey,
                      borderRadius: BorderRadius.circular(20 * _scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4 * _scaleFactor,
                          offset: Offset(0, 2 * _scaleFactor),
                        )
                      ],
                      border: Border.all(
                        color: _availableHintCards > 0 ? Colors.redAccent : Colors.grey,
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStartScreen() {
    final displayGameScore = previousScore;
    final displayLeaderboardPoints = previousScore * 30;
    final maxGameScore = 3;
    final maxLeaderboardPoints = 90;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                startGame();
              },
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Start Hard", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.red, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.red,
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

            if (level1Completed)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Hard Level completed with perfect score!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "🎮 Game Score: $displayGameScore/$maxGameScore",
                      style: TextStyle(color: Colors.green, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "🏆 Leaderboard Points: $displayLeaderboardPoints/$maxLeaderboardPoints",
                      style: TextStyle(color: Colors.blue, fontSize: 14 * _scaleFactor, fontWeight: FontWeight.bold),
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
                      "📊 Your previous hard score:",
                      style: TextStyle(color: Colors.blue, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Game: $displayGameScore/$maxGameScore",
                      style: TextStyle(color: Colors.white, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Leaderboard: $displayLeaderboardPoints/$maxLeaderboardPoints",
                      style: TextStyle(color: Colors.blue, fontSize: 14 * _scaleFactor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Try again to get a perfect score!",
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
                        "😅 Your previous score: $displayGameScore/$maxGameScore",
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
                color: Colors.red[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Hard Level Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.red[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Build an advanced Java program with custom methods using all 13 blocks",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.red[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      "🎁 Hard Difficulty: 30× Points Multiplier!",
                      style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🎮 Perfect Score (3/3) = 90 Leaderboard Points",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  SizedBox(height: 5 * _scaleFactor),
                  Text(
                    "(Easy: 30 points, Medium: 60 points, Hard: 90 points)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11 * _scaleFactor,
                        color: Colors.purple,
                        fontStyle: FontStyle.italic
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
                child: Text('📖 Short Story',
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
                label: Text(isTagalog ? 'English' : 'Tagalog',
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 10 * _scaleFactor),
          Text(
            isTagalog
                ? 'Ngayon, si Maria ay naging advanced Java programmer! Gusto niyang gumawa ng custom method para mas organized ang kanyang code. Tulungan siyang buuin ang program na may method na nagdi-display ng mensahe!'
                : 'Now, Maria has become an advanced Java programmer! She wants to create a custom method to make her code more organized. Help her build a program with a method that displays messages!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Build the advanced Java program with method using all 13 blocks',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 280 * _scaleFactor,
              maxHeight: 400 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.red, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<BlockItem>(
              onWillAccept: (data) {
                return true;
              },
              onAccept: (BlockItem data) {
                if (!isAnsweredCorrectly) {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_drop.mp3');

                  setState(() {
                    if (!droppedBlockItems.contains(data)) {
                      droppedBlockItems.add(data);
                    }
                    allBlockItems.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 6 * _scaleFactor,
                    runSpacing: 6 * _scaleFactor,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: droppedBlockItems.map((blockItem) {
                      return Draggable<BlockItem>(
                        data: blockItem,
                        feedback: Material(
                          color: Colors.transparent,
                          child: puzzleBlock(blockItem.text, Colors.redAccent),
                        ),
                        childWhenDragging: puzzleBlock(blockItem.text, Colors.redAccent.withOpacity(0.5)),
                        child: puzzleBlock(blockItem.text, Colors.redAccent),
                        onDragStarted: () {
                          final musicService = Provider.of<MusicService>(context, listen: false);
                          musicService.playSoundEffect('block_pickup.mp3');
                          setState(() {
                            currentlyDraggedBlock = blockItem.text;
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
                                  if (!allBlockItems.contains(blockItem)) {
                                    allBlockItems.add(blockItem);
                                  }
                                  droppedBlockItems.remove(blockItem);
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
          Text('💻 Code Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 180 * _scaleFactor,
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
            ),
            child: Wrap(
              spacing: 6 * _scaleFactor,
              runSpacing: 8 * _scaleFactor,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: allBlockItems.map((blockItem) {
                return isAnsweredCorrectly
                    ? puzzleBlock(blockItem.text, Colors.grey)
                    : Draggable<BlockItem>(
                  data: blockItem,
                  feedback: Material(
                    color: Colors.transparent,
                    child: puzzleBlock(blockItem.text, Colors.deepPurple),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(blockItem.text, Colors.deepPurple),
                  ),
                  child: puzzleBlock(blockItem.text, Colors.deepPurple),
                  onDragStarted: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('block_pickup.mp3');
                    setState(() {
                      currentlyDraggedBlock = blockItem.text;
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
                            if (!allBlockItems.contains(blockItem)) {
                              allBlockItems.add(blockItem);
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
              musicService.playSoundEffect('compile_hard.mp3');
              checkAnswer();
            },
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Run", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
    return Container(
      constraints: BoxConstraints(
        minWidth: 70 * _scaleFactor,
        maxWidth: 160 * _scaleFactor,
      ),
      margin: EdgeInsets.symmetric(horizontal: 2 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 10 * _scaleFactor,
        vertical: 8 * _scaleFactor,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15 * _scaleFactor),
          bottomRight: Radius.circular(15 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black87, width: 1.5 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4 * _scaleFactor,
            offset: Offset(2 * _scaleFactor, 2 * _scaleFactor),
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
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        softWrap: true,
      ),
    );
  }
}

class BlockItem {
  final String text;
  final Key key;

  BlockItem(this.text, this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BlockItem &&
              runtimeType == other.runtimeType &&
              key == other.key;

  @override
  int get hashCode => key.hashCode;
}