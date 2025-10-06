// lib/levels/php/level3.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import 'PhpBonusGame.dart';

class PhpLevel3 extends StatefulWidget {
  const PhpLevel3({super.key});

  @override
  State<PhpLevel3> createState() => _PhpLevel3State();
}

class _PhpLevel3State extends State<PhpLevel3> {
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
    // Correct blocks for: if ($age >= 18) {
    List<String> correctBlocks = [
      'if',
      '(',
      '\$age',
      '>=',
      '18',
      ')',
      '{'
    ];

    // Fewer and simpler incorrect blocks for beginners
    List<String> incorrectBlocks = [
      'else',
      'while',
      'for',
      '==',
      '<',
      '16',
      '}',
      ']',
      'switch',
      'case'
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

    // Less frequent penalties for beginners
    scoreReductionTimer = Timer.periodic(Duration(seconds: 30), (timer) {
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
        'PHP',
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
      MaterialPageRoute(builder: (context) => PhpBonusGame()),
    );
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScores(currentUser!['id'], 'PHP');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level3Data = scoresData['3'];

        if (level3Data != null) {
          setState(() {
            previousScore = level3Data['score'] ?? 0;
            level3Completed = level3Data['completed'] ?? false;
            hasPreviousScore = true;
            // DON'T set current score to previous score
            // score = previousScore; // REMOVED THIS LINE
          });
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'else', 'while', 'for', '==', '<', '16', '}', ']', 'switch', 'case'
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

    // Check for: if ($age >= 18) {
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    String expected = 'if(\$age>=18){';

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
                  'age_check.php',
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
                        _buildCodeLine(1, '<?php'),
                        _buildCodeLine(2, '\$age = 18;'),
                        _buildCodeLine(3, getPreviewCode()),
                        _buildCodeLine(4, '    echo "Adult";'),
                        _buildCodeLine(5, '} else {'),
                        _buildCodeLine(6, '    echo "Minor";'),
                        _buildCodeLine(7, '}'),
                        _buildCodeLine(8, '?>'),
                      ],
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSyntaxHighlightedLine('<?php', isPreprocessor: true),
                          _buildSyntaxHighlightedLine('\$age = 18;', isNormal: true),
                          _buildUserCodeLine(getPreviewCode()),
                          _buildSyntaxHighlightedLine('    echo "Adult";', isNormal: true),
                          _buildSyntaxHighlightedLine('} else {', isKeyword: true),
                          _buildSyntaxHighlightedLine('    echo "Minor";', isNormal: true),
                          _buildSyntaxHighlightedLine('}', isNormal: true),
                          _buildSyntaxHighlightedLine('?>', isPreprocessor: true),
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
          '        ',
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

    if (isPreprocessor) {
      textColor = Color(0xFF569CD6);
    } else if (isKeyword) {
      textColor = Color(0xFFDCDCAA);
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
        title: Text("🐘 PHP - Level 3", style: TextStyle(fontSize: 18 * _scaleFactor)),
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
              Color(0xFF1B0D1B),
              Color(0xFF2D1B2D),
              Color(0xFF553355),
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
                backgroundColor: Colors.purple,
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
                          style: TextStyle(color: Colors.greenAccent, fontSize: 14 * _scaleFactor),
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
                      style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
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
                            style: TextStyle(color: Colors.purpleAccent, fontSize: 12 * _scaleFactor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      Text(
                        "Bonus Game is unlocked! Play to unlock Level 4",
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
                color: Colors.purple[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Level 3 - If Statements",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Create an if statement: if (\$age >= 18) {",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Text(
                      'if (\$age >= 18) {',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14 * _scaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn how to make decisions in your PHP code!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.purple[600], fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    color: Colors.blue[50],
                    child: Column(
                      children: [
                        Text(
                          "What you'll learn:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scaleFactor),
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "• How to use if statements in PHP\n• Comparison operators (>=)\n• Making decisions in PHP code\n• Code blocks with { }",
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
                ? 'Si Zeke ay gustong gumawa ng decision sa kanyang PHP program! Kailangan niyang gumamit ng if statement para i-check kung ang edad ay 18 o mas mataas. Tulungan siyang buuin ang condition!'
                : 'Zeke wants to make a decision in his PHP program! He needs to use an if statement to check if the age is 18 or higher. Help him build the condition!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Arrange the blocks to create: if (\$age >= 18) {',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // TARGET AREA - Larger for better visibility
          Container(
            height: 160 * _scaleFactor,
            width: double.infinity,
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
                  setState(() {
                    droppedBlocks.add(data);
                    allBlocks.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Center(
                    child: Wrap(
                      spacing: 6 * _scaleFactor,
                      runSpacing: 6 * _scaleFactor,
                      alignment: WrapAlignment.center,
                      children: droppedBlocks.map((block) {
                        return Draggable<String>(
                          data: block,
                          feedback: puzzleBlock(block, Colors.greenAccent, isSmall: true),
                          childWhenDragging: puzzleBlock(block, Colors.greenAccent.withOpacity(0.5), isSmall: true),
                          child: puzzleBlock(block, Colors.greenAccent, isSmall: true),
                        );
                      }).toList(),
                    )
                );
              },
            ),
          ),

          SizedBox(height: 20 * _scaleFactor),
          Text('💻 Code Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          // SOURCE AREA - Better layout with smaller blocks
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
                  feedback: puzzleBlock(block, Colors.purple, isSmall: true),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.purple, isSmall: true),
                  ),
                  child: puzzleBlock(block, Colors.purple, isSmall: true),
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
              backgroundColor: Colors.purple,
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