import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import 'PythonBonusGame.dart';

class PythonLevel3 extends StatefulWidget {
  const PythonLevel3({super.key});

  @override
  State<PythonLevel3> createState() => _PythonLevel3State();
}

class _PythonLevel3State extends State<PythonLevel3> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level3Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 180;
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
    // Python if statement: if age >= 18: \n print("Adult")
    List<String> correctBlocks = [
      'if',
      'age',
      '>=',
      '18',
      ':',
      'print',
      '(',
      '"Adult"',
      ')'
    ];

    // Fewer and simpler incorrect blocks
    List<String> incorrectBlocks = [
      'else',
      'while',
      'for',
      '==',
      '<',
      '16',
      '21',
      '"Minor"',
      'print(',
      'print()'
    ];

    // Take only 3 incorrect blocks to make it easier
    incorrectBlocks.shuffle();
    List<String> selectedIncorrectBlocks = incorrectBlocks.take(3).toList();

    // Combine correct and incorrect blocks, then shuffle
    allBlocks = [
      ...correctBlocks,
      ...selectedIncorrectBlocks,
    ]..shuffle();
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      score = 3; // Always start with 3 points
      remainingSeconds = 180;
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
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("⏰ Time's Up!"),
              content: Text("Score: $score"),
              actions: [
                TextButton(
                  onPressed: () {
                    resetGame();
                    Navigator.pop(context);
                  },
                  child: Text("Try Again"),
                )
              ],
            ),
          );
        }
      });
    });

    // Less frequent penalties
    scoreReductionTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⏰ Time penalty! -1 point. Current score: $score")),
        );
      });
    });
  }

  void resetGame() {
    setState(() {
      score = 3; // Always reset to 3
      remainingSeconds = 180;
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
      // Only mark as completed if score is perfect (3/3)
      bool isPerfectScore = score == 3;

      final response = await ApiService.saveScore(
        currentUser!['id'],
        'Python',
        3,
        score,
        isPerfectScore, // Only true if perfect score
      );

      if (response['success'] == true) {
        setState(() {
          level3Completed = isPerfectScore; // Only completed if perfect score
          previousScore = score;
          hasPreviousScore = true;
        });

        _showCompletionDialog(isPerfectScore);
      } else {
        print('Failed to save score: ${response['message']}');
      }
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  void _showCompletionDialog(bool isPerfectScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(isPerfectScore ? "🎉 Level 3 Completed!" : "✅ Level 3 Finished"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPerfectScore ? Icons.celebration : Icons.check_circle,
              size: 60,
              color: isPerfectScore ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 10),
            Text(
              "You've completed Level 3!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Your Score: $score/3",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: score == 3 ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 10),

            if (isPerfectScore)
              Column(
                children: [
                  Text(
                    "🎁 Bonus Game Unlocked!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Complete the bonus game to unlock Level 4!",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        SizedBox(width: 8),
                        Text(
                          "Perfect Score Achieved!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    "🎯 Almost There!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You need a perfect score (3/3) to unlock the Bonus Game",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "💡 Tips for perfect score:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text("• Arrange blocks quickly"),
                        Text("• Avoid incorrect blocks"),
                        Text("• Complete before time runs out"),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          if (isPerfectScore)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToBonusGame();
              },
              child: Text("Play Bonus Game"),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text("Try Again"),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _navigateToBonusGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PythonBonusGame()),
    );
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScores(currentUser!['id'], 'Python');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level3Data = scoresData['3'];

        if (level3Data != null) {
          setState(() {
            previousScore = level3Data['score'] ?? 0;
            level3Completed = level3Data['completed'] ?? false;
            hasPreviousScore = true;
            // DON'T set current score to previous score
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
      'else', 'while', 'for', '==', '<', '16', '21', '"Minor"', 'print(', 'print()'
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
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
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You used incorrect code and lost all points!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Try Again"),
              )
            ],
          ),
        );
      }
      return;
    }

    // Check for: if age >= 18: \n print("Adult")
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    String expected = 'ifage>=18:print("adult")';

    if (normalizedAnswer == expected) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);
    } else {
      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Incorrect arrangement. -1 point. Current score: $score")),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You lost all your points."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Try Again"),
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
                  'age_checker.py',
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildCodeLine(1, ''),
                        _buildCodeLine(2, getPreviewCode()),
                        _buildCodeLine(3, ''),
                      ],
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSyntaxHighlightedLine('', isNormal: true),
                          _buildUserCodeLine(getPreviewCode()),
                          _buildSyntaxHighlightedLine('', isNormal: true),
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

  Widget _buildUserCodeLine(String code) {
    if (code.isEmpty) {
      return Container(
        height: 20 * _scaleFactor,
        child: Text(
          '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * _scaleFactor,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return Container(
      height: 20 * _scaleFactor,
      child: RichText(
        text: TextSpan(
          children: [
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

  Widget _buildCodeLine(int lineNumber, String code) {
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

  Widget _buildSyntaxHighlightedLine(String code, {bool isPreprocessor = false, bool isKeyword = false, bool isNormal = false}) {
    Color textColor = Colors.white;

    if (isKeyword) {
      textColor = Color(0xFF569CD6);
    } else if (isNormal) {
      textColor = Colors.white;
    }

    return Container(
      height: 20 * _scaleFactor,
      child: Text(
        code,
        style: TextStyle(
          color: textColor,
          fontSize: 12 * _scaleFactor,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  String getPreviewCode() {
    return droppedBlocks.join(' ');
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    scoreReductionTimer?.cancel();
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
        title: Text("🐍 Python - Level 3", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.blue,
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
              Color(0xFF0D1B1B),
              Color(0xFF1B2D2D),
              Color(0xFF335555),
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
              onPressed: startGame,
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Start Level 3", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            if (level3Completed)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Level 3 Completed!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "🎁 Bonus Game Unlocked!",
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    if (previousScore > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 5 * _scaleFactor),
                        child: Text(
                          "Your Best Score: $previousScore/3",
                          style: TextStyle(color: Colors.blueAccent, fontSize: 14 * _scaleFactor),
                          textAlign: TextAlign.center,
                        ),
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
                      style: TextStyle(color: Colors.blue, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    if (previousScore < 3)
                      Column(
                        children: [
                          Text(
                            "🎯 Get a perfect score (3/3) to unlock Bonus Game!",
                            style: TextStyle(color: Colors.orange, fontSize: 14 * _scaleFactor, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5 * _scaleFactor),
                          Text(
                            "Complete without losing any points",
                            style: TextStyle(color: Colors.blueAccent, fontSize: 12 * _scaleFactor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      Text(
                        "Bonus Game is unlocked! Play to unlock Level 4",
                        style: TextStyle(color: Colors.blueAccent, fontSize: 14 * _scaleFactor),
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
                color: Colors.blue[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Level 3 - If Statements",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Create an if statement: if age >= 18: print(\"Adult\")",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.blue[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Text(
                      'if age >= 18:\n    print("Adult")',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14 * _scaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn how to make decisions in your code!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.blue[600], fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    color: Colors.green[50],
                    child: Column(
                      children: [
                        Text(
                          "What you'll learn:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scaleFactor),
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "• How to use if statements\n• Comparison operators\n• Making decisions in code\n• Python indentation",
                          style: TextStyle(fontSize: 11 * _scaleFactor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    color: Colors.purple[50],
                    child: Column(
                      children: [
                        Text(
                          "🎁 BONUS GAME REQUIREMENT:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scaleFactor, color: Colors.purple[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "Get a PERFECT SCORE (3/3) to unlock the Bonus Game!",
                          style: TextStyle(fontSize: 11 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[700]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3 * _scaleFactor),
                        Text(
                          "• Complete without time penalties\n• Don't use incorrect blocks\n• Finish with all 3 points",
                          style: TextStyle(fontSize: 10 * _scaleFactor, color: Colors.purple[600]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Complete the bonus game to unlock Level 4!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12 * _scaleFactor,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B1B),
            Color(0xFF1B2D2D),
            Color(0xFF335555),
          ],
        ),
      ),
      child: SingleChildScrollView(
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
                  ? 'Si Juan ay gustong gumawa ng decision sa program! Kailangan niyang gumamit ng if statement para i-check kung ang age ay 18 o mas mataas. Tulungan siyang buuin ang condition!'
                  : 'Juan wants to make a decision in his program! He needs to use an if statement to check if age is 18 or older. Help him build the condition!',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white70),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Text('🧩 Arrange the blocks to create: if age >= 18: print("Adult")',
                style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
                textAlign: TextAlign.center),
            SizedBox(height: 20 * _scaleFactor),

            // TARGET AREA - FIXED VERSION
            Container(
              height: 160 * _scaleFactor,
              width: double.infinity,
              padding: EdgeInsets.all(16 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.grey[100]!.withOpacity(0.9),
                border: Border.all(color: Colors.blue, width: 2.5 * _scaleFactor),
                borderRadius: BorderRadius.circular(20 * _scaleFactor),
              ),
              child: DragTarget<String>(
                onWillAccept: (data) {
                  // FIX: Always accept blocks as long as game is not finished
                  return !isAnsweredCorrectly;
                },
                onAccept: (data) {
                  if (!isAnsweredCorrectly) {
                    setState(() {
                      droppedBlocks.add(data);
                      allBlocks.remove(data);
                    });
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 6 * _scaleFactor,
                        runSpacing: 6 * _scaleFactor,
                        alignment: WrapAlignment.center,
                        children: droppedBlocks.map((block) {
                          return Draggable<String>(
                            data: block,
                            feedback: puzzleBlock(block, Colors.yellowAccent, isSmall: true),
                            childWhenDragging: puzzleBlock(block, Colors.yellowAccent.withOpacity(0.3), isSmall: true),
                            child: puzzleBlock(block, Colors.yellowAccent, isSmall: true),
                            onDragStarted: () {
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

            // SOURCE AREA
            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.grey[800]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
              ),
              child: Wrap(
                spacing: 8 * _scaleFactor,
                runSpacing: 8 * _scaleFactor,
                alignment: WrapAlignment.center,
                children: allBlocks.map((block) {
                  return isAnsweredCorrectly
                      ? puzzleBlock(block, Colors.grey, isSmall: true)
                      : Draggable<String>(
                    data: block,
                    feedback: puzzleBlock(block, Colors.blue, isSmall: true),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: puzzleBlock(block, Colors.blue, isSmall: true),
                    ),
                    child: puzzleBlock(block, Colors.blue, isSmall: true),
                    onDragStarted: () {
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
              onPressed: isAnsweredCorrectly ? null : checkAnswer,
              icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
              label: Text("Run Code", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * _scaleFactor,
                  vertical: 16 * _scaleFactor,
                ),
              ),
            ),
            TextButton(
              onPressed: resetGame,
              child: Text("🔁 Restart Level", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget puzzleBlock(String text, Color color, {bool isSmall = false}) {
    double horizontalPadding = isSmall ? 12 * _scaleFactor : 16 * _scaleFactor;
    double verticalPadding = isSmall ? 8 * _scaleFactor : 12 * _scaleFactor;
    double fontSize = isSmall ? 12 * _scaleFactor : 14 * _scaleFactor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15 * _scaleFactor),
          bottomRight: Radius.circular(15 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black45, width: 1.5 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3 * _scaleFactor,
            offset: Offset(2 * _scaleFactor, 2 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}