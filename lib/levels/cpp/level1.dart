import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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
  int remainingSeconds = 120;
  Timer? countdownTimer;
  Timer? scoreReductionTimer;

  @override
  void initState() {
    super.initState();
    resetBlocks();
    loadScoreFromPrefs();
  }

  void resetBlocks() {
    // Basic C++ program blocks for Level 1
    allBlocks = [
      '#include <iostream>',
      'using namespace std;',
      'int main()',
      '{',
      'cout << "Hello, World!";',
      'return 0;',
      '}',
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
    // Main countdown timer
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
          saveScoreToPrefs(score);
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

    // Score reduction timer (every 20 seconds)
    scoreReductionTimer = Timer.periodic(Duration(seconds: 20), (timer) {
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

  Future<void> saveScoreToPrefs(int score) async {
    final prefs = await SharedPreferences.getInstance();
    // FIXED: Use consistent key format with LevelSelectionScreen
    await prefs.setInt('C++_level1_score', score);
    // Only mark as completed if score is perfect
    if (score == 3) {
      await prefs.setBool('C++_level1_completed', true);
      setState(() {
        level1Completed = true;
      });
    } else {
      await prefs.setBool('C++_level1_completed', false);
      setState(() {
        level1Completed = false;
      });
    }
  }

  Future<void> loadScoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // FIXED: Use consistent key format with LevelSelectionScreen
    final savedScore = prefs.getInt('C++_level1_score');
    final completed = prefs.getBool('C++_level1_completed') ?? false;

    setState(() {
      if (savedScore != null) {
        score = savedScore;
        previousScore = savedScore;
        hasPreviousScore = true;
      }
      // Only show as completed if score is perfect
      level1Completed = completed && score == 3;
    });
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer.replaceAll(' ', '').toLowerCase();
    String normalizedCorrect = '#include<iostream>usingnamespacestd;intmain(){cout<<"hello,world!";return0;}'.toLowerCase();

    if (normalizedAnswer == normalizedCorrect) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToPrefs(score);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Great job with your first C++ program!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've completed Level 1!",
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to mark this level as completed!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Code Output:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  "Hello, World!",
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
                  // Only navigate to next level if perfect score
                  Navigator.pushReplacementNamed(context, '/cpp_level2');
                } else {
                  // If not perfect score, go back to level selection
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
        saveScoreToPrefs(score);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Incorrect. -1 point. Current score: $score")),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToPrefs(score);
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
        title: Text("💻 C++ - Level 1: Hello World"),
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

          // Show different messages based on previous performance
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
                    "You've mastered the basics!",
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
                    "Try again to get a perfect score!",
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

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              // FIXED: Use consistent key format with LevelSelectionScreen
              await prefs.remove('C++_level1_score');
              await prefs.remove('C++_level1_completed');
              setState(() {
                level1Completed = false;
                hasPreviousScore = false;
                previousScore = 0;
                score = 3;
              });
            },
            child: Text("Reset Progress"),
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
                ? 'Si Zeke ay nagsisimula palang matuto ng C++! Gusto niyang gumawa ng kanyang unang programa na magpi-print ng "Hello, World!". Pwede mo ba siyang tulungan?'
                : 'Zeke is just starting to learn C++! He wants to create his first program that prints "Hello, World!". Can you help him?',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text('🧩 Arrange the puzzle blocks to form a complete C++ program:',
              style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          SizedBox(height: 20),
          Container(
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.blueGrey, width: 2.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DragTarget<String>(
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
                    alignment: WrapAlignment.center,
                    children: droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: puzzleBlock(block, Colors.greenAccent),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: puzzleBlock(block, Colors.greenAccent),
                        ),
                        child: puzzleBlock(block, Colors.greenAccent),
                        onDraggableCanceled: (velocity, offset) {
                          if (!isAnsweredCorrectly) {
                            setState(() {
                              if (!allBlocks.contains(block)) {
                                allBlocks.add(block);
                              }
                              droppedBlocks.remove(block);
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
            color: Colors.grey[300],
            child: Text(
              getPreviewCode(),
              style: TextStyle(fontFamily: 'monospace', fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          // Source area for blocks
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
                    child: puzzleBlock(block, Colors.blueAccent)),
                child: puzzleBlock(block, Colors.blueAccent),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : checkAnswer,
            icon: Icon(Icons.play_arrow),
            label: Text("Run Code"),
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
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
      ),
    );
  }
}
