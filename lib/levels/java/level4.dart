import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';

class JavaLevel4 extends StatefulWidget {
  const JavaLevel4({super.key});

  @override
  State<JavaLevel4> createState() => _JavaLevel4State();
}

class _JavaLevel4State extends State<JavaLevel4> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level4Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 300; // 5 minutes for complex level
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
    // COMBINED BLOCKS FROM LEVEL 1, 2, and 3
    List<String> correctBlocks = [
      // Level 1: Output statement
      'System.out.println', '(', '"Hello World"', ')', ';',

      // Level 2: Variable declaration
      'int', 'number', '=', '10', ';',

      // Level 3: If statement
      'if', '(', 'number', '>', '5', ')', '{'
    ];

    // Incorrect blocks from all levels
    List<String> incorrectBlocks = [
      // Incorrect output
      'cout', 'printf', 'print', 'Console.WriteLine',

      // Incorrect variable declaration
      'var', 'let', 'String', 'double', 'float',

      // Incorrect if statement
      'else', 'while', 'for', 'switch', '==', '<', '>=', '<=', '}', ']'
    ];

    // Take only 5 incorrect blocks to make it challenging but not too hard
    incorrectBlocks.shuffle();
    List<String> selectedIncorrectBlocks = incorrectBlocks.take(5).toList();

    // Combine correct and incorrect blocks, then shuffle
    allBlocks = [
      ...correctBlocks,
      ...selectedIncorrectBlocks,
    ]..shuffle();
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = 300;
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

    // Score reduction every 45 seconds for this complex level
    scoreReductionTimer = Timer.periodic(Duration(seconds: 45), (timer) {
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
      score = 3;
      remainingSeconds = 300;
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
        'Java',
        4, // Level 4
        score,
        true, // Mark as completed
      );

      if (response['success'] == true) {
        setState(() {
          level4Completed = true;
          previousScore = score;
          hasPreviousScore = true;
        });

        _showCompletionDialog();
      } else {
        print('Failed to save score: ${response['message']}');
      }
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("🎉 Level 4 Completed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 60, color: Colors.orange),
            SizedBox(height: 10),
            Text(
              "You've mastered Java Fundamentals!",
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
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.orange[50],
              child: Column(
                children: [
                  Text(
                    "🎓 Java Fundamentals Mastered:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("• Output with System.out.println"),
                  Text("• Variable declaration with int"),
                  Text("• If statements and conditions"),
                ],
              ),
            ),
            if (score < 3)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "💡 You can replay Level 4 anytime to improve your score!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        actions: [
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

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScores(currentUser!['id'], 'Java');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level4Data = scoresData['4'];

        if (level4Data != null) {
          setState(() {
            previousScore = level4Data['score'] ?? 0;
            level4Completed = level4Data['completed'] ?? false;
            hasPreviousScore = true;
            // DON'T set current score to previous score - start fresh
            // score = previousScore; // REMOVE THIS LINE
          });
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'cout', 'printf', 'print', 'Console.WriteLine',
      'var', 'let', 'String', 'double', 'float',
      'else', 'while', 'for', 'switch', '==', '<', '>=', '<=', '}', ']'
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

    // Check for the complete program combining all three levels
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    // Expected: System.out.println("HelloWorld");intnumber=10;if(number>5){
    String expected = 'system.out.println("helloworld");intnumber=10;if(number>5){';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildCodeLine(1, 'public class Main {'),
                        _buildCodeLine(2, '    public static void main(String[] args) {'),
                        _buildCodeLine(3, '        ' + getPreviewLine1()),
                        _buildCodeLine(4, '        ' + getPreviewLine2()),
                        _buildCodeLine(5, '        ' + getPreviewLine3()),
                        _buildCodeLine(6, '            System.out.println("Number > 5");'),
                        _buildCodeLine(7, '        }'),
                        _buildCodeLine(8, '    }'),
                        _buildCodeLine(9, '}'),
                      ],
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSyntaxHighlightedLine('public class Main {', isKeyword: true),
                          _buildSyntaxHighlightedLine('    public static void main(String[] args) {', isKeyword: true),
                          _buildUserCodeLine(getPreviewLine1()),
                          _buildUserCodeLine(getPreviewLine2()),
                          _buildUserCodeLine(getPreviewLine3()),
                          _buildSyntaxHighlightedLine('            System.out.println("Number > 5");', isNormal: true),
                          _buildSyntaxHighlightedLine('        }', isNormal: true),
                          _buildSyntaxHighlightedLine('    }', isNormal: true),
                          _buildSyntaxHighlightedLine('}', isNormal: true),
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

  String getPreviewLine1() {
    // Extract Level 1 blocks: System.out.println("Hello World");
    List<String> level1Blocks = ['System.out.println', '(', '"Hello World"', ')', ';'];
    return _extractBlocksForLine(level1Blocks);
  }

  String getPreviewLine2() {
    // Extract Level 2 blocks: int number = 10;
    List<String> level2Blocks = ['int', 'number', '=', '10', ';'];
    return _extractBlocksForLine(level2Blocks);
  }

  String getPreviewLine3() {
    // Extract Level 3 blocks: if (number > 5) {
    List<String> level3Blocks = ['if', '(', 'number', '>', '5', ')', '{'];
    return _extractBlocksForLine(level3Blocks);
  }

  String _extractBlocksForLine(List<String> targetBlocks) {
    String result = '';
    for (String block in droppedBlocks) {
      if (targetBlocks.contains(block)) {
        result += block + ' ';
      }
    }
    return result.trim();
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
              text: '        ',
              style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12 * _scaleFactor),
            ),
            TextSpan(
              text: code,
              style: TextStyle(
                color: Colors.orangeAccent[400],
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
        title: Text("☕ Java - Level 4", style: TextStyle(fontSize: 18 * _scaleFactor)),
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
              Color(0xFF1B0D0D),
              Color(0xFF2D1B1B),
              Color(0xFF553333),
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
              label: Text("Start Level 4", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.orange,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            if (level4Completed)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Level 4 Completed!",
                      style: TextStyle(color: Colors.orange, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "🎓 Java Fundamentals Mastered!",
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
                      style: TextStyle(color: Colors.orange, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Challenge yourself to get a perfect score!",
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
                    "🎯 Level 4 - Java Fundamentals Review",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Combine everything you've learned from Levels 1-3!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.orange[700], fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Build this program:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          'System.out.println("Hello World");\n'
                              'int number = 10;\n'
                              'if (number > 5) {',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontFamily: 'monospace',
                            fontSize: 12 * _scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Combine your knowledge of output, variables, and conditions!",
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
                          "What you'll review:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scaleFactor),
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "• Level 1: Output with System.out.println\n"
                              "• Level 2: Variable declaration with int\n"
                              "• Level 3: If statements and conditions\n"
                              "• Putting it all together in one program",
                          style: TextStyle(fontSize: 11 * _scaleFactor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    color: Colors.green[50],
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 16 * _scaleFactor),
                        SizedBox(width: 8 * _scaleFactor),
                        Expanded(
                          child: Text(
                            "⏰ 5 minutes - More time for this complex level!",
                            style: TextStyle(fontSize: 12 * _scaleFactor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
                child: Text('📖 Challenge Story',
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
                ? 'Ngayon ay kailangan mong pagsama-samahin ang lahat ng natutunan mo! Gumawa ng complete program na may output, variable declaration, at if statement. Ipakita na master mo na ang Java fundamentals!'
                : 'Now you need to combine everything you\'ve learned! Create a complete program with output, variable declaration, and if statement. Show that you\'ve mastered Java fundamentals!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Arrange blocks to create a complete Java program:',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 10 * _scaleFactor),
          Text('System.out.println("Hello World");  int number = 10;  if (number > 5) {',
              style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.orangeAccent, fontFamily: 'monospace'),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // TARGET AREA - Larger for more blocks
          Container(
            height: 200 * _scaleFactor,
            width: double.infinity,
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
                        feedback: puzzleBlock(block, Colors.orangeAccent, isSmall: true),
                        childWhenDragging: puzzleBlock(block, Colors.orangeAccent.withOpacity(0.5), isSmall: true),
                        child: puzzleBlock(block, Colors.orangeAccent, isSmall: true),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20 * _scaleFactor),
          Text('💻 Complete Program Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          // SOURCE AREA - More blocks for the complex level
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
                  feedback: puzzleBlock(block, Colors.orange, isSmall: true),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.orange, isSmall: true),
                  ),
                  child: puzzleBlock(block, Colors.orange, isSmall: true),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 30 * _scaleFactor),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : checkAnswer,
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Compile & Run", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
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