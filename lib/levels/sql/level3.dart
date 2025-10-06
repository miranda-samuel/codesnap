
import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import 'SqlBonusGame.dart';

class SqlLevel3 extends StatefulWidget {
  const SqlLevel3({super.key});

  @override
  State<SqlLevel3> createState() => _SqlLevel3State();
}

class _SqlLevel3State extends State<SqlLevel3> {
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
    // Correct blocks for: SELECT * FROM products ORDER BY price DESC LIMIT 5;
    List<String> correctBlocks = [
      'SELECT',
      '*',
      'FROM',
      'products',
      'ORDER BY',
      'price',
      'DESC',
      'LIMIT',
      '5',
      ';'
    ];

    // Fewer and simpler incorrect blocks
    List<String> incorrectBlocks = [
      'SELECT name',
      'WHERE',
      'price > 100',
      'ASC',
      'LIMIT 10',
      'INSERT',
      'UPDATE',
      'category',
      'FROM products'
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
    countdownTimer?.cancel();
    scoreReductionTimer?.cancel();

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
                    Navigator.pop(context);
                    resetGame();
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
          SnackBar(
            content: Text("⏰ Time penalty! -1 point. Current score: $score"),
            backgroundColor: Colors.orange,
          ),
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
        'SQL',
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
                      color: Colors.orange,
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
                      color: Colors.orange[50],
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
                            color: Colors.orange[800],
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
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!isPerfectScore) {
                resetGame();
              }
            },
            child: Text(isPerfectScore ? "Continue" : "Try Again"),
          ),
        ],
      ),
    );
  }

  void _navigateToBonusGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SQLBonusGame()), // Changed to lowercase
    );
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScores(currentUser!['id'], 'SQL');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level3Data = scoresData['3'];

        if (level3Data != null) {
          setState(() {
            previousScore = level3Data['score'] ?? 0;
            level3Completed = level3Data['completed'] ?? false;
            hasPreviousScore = true;
          });
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'SELECT name', 'WHERE', 'price > 100', 'ASC', 'LIMIT 10', 'INSERT', 'UPDATE', 'category', 'FROM products'
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
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You used incorrect SQL syntax and lost all points!"),
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

    // Check for: SELECT * FROM products ORDER BY price DESC LIMIT 5;
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    String expected = 'select*fromproductsorderbypricedesclimit5;';

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
          SnackBar(
            content: Text("❌ Incorrect arrangement. -1 point. Current score: $score"),
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
                  'products_query.sql',
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
                        _buildCodeLine(1, getPreviewCode()),
                      ],
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserCodeLine(getPreviewCode()),
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
        title: Text("🗃️ SQL - Level 3", style: TextStyle(fontSize: 18 * _scaleFactor)),
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
              Color(0xFF1B150D),
              Color(0xFF2D261B),
              Color(0xFF554433),
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
                backgroundColor: Colors.orange,
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
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    if (previousScore > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 5 * _scaleFactor),
                        child: Text(
                          "Your Best Score: $previousScore/3",
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 14 * _scaleFactor),
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
                      style: TextStyle(color: Colors.orange, fontSize: 16 * _scaleFactor),
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
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 12 * _scaleFactor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      Text(
                        "Bonus Game is unlocked! Play to unlock Level 4",
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 14 * _scaleFactor),
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
                    "🎯 Level 3 - ORDER BY & LIMIT",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Create a query to get top 5 most expensive products:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.orange[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Text(
                      'SELECT * FROM products ORDER BY price DESC LIMIT 5;',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14 * _scaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn how to sort and limit query results!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.orange[600], fontStyle: FontStyle.italic),
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
                          "• Sorting results with ORDER BY\n• DESC for descending order\n• Limiting results with LIMIT\n• Complex query combinations",
                          style: TextStyle(fontSize: 11 * _scaleFactor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    color: Colors.orange[50],
                    child: Column(
                      children: [
                        Text(
                          "🎁 BONUS GAME REQUIREMENT:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scaleFactor, color: Colors.orange[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "Get a PERFECT SCORE (3/3) to unlock the Bonus Game!",
                          style: TextStyle(fontSize: 11 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3 * _scaleFactor),
                        Text(
                          "• Complete without time penalties\n• Don't use incorrect blocks\n• Finish with all 3 points",
                          style: TextStyle(fontSize: 10 * _scaleFactor, color: Colors.orange[600]),
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
                      color: Colors.orange,
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
    // Calculate dynamic height based on number of dropped blocks
    double calculateTargetHeight() {
      if (droppedBlocks.isEmpty) return 120 * _scaleFactor;

      // Estimate rows needed based on block count
      int estimatedRows = (droppedBlocks.length / 3).ceil();
      double baseHeight = 80 * _scaleFactor;
      double rowHeight = 60 * _scaleFactor;

      return baseHeight + (estimatedRows * rowHeight);
    }

    final targetHeight = calculateTargetHeight().clamp(120 * _scaleFactor, 400 * _scaleFactor);

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
                ? 'Ngayon, natututo si Zeke tungkol sa pag-sort at pag-limit ng results sa SQL! Kailangan niyang kunin ang top 5 pinaka-mamahaling products mula sa products table. Pwede mo ba siyang tulungan?'
                : 'Now, Zeke is learning about sorting and limiting results in SQL! He needs to retrieve the top 5 most expensive products from the products table. Can you help him?',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Arrange the blocks to create: SELECT * FROM products ORDER BY price DESC LIMIT 5;',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // AUTO-EXPANDING TARGET AREA
          Container(
            height: targetHeight,
            width: double.infinity,
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.orange, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<String>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                if (!isAnsweredCorrectly) {
                  setState(() {
                    droppedBlocks.add(data);
                    allBlocks.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return droppedBlocks.isEmpty
                    ? Center(
                  child: Text(
                    'Drop SQL blocks here\n\n(Tap and drag blocks from below)',
                    style: TextStyle(
                      fontSize: 16 * _scaleFactor,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : Wrap(
                  spacing: 8 * _scaleFactor,
                  runSpacing: 8 * _scaleFactor,
                  alignment: WrapAlignment.start,
                  children: droppedBlocks.map((block) {
                    return Draggable<String>(
                      data: block,
                      feedback: Material(
                        elevation: 4.0,
                        child: puzzleBlock(block, Colors.greenAccent),
                      ),
                      childWhenDragging: puzzleBlock(block, Colors.greenAccent.withOpacity(0.3)),
                      onDragStarted: () {
                        setState(() {
                          droppedBlocks.remove(block);
                        });
                      },
                      onDragEnd: (details) {
                        if (!details.wasAccepted) {
                          setState(() {
                            allBlocks.add(block);
                          });
                        }
                      },
                      child: puzzleBlock(block, Colors.greenAccent),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          SizedBox(height: 20 * _scaleFactor),
          Text('💻 Query Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          // SOURCE AREA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Blocks:', style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10 * _scaleFactor),
              Container(
                padding: EdgeInsets.all(12 * _scaleFactor),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12 * _scaleFactor),
                ),
                child: Wrap(
                  spacing: 8 * _scaleFactor,
                  runSpacing: 8 * _scaleFactor,
                  alignment: WrapAlignment.center,
                  children: allBlocks.map((block) {
                    return isAnsweredCorrectly
                        ? puzzleBlock(block, Colors.grey)
                        : Draggable<String>(
                      data: block,
                      feedback: Material(
                        elevation: 4.0,
                        child: puzzleBlock(block, Colors.orangeAccent),
                      ),
                      childWhenDragging: puzzleBlock(block, Colors.orangeAccent.withOpacity(0.3)),
                      onDragCompleted: () {
                        // Block was successfully dropped in target
                      },
                      child: puzzleBlock(block, Colors.orangeAccent),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          SizedBox(height: 30 * _scaleFactor),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : checkAnswer,
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Run Query", style: TextStyle(fontSize: 16 * _scaleFactor)),
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
            onPressed: resetGame,
            child: Text("🔁 Restart Level", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget puzzleBlock(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scaleFactor,
        vertical: 10 * _scaleFactor,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8 * _scaleFactor),
        border: Border.all(color: Colors.black45, width: 1.0 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2 * _scaleFactor,
            offset: Offset(1 * _scaleFactor, 1 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 13 * _scaleFactor,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}