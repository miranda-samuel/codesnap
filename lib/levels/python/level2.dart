import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';

class PythonLevel2 extends StatefulWidget {
  const PythonLevel2({super.key});

  @override
  State<PythonLevel2> createState() => _PythonLevel2State();
}

class _PythonLevel2State extends State<PythonLevel2> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level2Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 120;
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
    // Python variable assignment and print: name = "Juan" \n print(name)
    List<String> correctBlocks = [
      'name',
      '=',
      '"Juan"',
      'print',
      '(',
      'name',
      ')'
    ];

    // Incorrect/distractor blocks
    List<String> incorrectBlocks = [
      'var',
      'let',
      'const',
      'String',
      'str',
      'cout',
      'printf',
      'echo',
      'System.out.println',
      ';',
      ':',
      '==',
      '"Maria"',
      '"Pedro"',
      'age',
      'score',
      'print(',
      'print()',
      'write',
      'puts',
    ];

    // Shuffle incorrect blocks and take 5 random ones
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
      remainingSeconds = 120;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⏰ Time penalty! -1 point. Current score: $score")),
        );
      });
    });
  }

  void resetGame() {
    setState(() {
      score = 3;
      remainingSeconds = 120;
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
        2,
        score,
        score == 3,
      );

      if (response['success'] == true) {
        setState(() {
          level2Completed = score == 3;
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
        final level2Data = scoresData['2'];

        if (level2Data != null) {
          setState(() {
            previousScore = level2Data['score'] ?? 0;
            level2Completed = level2Data['completed'] ?? false;
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
      'var',
      'let',
      'const',
      'String',
      'str',
      'cout',
      'printf',
      'echo',
      'System.out.println',
      ';',
      ':',
      '==',
      '"Maria"',
      '"Pedro"',
      'age',
      'score',
      'print(',
      'print()',
      'write',
      'puts',
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
                child: Text("Retry"),
              )
            ],
          ),
        );
      }
      return;
    }

    // Check for: name = "Juan" \n print(name)
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    // Allow for both single line and multi-line arrangements
    bool isCorrect = normalizedAnswer == 'name="juan"print(name)' ||
        normalizedAnswer == 'name="juan"print(name)';

    if (isCorrect) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Excellent Python Developer!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've unlocked Level 3!",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to unlock the next level!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Code Output:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  "Juan",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Your Code:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.blue[50],
                child: Text(
                  getPreviewCode(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Python Concepts:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.green[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Variables - store data values"),
                    Text("• Assignment - = operator assigns values"),
                    Text("• Strings - text in double quotes"),
                    Text("• Print variables - use variable name without quotes"),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (score == 3) {
                  Navigator.pushReplacementNamed(context, '/python_level3');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels',
                      arguments: 'Python');
                }
              },
              child: Text(score == 3 ? "Next Level" : "Go Back"),
            )
          ],
        ),
      );
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

  Widget getCodePreview() {
    List<String> lines = getPreviewCode().split(' ');
    bool hasVariable = lines.contains('name') && lines.contains('=') && lines.contains('"Juan"');
    bool hasPrint = lines.contains('print') && lines.contains('(') && lines.contains('name') && lines.contains(')');

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
                  'variables.py',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildCodeLine(1, ''),
                        _buildCodeLine(2, ''),
                      ],
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    // Actual code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserCodeLine(getPreviewCode(), isVariable: hasVariable, isPrint: hasPrint),
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

  Widget _buildUserCodeLine(String code, {bool isVariable = false, bool isPrint = false}) {
    if (code.isEmpty) {
      return Container(
        height: 40 * _scaleFactor,
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

    // Split the code into parts for syntax highlighting
    List<String> parts = code.split(' ');

    return Container(
      height: 40 * _scaleFactor,
      child: Wrap(
        spacing: 4 * _scaleFactor,
        runSpacing: 4 * _scaleFactor,
        children: parts.map((part) {
          Color color = Colors.white;

          if (part == 'name' || part == 'print') {
            color = Color(0xFF569CD6); // Blue for keywords
          } else if (part == '=') {
            color = Colors.white;
          } else if (part == '"Juan"') {
            color = Color(0xFFCE9178); // Orange for strings
          } else if (part == '(' || part == ')') {
            color = Colors.white;
          }

          return Text(
            part,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontSize: 12 * _scaleFactor,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
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
        title: Text("🐍 Python - Level 2", style: TextStyle(fontSize: 18 * _scaleFactor)),
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
              label: Text("Start Game", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            if (level2Completed)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Level 2 completed with perfect score!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "You've unlocked Level 3!",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      style: TextStyle(color: Colors.blue, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Try again to get a perfect score and unlock Level 3!",
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
                color: Colors.blue[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Level 2 Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Create a variable and print its value:\nname = \"Juan\"\nprint(name)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.blue[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Text(
                      "name = \"Juan\"\nprint(name)",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14 * _scaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn Python variables and printing!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.blue[600], fontStyle: FontStyle.italic),
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
                  ? 'Si Juan ay natututo ng variables sa Python! Kailangan niyang mag-store ng kanyang pangalan sa variable at i-print ito. Tulungan mo siyang buuin ang tamang code!'
                  : 'Juan is learning about variables in Python! He needs to store his name in a variable and print it. Help him build the correct code!',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white70),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Text('🧩 Arrange the blocks to create:\nname = "Juan"\nprint(name)',
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
                  // Always accept blocks as long as game is not finished
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
                            feedback: puzzleBlock(block, Colors.yellowAccent),
                            childWhenDragging: puzzleBlock(block, Colors.yellowAccent.withOpacity(0.3)),
                            child: puzzleBlock(block, Colors.yellowAccent),
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
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Wrap(
                spacing: 8 * _scaleFactor,
                runSpacing: 10 * _scaleFactor,
                alignment: WrapAlignment.center,
                children: allBlocks.map((block) {
                  return isAnsweredCorrectly
                      ? puzzleBlock(block, Colors.grey)
                      : Draggable<String>(
                    data: block,
                    feedback: puzzleBlock(block, Colors.blueAccent),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: puzzleBlock(block, Colors.blueAccent),
                    ),
                    child: puzzleBlock(block, Colors.blueAccent),
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
              child: Text("🔁 Retry", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
            ),
            SizedBox(height: 20 * _scaleFactor),
          ],
        ),
      ),
    );
  }

  Widget puzzleBlock(String text, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scaleFactor,
        vertical: 10 * _scaleFactor,
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
          fontSize: 12 * _scaleFactor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}