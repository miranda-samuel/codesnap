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
    // Correct blocks for C++
    List<String> correctBlocks = [
      '#include <iostream>',
      'using namespace std;',
      'int main() {',
      'cout << "Hello World";',
      'return 0;',
      '}',
    ];

    // Incorrect/distractor blocks for C++
    List<String> incorrectBlocks = [
      '#include <stdio.h>',
      'using namespace std',
      'void main() {',
      'printf("Hello World")',
      'System.out.print("Hello World")',
      'print("Hello World")',
      'console.log("Hello World")',
      'return 1;',
      'return;',
      'end',
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
          // SAVE ONLY WHEN TIME'S UP (game completed)
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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        // DON'T save intermediate penalties
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
      'using namespace std',
      'void main() {',
      'printf("Hello World")',
      'System.out.print("Hello World")',
      'print("Hello World")',
      'console.log("Hello World")',
      'return 1;',
      'return;',
      'end',
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
            content: Text("❌ You used incorrect C++ code! -1 point. Current score: $score"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        // SAVE ONLY WHEN GAME IS OVER (score = 0)
        saveScoreToDatabase(score);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You used incorrect C++ code and lost all points!"),
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

    // Check if the arrangement is correct
    String userCode = droppedBlocks.join('\n');
    String normalizedUserCode = userCode.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();
    String correctCode = """
#include <iostream>
using namespace std;
int main() {
cout << "Hello World";
return 0;
}
""";
    String normalizedCorrectCode = correctCode.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();

    if (normalizedUserCode == normalizedCorrectCode) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      // ONLY SAVE WHEN ANSWER IS CORRECT (GAME COMPLETED)
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
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
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
      // DON'T SAVE INTERMEDIATE PENALTIES - just show message
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
        // SAVE ONLY WHEN GAME IS OVER (score = 0)
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

  String getPreviewCode() {
    return droppedBlocks.join('\n');
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
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
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
        ],
      ),
    );
  }

  Widget buildGameUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📖 Short Story',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    isTagalog = !isTagalog;
                  });
                },
                icon: Icon(Icons.translate),
                label: Text(isTagalog ? 'English' : 'Tagalog'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            isTagalog
                ? 'Si Alex ay nagsisimula matuto ng C++! Gusto niyang gumawa ng kanyang unang program na magdi-display ng "Hello World". Pwede mo ba siyang tulungan buuin ang tamang C++ code?'
                : 'Alex is starting to learn C++! He wants to create his first program that displays "Hello World". Can you help him build the correct C++ code?',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),

          Text('🧩 Arrange the puzzle blocks to form a complete C++ Hello World program:',
              style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          SizedBox(height: 20),

          // TARGET AREA - FIXED OVERFLOW ISSUE
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 140,
              maxHeight: 300, // Increased max height to accommodate multiple lines
            ),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.blueGrey, width: 2.5),
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
                return droppedBlocks.isEmpty
                    ? Center(
                  child: Text(
                    'Drag C++ code blocks here...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
                    : SingleChildScrollView( // Added ScrollView to prevent overflow
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: puzzleBlock(block, Colors.greenAccent),
                        childWhenDragging: puzzleBlock(block, Colors.greenAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.greenAccent),
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
          Text('📝 Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            height: 120,
            color: Colors.grey[300],
            child: SingleChildScrollView(
              child: Text(
                getPreviewCode(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // SOURCE AREA
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: allBlocks.map((block) {
              return isAnsweredCorrectly
                  ? puzzleBlock(block, Colors.grey)
                  : Draggable<String>(
                data: block,
                feedback: puzzleBlock(block, Colors.blueAccent),
                childWhenDragging: Opacity(
                  opacity: 0.4,
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

          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : checkAnswer,
            icon: Icon(Icons.play_arrow),
            label: Text("Compile & Run"),
          ),
          TextButton(
            onPressed: resetGame,
            child: Text("🔁 Retry"),
          ),
        ],
      ),
    );
  }

  Widget puzzleBlock(String text, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: Colors.black45, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}