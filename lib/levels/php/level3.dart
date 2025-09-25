// lib/levels/php/level3.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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
    // Reduced blocks for PHP control structures (if-else)
    allBlocks = [
      '<?php',
      '\$age',
      '=',
      '18',
      ';',
      'if',
      '(\$age >= 18)',
      '{',
      'echo',
      '"Adult"',
      ';',
      '}',
      'else',
      '{',
      'echo',
      '"Minor"',
      ';',
      '}',
      '?>',
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

    // Score reduction timer (every 40 seconds)
    scoreReductionTimer = Timer.periodic(Duration(seconds: 40), (timer) {
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
    // Use consistent key format with LevelSelectionScreen
    await prefs.setInt('PHP_level3_score', score);
    // Only mark as completed if score is perfect
    if (score == 3) {
      await prefs.setBool('PHP_level3_completed', true);
      setState(() {
        level3Completed = true;
      });
    } else {
      await prefs.setBool('PHP_level3_completed', false);
      setState(() {
        level3Completed = false;
      });
    }
  }

  Future<void> loadScoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Use consistent key format with LevelSelectionScreen
    final savedScore = prefs.getInt('PHP_level3_score');
    final completed = prefs.getBool('PHP_level3_completed') ?? false;

    setState(() {
      if (savedScore != null) {
        score = savedScore;
        previousScore = savedScore;
        hasPreviousScore = true;
      }
      // Only show as completed if score is perfect
      level3Completed = completed && score == 3;
    });
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer.replaceAll(' ', '').toLowerCase();
    String normalizedCorrect = '<?php\$age=18;if(\$age>=18){echo"adult";}else{echo"minor";}?>'.toLowerCase();

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
              Text("Great job with PHP control structures!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've completed Level 3!",
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
                  "Adult",
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
                  Navigator.pushReplacementNamed(context, '/php_level4');
                } else {
                  // If not perfect score, go back to level selection
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
        title: Text("🐘 PHP - Level 3: Control Structures"),
        backgroundColor: Colors.purple,
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
                backgroundColor: Colors.purple),
          ),
          SizedBox(height: 20),

          // Show different messages based on previous performance
          if (level3Completed)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    "✅ Level 3 completed with perfect score!",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "You've mastered control structures!",
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: Colors.purple, fontSize: 16),
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
              // Use consistent key format with LevelSelectionScreen
              await prefs.remove('PHP_level3_completed');
              await prefs.remove('PHP_level3_score');
              setState(() {
                level3Completed = false;
                hasPreviousScore = false;
                previousScore = 0;
                score = 3;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
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
                ? 'Ngayon, natututo si Zeke tungkol sa control structures sa PHP! Gusto niyang gumamit ng if-else statement para i-check kung ang edad ay sapat na para maging adult. Pwede mo ba siyang tulungan?'
                : 'Now, Zeke is learning about control structures in PHP! He wants to use an if-else statement to check if an age is sufficient to be an adult. Can you help him?',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text('🧩 Arrange the puzzle blocks to create an if-else statement:',
              style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          SizedBox(height: 20),
          Container(
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.purple, width: 2.5),
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
                feedback: puzzleBlock(block, Colors.purpleAccent),
                childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.purpleAccent)),
                child: puzzleBlock(block, Colors.purpleAccent),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : checkAnswer,
            icon: Icon(Icons.play_arrow),
            label: Text("Run Code"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
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
