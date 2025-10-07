import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // ADD THIS IMPORT
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import '../../services/music_service.dart'; // ADD THIS IMPORT

class CppLevel2 extends StatefulWidget {
  const CppLevel2({super.key});

  @override
  State<CppLevel2> createState() => _CppLevel2State();
}

class _CppLevel2State extends State<CppLevel2> {
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
    _startGameMusic(); // ADD THIS
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic(); // STOP REGULAR MUSIC
      await musicService.playSoundEffect('game_start.mp3'); // GAME START SOUND
      await Future.delayed(Duration(milliseconds: 500));
      // PLAY GAME BACKGROUND MUSIC
      await musicService.playSoundEffect('game_music.mp3');
    });
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
    // Correct blocks for: int age = 25;
    List<String> correctBlocks = [
      'int',
      'age',
      '=',
      '25',
      ';'
    ];

    // Incorrect/distractor blocks
    List<String> incorrectBlocks = [
      'string',
      'double',
      'char',
      'float',
      'bool',
      'name',
      'height',
      'score',
      '==',
      '!=',
      '++',
      '--',
      '25.5',
      '"25"',
      'true',
      "'A'",
    ];

    // Shuffle incorrect blocks and take 4 random ones
    incorrectBlocks.shuffle();
    List<String> selectedIncorrectBlocks = incorrectBlocks.take(4).toList();

    // Combine correct and incorrect blocks, then shuffle
    allBlocks = [
      ...correctBlocks,
      ...selectedIncorrectBlocks,
    ]..shuffle();
  }

  void startGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3'); // ADD LEVEL START SOUND

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

          final musicService = Provider.of<MusicService>(context, listen: false);
          musicService.playSoundEffect('time_up.mp3'); // TIME UP SOUND

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("⏰ Time's Up!"),
              content: Text("Score: $score"),
              actions: [
                TextButton(
                  onPressed: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('click.mp3');
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
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty.mp3'); // PENALTY SOUND

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⏰ Time penalty! -1 point. Current score: $score")),
        );
      });
    });
  }

  void resetGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3'); // RESET SOUND

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
        'C++',
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
      final response = await ApiService.getScores(currentUser!['id'], 'C++');

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

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'string', 'double', 'char', 'float', 'bool',
      'name', 'height', 'score', '==', '!=', '++', '--',
      '25.5', '"25"', 'true', "'A'",
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      musicService.playSoundEffect('error.mp3'); // ERROR SOUND

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

        musicService.playSoundEffect('game_over.mp3'); // GAME OVER SOUND

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You used incorrect code and lost all points!"),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
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

    // Check for: int age = 25;
    String answer = droppedBlocks.join(' ');
    String normalizedAnswer = answer
        .replaceAll(' ', '')
        .replaceAll('\n', '')
        .toLowerCase();

    String expected = 'intage=25;';

    if (normalizedAnswer == expected) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      // PLAY SUCCESS SOUND BASED ON SCORE
      if (score == 3) {
        musicService.playSoundEffect('perfect.mp3'); // PERFECT SCORE SOUND
      } else {
        musicService.playSoundEffect('success.mp3'); // SUCCESS SOUND
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Great job! You created a variable!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've mastered Level 2!",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to complete this level!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Variable Created:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  "int age = 25;",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Explanation:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• 'int' - data type for whole numbers"),
                    Text("• 'age' - variable name"),
                    Text("• '=' - assignment operator"),
                    Text("• '25' - value assigned to variable"),
                    Text("• ';' - end of statement"),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (score == 3)
              TextButton(
                onPressed: () {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('level_complete.mp3');
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pushReplacementNamed(context, '/cpp_level3'); // NEXT LEVEL
                },
                child: Text("Next Level"),
              ),
            TextButton(
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                if (score == 3) {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: 'C++');
                } else {
                  resetGame();
                }
              },
              child: Text(score == 3 ? "Go Back to Levels" : "Try Again"),
            )
          ],
        ),
      );
    } else {
      musicService.playSoundEffect('wrong.mp3'); // WRONG ANSWER SOUND

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

        musicService.playSoundEffect('game_over.mp3'); // GAME OVER SOUND

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You lost all your points."),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
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
                  'main.cpp',
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
                        _buildCodeLine(1, '#include <iostream>'),
                        _buildCodeLine(2, 'using namespace std;'),
                        _buildCodeLine(3, ''),
                        _buildCodeLine(4, 'int main() {'),
                        _buildCodeLine(5, '    ' + getPreviewCode()),
                        _buildCodeLine(6, '    cout << age;'),
                        _buildCodeLine(7, '    return 0;'),
                        _buildCodeLine(8, '}'),
                      ],
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSyntaxHighlightedLine('#include <iostream>', isPreprocessor: true),
                          _buildSyntaxHighlightedLine('using namespace std;', isKeyword: true),
                          SizedBox(height: 8 * _scaleFactor),
                          _buildSyntaxHighlightedLine('int main() {', isKeyword: true),
                          _buildSyntaxHighlightedLine('    ' + getPreviewCode(), isNormal: true),
                          _buildSyntaxHighlightedLine('    cout << age;', isNormal: true),
                          _buildSyntaxHighlightedLine('    return 0;', isKeyword: true),
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
      textColor = Color(0xFFCE9178);
    } else if (isKeyword) {
      textColor = Color(0xFF569CD6);
    } else if (isNormal) {
      textColor = Colors.white;
    }

    if (isNormal && code.contains(getPreviewCode()) && getPreviewCode().isNotEmpty) {
      return Container(
        height: 20 * _scaleFactor,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '    ',
                style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12 * _scaleFactor),
              ),
              TextSpan(
                text: getPreviewCode(),
                style: TextStyle(
                  color: Colors.blueAccent[400],
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

    // RESTORE REGULAR BACKGROUND MUSIC WHEN LEAVING GAME
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.playBackgroundMusic();
    });

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
        title: Text("⚡ C++ - Level 2", style: TextStyle(fontSize: 18 * _scaleFactor)),
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
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
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
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                startGame();
              },
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Start Level 2", style: TextStyle(fontSize: 16 * _scaleFactor)),
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
                      style: TextStyle(color: Colors.blue, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "You've mastered variables!",
                      style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      "Try again to get a perfect score!",
                      style: TextStyle(color: Colors.lightGreen, fontSize: 14 * _scaleFactor),
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
                    "Create a variable to store age: int age = 25;",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.green[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Text(
                      "int age = 25;",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14 * _scaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn about variables and data types!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.green[600], fontStyle: FontStyle.italic),
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
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('toggle.mp3');
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
                ? 'Si Maria ay gustong mag-store ng kanyang edad sa program! Gamitin ang "int" data type para gumawa ng variable na "age" at i-assign ang value na 25.'
                : 'Maria wants to store her age in the program! Use the "int" data type to create an "age" variable and assign the value 25.',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Arrange the blocks to create: int age = 25;',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // TARGET AREA
          Container(
            height: 140 * _scaleFactor,
            width: double.infinity,
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.green, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<String>(
              onWillAccept: (data) {
                return !droppedBlocks.contains(data);
              },
              onAccept: (data) {
                if (!isAnsweredCorrectly) {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_drop.mp3'); // BLOCK DROP SOUND

                  setState(() {
                    droppedBlocks.add(data);
                    allBlocks.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Center(
                  child: Wrap(
                    spacing: 8 * _scaleFactor,
                    runSpacing: 8 * _scaleFactor,
                    alignment: WrapAlignment.center,
                    children: droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: puzzleBlock(block, Colors.lightGreenAccent),
                        childWhenDragging: puzzleBlock(block, Colors.lightGreenAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.lightGreenAccent),
                        onDragStarted: () {
                          final musicService = Provider.of<MusicService>(context, listen: false);
                          musicService.playSoundEffect('block_pickup.mp3'); // BLOCK PICKUP SOUND

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

          SizedBox(height: 20 * _scaleFactor),
          Text('💻 Code Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          // SOURCE AREA
          Wrap(
            spacing: 10 * _scaleFactor,
            runSpacing: 12 * _scaleFactor,
            alignment: WrapAlignment.center,
            children: allBlocks.map((block) {
              return isAnsweredCorrectly
                  ? puzzleBlock(block, Colors.grey)
                  : Draggable<String>(
                data: block,
                feedback: puzzleBlock(block, Colors.lightGreen),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: puzzleBlock(block, Colors.lightGreen),
                ),
                child: puzzleBlock(block, Colors.lightGreen),
                onDragStarted: () {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_pickup.mp3'); // BLOCK PICKUP SOUND

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

          SizedBox(height: 30 * _scaleFactor),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('compile.mp3'); // COMPILE SOUND
              checkAnswer();
            },
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Compile & Run", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * _scaleFactor,
                vertical: 16 * _scaleFactor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('button_click.mp3');
              resetGame();
            },
            child: Text("🔁 Retry", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget puzzleBlock(String text, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * _scaleFactor,
        vertical: 12 * _scaleFactor,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * _scaleFactor),
          bottomRight: Radius.circular(20 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black45, width: 1.5 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4 * _scaleFactor,
            offset: Offset(2 * _scaleFactor, 2 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 14 * _scaleFactor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}