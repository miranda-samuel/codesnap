import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';

class CppLevel1 extends StatefulWidget {
  const CppLevel1({super.key});

  @override
  State<CppLevel1> createState() => _CppLevel1State();
}

class _CppLevel1State extends State<CppLevel1> {
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
    // Correct blocks for C++ Hello World
    List<String> correctBlocks = [
      '#include <iostream>',
      'using namespace std;',
      'int main()',
      '{',
      'cout',
      '<<',
      '"Hello World"',
      ';',
      'return 0;',
      '}'
    ];

    // Incorrect/distractor blocks for C++
    List<String> incorrectBlocks = [
      '#include <stdio.h>',
      '#include <iostream.h>',
      'using namespace std',
      'void main()',
      'main()',
      'printf',
      'cout >>',
      '<<<',
      '>>>',
      'System.out.print',
      '"Hello"',
      '"Hi World"',
      'return 1;',
      'end',
      '}',
      '{',
      'endl',
      'cin',
      'std::cout',
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
        'C++',
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
      final response = await ApiService.getScores(currentUser!['id'], 'C++');

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
        final response = await ApiService.getScores(currentUser!['id'], 'C++');
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
      '#include <stdio.h>',
      '#include <iostream.h>',
      'using namespace std',
      'void main()',
      'main()',
      'printf',
      'cout >>',
      '<<<',
      '>>>',
      'System.out.print',
      '"Hello"',
      '"Hi World"',
      'return 1;',
      'end',
      'endl',
      'cin',
      'std::cout',
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

    // For C++, we need to check the logical structure rather than exact string match
    // since there can be variations in formatting
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    // Expected structure variations
    String expected1 = '#include<iostream>usingnamespacestd;intmain(){cout<<"helloworld";return0;}';
    String expected2 = '#include<iostream>usingnamespacestd;intmain(){cout<<"helloworld";return0;}';

    if (normalizedAnswer.contains('include<iostream>') &&
        normalizedAnswer.contains('usingnamespacestd') &&
        normalizedAnswer.contains('intmain') &&
        normalizedAnswer.contains('cout<<"helloworld"') &&
        normalizedAnswer.contains('return0')) {

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
              Text("Well done C++ Programmer!"),
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
              Text("Complete Code:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.blue[50],
                child: Text(
                  getFormattedCode(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
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
                  Navigator.pushReplacementNamed(context, '/cpp_level2');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels',
                      arguments: 'C++');
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

  String getFormattedCode() {
    // Format the code with proper indentation for display
    List<String> formatted = [];
    for (int i = 0; i < droppedBlocks.length; i++) {
      String block = droppedBlocks[i];
      if (block == '{') {
        formatted.add(block);
      } else if (block == '}') {
        formatted.add('  $block');
      } else if (block.startsWith('cout') || block.startsWith('return')) {
        formatted.add('  $block');
      } else {
        formatted.add(block);
      }
    }
    return formatted.join('\n');
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
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
        title: Text("⚡ C++ - Level 1"),
        backgroundColor: Colors.blue,
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
                backgroundColor: Colors.blue),
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
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: Colors.blue, fontSize: 16),
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
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Text(
                  "🎯 Level 1 Objective",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
                SizedBox(height: 10),
                Text(
                  "Create a complete C++ program that outputs 'Hello World' to the console. "
                      "You'll need to include the necessary headers and main function structure.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.blue[700]),
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
                ? 'Si Alex ay baguhan sa C++ programming! Kailangan niyang gumawa ng kanyang unang program na magdi-display ng "Hello World". Tulungan mo siyang buuin ang tamang C++ code!'
                : 'Alex is new to C++ programming! He needs to create his first program that displays "Hello World". Help him build the correct C++ code!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          ),
          SizedBox(height: 20),

          Text('🧩 Arrange the blocks to form a complete C++ Hello World program:',
              style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
              textAlign: TextAlign.center),
          SizedBox(height: 20),

          // TARGET AREA
          Container(
            height: isSmallScreen ? 180 : 200,
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.blue, width: 2.5),
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
          Text('📝 Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 16 : 18)),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            width: double.infinity,
            color: Colors.grey[300],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                getPreviewCode(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
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
                feedback: puzzleBlock(block, Colors.blueAccent, isSmallScreen, isMediumScreen),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: puzzleBlock(block, Colors.blueAccent, isSmallScreen, isMediumScreen),
                ),
                child: puzzleBlock(block, Colors.blueAccent, isSmallScreen, isMediumScreen),
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
            label: Text("Compile & Run", style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
    double fontSize = isSmallScreen ? 10 : (isMediumScreen ? 12 : 14);
    double horizontalPadding = isSmallScreen ? 10 : 14;
    double verticalPadding = isSmallScreen ? 6 : 10;

    // Adjust for longer C++ code blocks
    if (text.length > 15) {
      fontSize = isSmallScreen ? 8 : (isMediumScreen ? 10 : 12);
      horizontalPadding = isSmallScreen ? 6 : 8;
    } else if (text.length > 10) {
      fontSize = isSmallScreen ? 9 : (isMediumScreen ? 11 : 13);
      horizontalPadding = isSmallScreen ? 8 : 10;
    }

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
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
    );
  }
}