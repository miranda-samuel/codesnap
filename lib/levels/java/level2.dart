import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import '../../services/music_service.dart';
import '../../services/daily_challenge_service.dart';

class JavaLevel2 extends StatefulWidget {
  const JavaLevel2({super.key});

  @override
  State<JavaLevel2> createState() => _JavaLevel2State();
}

class _JavaLevel2State extends State<JavaLevel2> {
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

  // NEW: Hint card system using UserPreferences
  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  @override
  void initState() {
    super.initState();
    resetBlocks();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
    _loadHintCards(); // Load hint cards for current user
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
      await Future.delayed(Duration(milliseconds: 500));
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

  // NEW: Load hint cards using UserPreferences
  Future<void> _loadHintCards() async {
    final user = await UserPreferences.getUser();
    if (user['id'] != null) {
      final hintCards = await DailyChallengeService.getUserHintCards(user['id']);
      setState(() {
        _availableHintCards = hintCards;
      });
    }
  }

  // NEW: Save hint cards using UserPreferences
  Future<void> _saveHintCards(int count) async {
    final user = await UserPreferences.getUser();
    if (user['id'] != null) {
      // We'll update the hint cards count in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userKey = 'hint_cards_${user['id']}';
      await prefs.setInt(userKey, count);

      setState(() {
        _availableHintCards = count;
      });
    }
  }

  // NEW: Use hint card - shows hint and auto-drags correct answer
  void _useHintCard() async {
    if (_availableHintCards > 0 && !_isUsingHint) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('hint_use.mp3');

      setState(() {
        _isUsingHint = true;
        _showHint = true;
        _currentHint = _getLevelHint();
        _availableHintCards--;
      });

      // Save the updated hint card count
      final user = await UserPreferences.getUser();
      if (user['id'] != null) {
        await DailyChallengeService.useHintCard(user['id']);
      }

      // Auto-drag the correct blocks after a short delay
      _autoDragCorrectBlocks();
    } else if (_availableHintCards <= 0) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hint cards available! Complete daily challenges to earn more.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // NEW: Auto-drag correct blocks to answer area
  void _autoDragCorrectBlocks() {
    // Correct blocks for Java: variable declaration and sum calculation
    List<String> correctBlocks = [
      'int x = 5;',
      'int y = 10;',
      'int sum = x + y;',
      'System.out.println(sum);'
    ];

    // Remove any existing correct blocks from dropped area first
    setState(() {
      droppedBlocks.clear();
    });

    // Add correct blocks one by one with delay
    int delay = 0;
    for (String block in correctBlocks) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() {
            if (!droppedBlocks.contains(block)) {
              droppedBlocks.add(block);
            }
            if (allBlocks.contains(block)) {
              allBlocks.remove(block);
            }
          });
        }
      });
      delay += 500; // 0.5 second delay between each block
    }

    // Hide hint after all blocks are placed
    Future.delayed(Duration(milliseconds: delay + 1000), () {
      if (mounted) {
        setState(() {
          _showHint = false;
          _isUsingHint = false;
        });
      }
    });
  }

  String _getLevelHint() {
    return "The correct code is:\nint x = 5;\nint y = 10;\nint sum = x + y;\nSystem.out.println(sum);\n\n💡 Hint: First declare variables x and y, then calculate their sum, and finally display the result!";
  }

  void _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      currentUser = user;
    });
    loadScoreFromDatabase();
    _loadHintCards(); // Load hint cards for this user
  }

  void resetBlocks() {
    // Correct blocks for Java: variable declaration and sum calculation
    List<String> correctBlocks = [
      'int x = 5;',
      'int y = 10;',
      'int sum = x + y;',
      'System.out.println(sum);'
    ];

    // Incorrect/distractor blocks
    List<String> incorrectBlocks = [
      'x = 5;',
      'y = 10;',
      'sum = x + y;',
      'cout << sum;',
      'printf(sum);',
      'print(sum);',
      'var x = 5;',
      'var y = 10;',
      'let sum = x + y;',
      'System.out.print(sum);',
      'console.log(sum);',
      'int z = 15;',
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
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = 120;
      droppedBlocks.clear();
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
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
          musicService.playSoundEffect('time_up.mp3');

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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty.mp3');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⏰ Time penalty! -1 point. Current score: $score")),
        );
      });
    });
  }

  void resetGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    setState(() {
      score = 3;
      remainingSeconds = 120;
      gameStarted = false;
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
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
        2, // Level 2
        score,
        score == 3, // Only completed if perfect score
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
      final response = await ApiService.getScores(currentUser!['id'], 'Java');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level2Data = scoresData['2']; // Level 2

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

  Future<void> refreshScore() async {
    if (currentUser?['id'] != null) {
      try {
        final response = await ApiService.getScores(currentUser!['id'], 'Java');
        if (response['success'] == true && response['scores'] != null) {
          final scoresData = response['scores'];
          final level2Data = scoresData['2'];

          setState(() {
            if (level2Data != null) {
              previousScore = level2Data['score'] ?? 0;
              level2Completed = level2Data['completed'] ?? false;
              hasPreviousScore = true;
              score = previousScore;
            } else {
              hasPreviousScore = false;
              previousScore = 0;
              level2Completed = false;
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
      'x = 5;',
      'y = 10;',
      'sum = x + y;',
      'cout << sum;',
      'printf(sum);',
      'print(sum);',
      'var x = 5;',
      'var y = 10;',
      'let sum = x + y;',
      'System.out.print(sum);',
      'console.log(sum);',
      'int z = 15;',
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      musicService.playSoundEffect('error.mp3');

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

        musicService.playSoundEffect('game_over.mp3');

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

    // Check for correct order: variable declarations first, then calculation, then output
    String answer = droppedBlocks.join('\n');
    String normalizedAnswer = answer
        .replaceAll('\n', '')
        .replaceAll(' ', '')
        .toLowerCase();

    // Expected: intx=5;inty=10;intsum=x+y;system.out.println(sum);
    String expected = 'intx=5;inty=10;intsum=x+y;system.out.println(sum);';

    if (normalizedAnswer == expected) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      // PLAY SUCCESS SOUND BASED ON SCORE
      if (score == 3) {
        musicService.playSoundEffect('perfect.mp3');
      } else {
        musicService.playSoundEffect('success.mp3');
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Excellent Java Programming!"),
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
                  "15",
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
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                if (score == 3) {
                  musicService.playSoundEffect('level_complete.mp3');
                  Navigator.pushReplacementNamed(context, '/java_level3');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: 'Java');
                }
              },
              child: Text(score == 3 ? "Next Level" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      musicService.playSoundEffect('wrong.mp3');

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

        musicService.playSoundEffect('game_over.mp3');

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

  // NEW: Hint Display Widget
  Widget _buildHintDisplay() {
    if (!_showHint) return SizedBox();

    return Positioned(
      top: 60 * _scaleFactor,
      left: 20 * _scaleFactor,
      right: 20 * _scaleFactor,
      child: Container(
        padding: EdgeInsets.all(16 * _scaleFactor),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.orangeAccent, width: 2 * _scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8 * _scaleFactor,
              offset: Offset(0, 4 * _scaleFactor),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.white, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  '💡 Hint Activated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * _scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              _currentHint,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * _scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Correct blocks are being placed automatically...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * _scaleFactor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMPROVED CODE PREVIEW WITH ORGANIZED LAYOUT
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
          // Code content
          Container(
            padding: EdgeInsets.all(12 * _scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers and code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Container(
                      width: 30 * _scaleFactor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildCodeLine(1),
                          _buildCodeLine(2),
                          _buildCodeLine(3),
                          _buildCodeLine(4),
                          _buildCodeLine(5),
                          _buildCodeLine(6),
                          _buildCodeLine(7),
                          _buildCodeLine(8),
                          _buildCodeLine(9),
                        ],
                      ),
                    ),
                    SizedBox(width: 16 * _scaleFactor),
                    // Actual code with syntax highlighting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSyntaxHighlightedLine('public class Main {', isKeyword: true),
                          _buildSyntaxHighlightedLine('    public static void main(String[] args) {', isKeyword: true),
                          _buildUserCodeLine(1, droppedBlocks.length > 0 ? droppedBlocks[0] : ''),
                          _buildUserCodeLine(2, droppedBlocks.length > 1 ? droppedBlocks[1] : ''),
                          _buildUserCodeLine(3, droppedBlocks.length > 2 ? droppedBlocks[2] : ''),
                          _buildUserCodeLine(4, droppedBlocks.length > 3 ? droppedBlocks[3] : ''),
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

  Widget _buildUserCodeLine(int lineNumber, String code) {
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

  Widget _buildCodeLine(int lineNumber) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.playBackgroundMusic();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recalculate scale factor when screen size changes
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
        title: Text("☕ Java - Level 2", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.red,
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
        child: Stack(
          children: [
            gameStarted ? buildGameUI() : buildStartScreen(),
            // ADD HINT BUTTON AND DISPLAY TO STACK
            if (gameStarted && !isAnsweredCorrectly) ...[
              _buildHintDisplay(),
              // ✅ HINT CARD BUTTON - BOTTOM RIGHT
              Positioned(
                bottom: 20 * _scaleFactor,
                right: 20 * _scaleFactor,
                child: GestureDetector(
                  onTap: _useHintCard,
                  child: Container(
                    padding: EdgeInsets.all(12 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: _availableHintCards > 0 ? Colors.orange : Colors.grey,
                      borderRadius: BorderRadius.circular(20 * _scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4 * _scaleFactor,
                          offset: Offset(0, 2 * _scaleFactor),
                        )
                      ],
                      border: Border.all(
                        color: _availableHintCards > 0 ? Colors.orangeAccent : Colors.grey,
                        width: 2 * _scaleFactor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 20 * _scaleFactor),
                        SizedBox(width: 6 * _scaleFactor),
                        Text(
                          '$_availableHintCards',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * _scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
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
              label: Text("Start", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            // Display available hint cards in start screen
            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Use hint cards during the game for help!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * _scaleFactor,
              ),
            ),

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
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      style: TextStyle(color: Colors.red, fontSize: 16 * _scaleFactor),
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
                color: Colors.red[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Level 2 Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.red[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Create a Java program that declares variables, calculates their sum, and displays the result",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.red[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🎁 Get a perfect score (3/3) to unlock Level 3!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
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
                ? 'Si Maria ay natututo ng variables at calculations sa Java! Kailangan niyang ideklara ang x at y, kalkulahin ang sum, at ipakita ang resulta. Tulungan mo siya!'
                : 'Maria is learning about variables and calculations in Java! She needs to declare x and y, calculate their sum, and display the result. Help her!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Arrange the 4 correct blocks to create the program',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // TARGET AREA - EXACTLY LIKE LEVEL 1
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 140 * _scaleFactor,
              maxHeight: 200 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.red, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<String>(
              onWillAccept: (data) {
                return !droppedBlocks.contains(data);
              },
              onAccept: (data) {
                if (!isAnsweredCorrectly) {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_drop.mp3');

                  setState(() {
                    droppedBlocks.add(data);
                    allBlocks.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 8 * _scaleFactor,
                    runSpacing: 8 * _scaleFactor,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: Material(
                          color: Colors.transparent,
                          child: puzzleBlock(block, Colors.orangeAccent),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.orangeAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.orangeAccent),
                        onDragStarted: () {
                          final musicService = Provider.of<MusicService>(context, listen: false);
                          musicService.playSoundEffect('block_pickup.mp3');

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
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 100 * _scaleFactor,
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
            ),
            child: Wrap(
              spacing: 8 * _scaleFactor,
              runSpacing: 10 * _scaleFactor,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: allBlocks.map((block) {
                return isAnsweredCorrectly
                    ? puzzleBlock(block, Colors.grey)
                    : Draggable<String>(
                  data: block,
                  feedback: Material(
                    color: Colors.transparent,
                    child: puzzleBlock(block, Colors.redAccent),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.redAccent),
                  ),
                  child: puzzleBlock(block, Colors.redAccent),
                  onDragStarted: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('block_pickup.mp3');

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
            onPressed: isAnsweredCorrectly ? null : () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('compile.mp3');
              checkAnswer();
            },
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Run", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
    // Calculate text width to adjust block size - SAME AS LEVEL 8
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 12 * _scaleFactor, // Using 12 instead of 14 for consistency
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final minWidth = 80 * _scaleFactor;  // Same as Level 8
    final maxWidth = 240 * _scaleFactor; // Same as Level 8

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      margin: EdgeInsets.symmetric(horizontal: 3 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scaleFactor,  // Same as Level 8
        vertical: 10 * _scaleFactor,    // Same as Level 8
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * _scaleFactor),
          bottomRight: Radius.circular(20 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black87, width: 2.0 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6 * _scaleFactor,
            offset: Offset(3 * _scaleFactor, 3 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 12 * _scaleFactor, // Changed from 14 to 12 to match Level 8
          color: Colors.black,
          shadows: [
            Shadow(
              offset: Offset(1 * _scaleFactor, 1 * _scaleFactor),
              blurRadius: 2 * _scaleFactor,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        softWrap: true, // Added for better text wrapping
      ),
    );
  }
}