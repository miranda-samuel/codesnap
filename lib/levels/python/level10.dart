import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import '../../services/music_service.dart';
import 'python_bonus_game1.dart';

class PythonLevel10 extends StatefulWidget {
  const PythonLevel10({super.key});

  @override
  State<PythonLevel10> createState() => _PythonLevel10State();
}

class _PythonLevel10State extends State<PythonLevel10> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level10Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 240;
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  // Track currently dragged block
  String? currentlyDraggedBlock;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  @override
  void initState() {
    super.initState();
    resetBlocks();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
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

  void _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      currentUser = user;
    });
    loadScoreFromDatabase();
  }

  void resetBlocks() {
    // Correct blocks for Python: File handling with context manager
    List<String> correctBlocks = [
      'with open("data.txt", "r") as file:',
      '    data = file.read()',
      '    lines = data.split("\\n")',
      '    for i, line in enumerate(lines):',
      '        if line.strip():',
      '            print(f"Line {i+1}: {line}")',
      '    print(f"Total lines: {len(lines)}")',
      'print("File reading completed!")'
    ];

    // Incorrect/distractor blocks
    List<String> incorrectBlocks = [
      'open("data.txt", "r")',
      'file = open("data.txt", "r")',
      'data = file.read()',
      'lines = data.split("\\n")',
      'for i in range(len(lines)):',
      'for line in lines:',
      'if line != "":',
      'if line:',
      'print("Line " + str(i+1) + ": " + line)',
      'print("Line: " + line)',
      'print(f"Total: {len(lines)} lines")',
      'file.close()',
      'try:',
      'except FileNotFoundError:',
      'with open("data.txt") as f:',
      'with open("data.txt", "w") as file:',
      'data = read_file("data.txt")',
      'lines = data.lines()',
    ];

    // Shuffle incorrect blocks and take 4 random ones
    incorrectBlocks.shuffle();
    List<String> selectedIncorrectBlocks = incorrectBlocks.take(4).toList();

    // Combine correct and incorrect blocks, then shuffle
    allBlocks = [
      ...correctBlocks,
      ...selectedIncorrectBlocks,
    ]..shuffle();
  }

  void startGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = 240;
      droppedBlocks.clear();
      isAnsweredCorrectly = false;
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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 120), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty.mp3');

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
      remainingSeconds = 240;
      gameStarted = false;
      isAnsweredCorrectly = false;
      droppedBlocks.clear();
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();
      resetBlocks();
    });
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.saveScore(
        currentUser!['id'],
        'Python',
        10,
        score,
        score == 3,
      );

      if (response['success'] == true) {
        setState(() {
          level10Completed = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });
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
      final response = await ApiService.getScores(currentUser!['id'], 'Python');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level10Data = scoresData['10'];

        if (level10Data != null) {
          setState(() {
            previousScore = level10Data['score'] ?? 0;
            level10Completed = level10Data['completed'] ?? false;
            hasPreviousScore = true;
            score = previousScore;
          });
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  // Check if a block is incorrect
  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'open("data.txt", "r")',
      'file = open("data.txt", "r")',
      'data = file.read()',
      'lines = data.split("\\n")',
      'for i in range(len(lines)):',
      'for line in lines:',
      'if line != "":',
      'if line:',
      'print("Line " + str(i+1) + ": " + line)',
      'print("Line: " + line)',
      'print(f"Total: {len(lines)} lines")',
      'file.close()',
      'try:',
      'except FileNotFoundError:',
      'with open("data.txt") as f:',
      'with open("data.txt", "w") as file:',
      'data = read_file("data.txt")',
      'lines = data.lines()',
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

    // Check for the correct sequence for file handling
    bool hasWithOpen = droppedBlocks.contains('with open("data.txt", "r") as file:');
    bool hasDataRead = droppedBlocks.contains('    data = file.read()');
    bool hasSplit = droppedBlocks.contains('    lines = data.split("\\n")');
    bool hasEnumerate = droppedBlocks.contains('    for i, line in enumerate(lines):');
    bool hasStripCheck = droppedBlocks.contains('        if line.strip():');
    bool hasPrintLine = droppedBlocks.contains('            print(f"Line {i+1}: {line}")');
    bool hasPrintTotal = droppedBlocks.contains('    print(f"Total lines: {len(lines)}")');
    bool hasPrintComplete = droppedBlocks.contains('print("File reading completed!")');

    // Check if all correct blocks are present
    bool allCorrectBlocksPresent = hasWithOpen &&
        hasDataRead &&
        hasSplit &&
        hasEnumerate &&
        hasStripCheck &&
        hasPrintLine &&
        hasPrintTotal &&
        hasPrintComplete;

    // Check if no extra correct blocks are used (should be exactly 8 blocks)
    bool correctBlockCount = droppedBlocks.length == 8;

    if (allCorrectBlocksPresent && correctBlockCount) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      // PLAY SUCCESS SOUND BASED ON SCORE
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
              Text("Excellent! You've created a perfect file reader program!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Column(
                  children: [
                    Text(
                      "🎉 Perfect! You've unlocked the Bonus Game!",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Complete the Bonus Game to earn extra points!",
                      style: TextStyle(color: Colors.purple, fontSize: 12),
                    ),
                  ],
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to unlock the Bonus Game!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Code Output:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Line 1: Hello World", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
                    Text("Line 2: Python Programming", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
                    Text("Line 3: File Handling", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
                    SizedBox(height: 5),
                    Text("Total lines: 4", style: TextStyle(color: Colors.yellow, fontFamily: 'monospace', fontSize: 14)),
                    SizedBox(height: 5),
                    Text("File reading completed!", style: TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 14)),
                  ],
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PythonBonusGame1()),
                  );
                } else {
                  resetGame();
                }
              },
              child: Text(score == 3 ? "Play Bonus Game" : "OK"),
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

        String errorMessage = "❌ Incorrect arrangement. -1 point. Current score: $score";

        // Provide specific feedback
        if (!allCorrectBlocksPresent) {
          errorMessage = "❌ Missing some required code blocks. -1 point. Current score: $score";
        } else if (!correctBlockCount) {
          errorMessage = "❌ Used wrong number of blocks. -1 point. Current score: $score";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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

  // IMPROVED CODE PREVIEW WITH BETTER SCALING
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
          // Code editor header
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
                  'file_reader.py',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12 * _scaleFactor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Code content
          Container(
            padding: EdgeInsets.all(12 * _scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers and code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Container(
                      width: 30 * _scaleFactor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildCodeLine(1),
                          _buildCodeLine(2),
                          _buildCodeLine(3),
                          _buildCodeLine(4),
                          _buildCodeLine(5),
                          _buildCodeLine(6),
                          _buildCodeLine(7),
                          _buildCodeLine(8),
                          _buildCodeLine(9),
                        ],
                      ),
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    // Actual code with syntax highlighting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserCodePreview(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCodePreview() {
    if (droppedBlocks.isEmpty) {
      return Container(
        height: 20 * _scaleFactor,
        child: Text(
          '    ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12 * _scaleFactor,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    List<Widget> codeLines = [];
    bool hasWithOpen = droppedBlocks.contains('with open("data.txt", "r") as file:');
    bool hasDataRead = droppedBlocks.contains('    data = file.read()');
    bool hasSplit = droppedBlocks.contains('    lines = data.split("\\n")');
    bool hasEnumerate = droppedBlocks.contains('    for i, line in enumerate(lines):');
    bool hasStripCheck = droppedBlocks.contains('        if line.strip():');
    bool hasPrintLine = droppedBlocks.contains('            print(f"Line {i+1}: {line}")');
    bool hasPrintTotal = droppedBlocks.contains('    print(f"Total lines: {len(lines)}")');
    bool hasPrintComplete = droppedBlocks.contains('print("File reading completed!")');

    if (hasWithOpen) {
      codeLines.add(_buildUserCodeLine('with open("data.txt", "r") as file:', indent: 0));
    }

    if (hasDataRead) {
      codeLines.add(_buildUserCodeLine('data = file.read()', indent: 1));
    }

    if (hasSplit) {
      codeLines.add(_buildUserCodeLine('lines = data.split("\\n")', indent: 1));
    }

    if (hasEnumerate) {
      codeLines.add(_buildUserCodeLine('for i, line in enumerate(lines):', indent: 1));
    }

    if (hasStripCheck) {
      codeLines.add(_buildUserCodeLine('if line.strip():', indent: 2));
    }

    if (hasPrintLine) {
      codeLines.add(_buildUserCodeLine('print(f"Line {i+1}: {line}")', indent: 3));
    }

    if (hasPrintTotal) {
      codeLines.add(_buildUserCodeLine('print(f"Total lines: {len(lines)}")', indent: 1));
    }

    if (hasPrintComplete) {
      codeLines.add(_buildUserCodeLine('print("File reading completed!")', indent: 0));
    }

    // Add any incorrect blocks that were used
    for (String block in droppedBlocks) {
      if (!['with open("data.txt", "r") as file:',
        '    data = file.read()',
        '    lines = data.split("\\n")',
        '    for i, line in enumerate(lines):',
        '        if line.strip():',
        '            print(f"Line {i+1}: {line}")',
        '    print(f"Total lines: {len(lines)}")',
        'print("File reading completed!")'].contains(block)) {
        codeLines.add(_buildUserCodeLine(block, indent: 0));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: codeLines,
    );
  }

  Widget _buildUserCodeLine(String code, {int indent = 0}) {
    String indentation = ' '.padLeft(indent * 4);

    return Container(
      height: 20 * _scaleFactor,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: indentation,
              style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12 * _scaleFactor),
            ),
            TextSpan(
              text: code,
              style: TextStyle(
                color: Colors.greenAccent[400],
                fontFamily: 'monospace',
                fontSize: 12 * _scaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeLine(int lineNumber) {
    return Container(
      height: 20 * _scaleFactor,
      child: Text(
        lineNumber.toString().padLeft(2, ' '),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12 * _scaleFactor,
          fontFamily: 'monospace',
        ),
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
    // Recalculate scale factor when screen size changes
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
        title: Text("🐍 Python - Level 10", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.green[700],
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
                Text(" $score",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor)),
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
              Color(0xFF0A150A),
              Color(0xFF152415),
              Color(0xFF2A4A2A),
            ],
          ),
        ),
        child: gameStarted ? buildGameUI() : buildStartScreen(),
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
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                startGame();
              },
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Start", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.green[700],
              ),
            ),

            // BONUS GAME 1 BUTTON - Only show if level 10 is completed with perfect score
            if (level10Completed && previousScore == 3)
              Padding(
                padding: EdgeInsets.only(top: 20 * _scaleFactor),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('bonus_unlock.mp3');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PythonBonusGame1()),
                    );
                  },
                  icon: Icon(Icons.casino, size: 20 * _scaleFactor),
                  label: Text("Play Bonus Game", style: TextStyle(fontSize: 16 * _scaleFactor)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                    backgroundColor: Colors.amber[700],
                  ),
                ),
              ),

            SizedBox(height: 20 * _scaleFactor),

            if (level10Completed)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Level 10 completed with perfect score!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "🎁 Bonus Game is now available!",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Try again to get a perfect score and unlock the Bonus Game!",
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
                        "😅 Your previous score: $previousScore/3",
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
                color: Colors.green[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Level 10 Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Create a file reader program that uses context managers and enumerate",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.green[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🎁 Get a perfect score (3/3) to unlock the Bonus Game!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
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
                ? 'Ngayon, si Juan ay gumagawa ng file reader program! Dapat basahin niya ang data.txt file at ipakita ang bawat linya kasama ang line number. Kailangan niyang gamitin ang "with" statement para automatic mag-close ang file at iwasan ang memory leaks. Gamitin ang enumerate() at proper file handling techniques!'
                : 'Juan is creating a file reader program! He needs to read data.txt file and display each line with its line number. He must use the "with" statement for automatic file closing and to avoid memory leaks. Use enumerate() and proper file handling techniques!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Arrange the 8 correct blocks to create the file reader program',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // IMPROVED TARGET AREA WITH BETTER OVERFLOW HANDLING
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 220 * _scaleFactor,
              maxHeight: 300 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.green[700]!, width: 2.5 * _scaleFactor),
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
                          child: puzzleBlock(block, Colors.lightGreenAccent[700]!),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.lightGreenAccent[700]!.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.lightGreenAccent[700]!),
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
          Text('💻 Code Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          // SOURCE AREA WITH IMPROVED LAYOUT
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 160 * _scaleFactor,
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
                    child: puzzleBlock(block, Colors.greenAccent[700]!),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.greenAccent[700]!),
                  ),
                  child: puzzleBlock(block, Colors.greenAccent[700]!),
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
              backgroundColor: Colors.green[700],
              padding: EdgeInsets.symmetric(
                horizontal: 24 * _scaleFactor,
                vertical: 16 * _scaleFactor,
              ),
            ),
          ),
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
    // Calculate text width to adjust block size
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
    )..layout();

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