import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';

class JavaLevel1 extends StatefulWidget {
  const JavaLevel1({super.key});

  @override
  State<JavaLevel1> createState() => _JavaLevel1State();
}

class _JavaLevel1State extends State<JavaLevel1> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level1Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 90;
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  // Track currently dragged block
  String? currentlyDraggedBlock;

  @override
  void initState() {
    super.initState();
    resetBlocks();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      currentUser = user;
    });
    loadScoreFromDatabase();
  }

  void resetBlocks() {
    // Simple blocks for Java Hello World - System.out.println("Hello World");
    List<String> correctBlocks = [
      'System.out.println',
      '(',
      '"Hello World"',
      ')',
      ';'
    ];

    // Incorrect/distractor blocks
    List<String> incorrectBlocks = [
      'System.out.print',
      'System.out.print("Hello World")',
      'print("Hello World")',
      'Console.WriteLine("Hello World")',
      'printf("Hello World")',
      'cout << "Hello World"',
      '"Hello"',
      '"Hi World"',
      '()',
      '();',
      'println',
      'System.out',
    ];

    // Shuffle incorrect blocks and take 3 random ones
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
      score = 3;
      remainingSeconds = 90;
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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 15), (timer) {
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
      remainingSeconds = 90;
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
        1,
        score,
        score == 3, // Only completed if perfect score
      );

      if (response['success'] == true) {
        setState(() {
          level1Completed = score == 3;
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
      final response = await ApiService.getScores(currentUser!['id'], 'Java');

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
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  Future<void> refreshScore() async {
    if (currentUser?['id'] != null) {
      try {
        final response = await ApiService.getScores(currentUser!['id'], 'Java');
        if (response['success'] == true && response['scores'] != null) {
          final scoresData = response['scores'];
          final level1Data = scoresData['1'];

          setState(() {
            if (level1Data != null) {
              previousScore = level1Data['score'] ?? 0;
              level1Completed = level1Data['completed'] ?? false;
              hasPreviousScore = true;
              score = previousScore;
            } else {
              hasPreviousScore = false;
              previousScore = 0;
              level1Completed = false;
              score = 3;
            }
          });
        }
      } catch (e) {
        print('Error refreshing score: $e');
      }
    }
  }

  // Check if a block is incorrect
  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'System.out.print',
      'System.out.print("Hello World")',
      'print("Hello World")',
      'Console.WriteLine("Hello World")',
      'printf("Hello World")',
      'cout << "Hello World"',
      '"Hello"',
      '"Hi World"',
      '();',
      'println',
      'System.out',
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

    // Simple check for: System.out.println("Hello World");
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    // Exact match for the simple version
    String expected = 'system.out.println("helloworld");';

    if (normalizedAnswer == expected) {
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
              Text("Well done Java Developer!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've unlocked Level 2!",
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
                  "Hello World",
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
                color: Colors.orange[50],
                child: Text(
                  getPreviewCode(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (score == 3) {
                  Navigator.pushReplacementNamed(context, '/java_level2');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels',
                      arguments: 'Java');
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

  // BAGONG PREVIEW NA MAY CODE EDITOR STYLE
  Widget getCodePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark background like VS Code
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code editor header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.grey[400], size: 16),
                SizedBox(width: 8),
                Text(
                  'HelloWorld.java',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Code content
          Container(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers and code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildCodeLine(1, 'public class HelloWorld {'),
                        _buildCodeLine(2, '    public static void main(String[] args) {'),
                        _buildCodeLine(3, '        ' + getPreviewCode()),
                        _buildCodeLine(4, '    }'),
                        _buildCodeLine(5, '}'),
                      ],
                    ),
                    SizedBox(width: 16),
                    // Actual code with syntax highlighting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSyntaxHighlightedLine('public class HelloWorld {', isKeyword: true),
                          _buildSyntaxHighlightedLine('    public static void main(String[] args) {', isKeyword: true),
                          _buildUserCodeLine('        ' + getPreviewCode()),
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

  Widget _buildCodeLine(int lineNumber, String code) {
    return Container(
      height: 20,
      child: Text(
        lineNumber.toString().padLeft(2, ' '),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildSyntaxHighlightedLine(String code, {bool isKeyword = false, bool isNormal = false}) {
    Color textColor = Colors.white; // Default color

    if (isKeyword) {
      textColor = Color(0xFF569CD6); // Blue for keywords
    } else if (isNormal) {
      textColor = Colors.white; // White for normal code
    }

    return Container(
      height: 20,
      child: Text(
        code,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildUserCodeLine(String code) {
    // Highlight the user's code in green
    if (getPreviewCode().isNotEmpty) {
      return Container(
        height: 20,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '        ', // Indentation
                style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
              ),
              TextSpan(
                text: getPreviewCode(),
                style: TextStyle(
                  color: Colors.greenAccent[400],
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 20,
      child: Text(
        code,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
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
    return Scaffold(
      appBar: AppBar(
        title: Text("☕ Java - Level 1"),
        backgroundColor: Colors.orange,
        actions: gameStarted
            ? [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.timer),
                SizedBox(width: 4),
                Text(formatTime(remainingSeconds)),
                SizedBox(width: 16),
                Icon(Icons.star, color: Colors.yellowAccent),
                Text(" $score",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ]
            : [],
      ),
      body: gameStarted ? buildGameUI() : buildStartScreen(),
    );
  }

  Widget buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: startGame,
            icon: Icon(Icons.play_arrow),
            label: Text("Start Game"),
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.orange),
          ),
          SizedBox(height: 20),

          if (level1Completed)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    "✅ Level 1 completed with perfect score!",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "You've unlocked Level 2!",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          else if (hasPreviousScore && previousScore > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    "📊 Your previous score: $previousScore/3",
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Try again to get a perfect score and unlock Level 2!",
                    style: TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (hasPreviousScore && previousScore == 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Text(
                      "😅 Your previous score: $previousScore/3",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Don't give up! You can do better this time!",
                      style: TextStyle(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                Text(
                  "🎯 Level 1 Objective",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                ),
                SizedBox(height: 10),
                Text(
                  "Arrange the code blocks to create: System.out.println(\"Hello World\");",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.orange[700]),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black,
                  child: Text(
                    "System.out.println(\"Hello World\");",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGameUI() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('📖 Short Story',
                    style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    isTagalog = !isTagalog;
                  });
                },
                icon: Icon(Icons.translate, size: isSmallScreen ? 16 : 20),
                label: Text(isTagalog ? 'English' : 'Tagalog',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            isTagalog
                ? 'Si Maria ay natututo ng Java programming! Kailangan niyang gumamit ng System.out.println para mag-display ng "Hello World". Tulungan mo siyang buuin ang tamang code!'
                : 'Maria is learning Java programming! She needs to use System.out.println to display "Hello World". Help her build the correct code!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          ),
          SizedBox(height: 20),

          Text('🧩 Arrange the blocks to form: System.out.println("Hello World");',
              style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
              textAlign: TextAlign.center),
          SizedBox(height: 20),

          // TARGET AREA
          Container(
            height: isSmallScreen ? 120 : 140,
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.orange, width: 2.5),
              borderRadius: BorderRadius.circular(20),
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
                    spacing: isSmallScreen ? 4 : 8,
                    runSpacing: isSmallScreen ? 4 : 8,
                    alignment: WrapAlignment.center,
                    children: droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: puzzleBlock(block, Colors.greenAccent, isSmallScreen, isMediumScreen),
                        childWhenDragging: puzzleBlock(block, Colors.greenAccent.withOpacity(0.5), isSmallScreen, isMediumScreen),
                        child: puzzleBlock(block, Colors.greenAccent, isSmallScreen, isMediumScreen),
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
                );
              },
            ),
          ),

          SizedBox(height: 20),
          Text('💻 Code Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 16 : 18)),
          SizedBox(height: 10),
          // BAGONG CODE PREVIEW NA MAY EDITOR STYLE
          getCodePreview(),
          SizedBox(height: 20),

          // SOURCE AREA
          Wrap(
            spacing: isSmallScreen ? 6 : 10,
            runSpacing: isSmallScreen ? 8 : 12,
            alignment: WrapAlignment.center,
            children: allBlocks.map((block) {
              return isAnsweredCorrectly
                  ? puzzleBlock(block, Colors.grey, isSmallScreen, isMediumScreen)
                  : Draggable<String>(
                data: block,
                feedback: puzzleBlock(block, Colors.orangeAccent, isSmallScreen, isMediumScreen),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: puzzleBlock(block, Colors.orangeAccent, isSmallScreen, isMediumScreen),
                ),
                child: puzzleBlock(block, Colors.orangeAccent, isSmallScreen, isMediumScreen),
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

          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : checkAnswer,
            icon: Icon(Icons.play_arrow),
            label: Text("Run Code", style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 24,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
          ),
          TextButton(
            onPressed: resetGame,
            child: Text("🔁 Retry", style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
          ),
        ],
      ),
    );
  }

  Widget puzzleBlock(String text, Color color, bool isSmallScreen, bool isMediumScreen) {
    double fontSize = isSmallScreen ? 12 : (isMediumScreen ? 14 : 16);
    double horizontalPadding = isSmallScreen ? 12 : 16;
    double verticalPadding = isSmallScreen ? 8 : 12;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 3),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSmallScreen ? 15 : 20),
          bottomRight: Radius.circular(isSmallScreen ? 15 : 20),
        ),
        border: Border.all(color: Colors.black45, width: isSmallScreen ? 1.0 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: isSmallScreen ? 3 : 4,
            offset: Offset(2, 2),
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