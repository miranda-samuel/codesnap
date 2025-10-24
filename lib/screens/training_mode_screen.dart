import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/music_service.dart';
import '../../services/user_preferences.dart';
import '../../services/daily_challenge_service.dart';
import 'dart:math';

class TrainingModeScreen extends StatefulWidget {
  const TrainingModeScreen({super.key});

  @override
  State<TrainingModeScreen> createState() => _TrainingModeScreenState();
}

class _TrainingModeScreenState extends State<TrainingModeScreen> {
  // Training modes
  int _selectedTrainingMode = 0; // 0 = Main Game, 1 = Daily Challenge, 2 = Bonus Game
  List<String> trainingModes = ['Main Game Training', 'Daily Challenge Training', 'Bonus Game'];
  bool _showModeSelection = true; // Show mode selection at start

  // Main Game Training Variables
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isAnsweredCorrectly = false;
  int score = 3;
  int remainingSeconds = 180;
  Timer? countdownTimer;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  // Tutorial variables - SEPARATE FOR EACH MODE
  bool _showMainGameTutorial = true;
  bool _showDailyChallengeTutorial = true;
  bool _showBonusGameTutorial = true;
  int _currentTutorialStep = 0;
  bool _showBlockHint = false;

  // Daily Challenge Training Variables
  final List<Map<String, dynamic>> dailyChallenges = [
    {
      'id': '1',
      'question': 'Complete the function to return the sum of two numbers',
      'incompleteCode': 'def add_numbers(a, b):\n    ______\n    return result',
      'solution': 'def add_numbers(a, b):\n    result = a + b\n    return result',
      'requiredBlocks': ['result = a + b'],
      'optionalBlocks': ['print("Hello")', '# comment'],
      'language': 'Python',
      'difficulty': 'Easy',
    },
  ];

  TextEditingController _codeController = TextEditingController();
  bool _isCompleted = false;
  bool _showResult = false;
  int _remainingTime = 300;
  Timer? _timer;
  String _completionTime = '';
  DateTime? _startTime;
  List<String> _testResults = [];
  int _currentChallengeIndex = 0;
  int? _userId;
  bool _isLoading = false;

  // Falling blocks game variables
  List<FallingBlock> _fallingBlocks = [];
  Timer? _blockSpawnTimer;
  Timer? _fallingAnimationTimer;
  Random _random = Random();
  List<String> _collectedBlocks = [];
  Set<String> _requiredBlocks = {};
  Set<String> _optionalBlocks = {};

  // Bonus Game Variables
  String _selectedAnswer = '';
  bool _bonusGameStarted = false;
  bool _bonusIsTagalog = true;
  bool _bonusIsAnsweredCorrectly = false;
  int _bonusCurrentScore = 0;
  int _bonusQuestionsCorrect = 0;
  int _bonusRemainingSeconds = 10;
  Timer? _bonusCountdownTimer;
  int _bonusCurrentQuestionIndex = 0;

  // Questions for Bonus Game
  List<Map<String, dynamic>> _bonusQuestions = [
    {
      'question': 'What is used to output text in C++?',
      'tagalogQuestion': 'Ano ang ginagamit para mag-output ng text sa C++?',
      'correctAnswer': 'cout',
      'options': ['cin', 'cout', 'printf', 'print'],
      'points': 10,
      'explanation': 'cout is used for output in C++',
      'tagalogExplanation': 'Ang cout ang ginagamit para sa output sa C++'
    },
    {
      'question': 'Which keyword is used to create a class in C++?',
      'tagalogQuestion': 'Anong keyword ang ginagamit para gumawa ng class sa C++?',
      'correctAnswer': 'class',
      'options': ['class', 'struct', 'object', 'new'],
      'points': 10,
      'explanation': 'The "class" keyword is used to define a class in C++',
      'tagalogExplanation': 'Ang "class" na keyword ang ginagamit para mag-define ng class sa C++'
    },
    {
      'question': 'What is the correct way to create a variable in C++?',
      'tagalogQuestion': 'Ano ang tamang paraan para gumawa ng variable sa C++?',
      'correctAnswer': 'int x = 5;',
      'options': ['int x = 5;', 'variable x = 5', 'x = 5', 'let x = 5'],
      'points': 10,
      'explanation': 'In C++, you declare variables with their type first',
      'tagalogExplanation': 'Sa C++, idine-declare ang variables gamit ang type muna'
    },
  ];

  Map<String, dynamic> get _currentBonusQuestion => _bonusQuestions[_bonusCurrentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _calculateScaleFactor();
    _startGameMusic();
    _loadUserData();
    resetBlocks(); // Initialize main game blocks
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
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

  Future<void> _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      _userId = user['id'];
    });
  }

  // === TUTORIAL METHODS FOR ALL MODES ===
  void _showWelcomeDialog(int mode) {
    String title = "";
    String description = "";
    String goal = "";
    IconData icon = Icons.school;

    switch (mode) {
      case 0: // Main Game
        title = "🎮 Welcome to Main Game Training!";
        description = "This tutorial will teach you how to play the main game!";
        goal = 'Create: print("Hello World")';
        icon = Icons.gamepad;
        break;
      case 1: // Daily Challenge
        title = "🏆 Welcome to Daily Challenge Training!";
        description = "This tutorial will teach you how to complete coding challenges!";
        goal = 'Complete the function by collecting falling code blocks';
        icon = Icons.celebration;
        break;
      case 2: // Bonus Game
        title = "🎯 Welcome to Bonus Game!";
        description = "This tutorial will teach you how to play the quiz game!";
        goal = 'Answer C++ questions correctly before time runs out';
        icon = Icons.quiz;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 48),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(description,
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.tealAccent),
              ),
              child: Column(
                children: [
                  Text("🎯 Your Goal:",
                      style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(goal,
                      style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('click.mp3');
              Navigator.pop(context);
              _showTutorialStep1(mode);
            },
            child: Text("START TUTORIAL", style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  void _showTutorialStep1(int mode) {
    setState(() {
      _currentTutorialStep = 1;
    });

    String title = "";
    String message = "";
    IconData icon = Icons.touch_app;

    switch (mode) {
      case 0: // Main Game
        title = "Step 1: Drag Blocks";
        message = "Tap and drag the blue code blocks to the drop area below.\n\nTry dragging the 'print' block first!";
        icon = Icons.touch_app;
        break;
      case 1: // Daily Challenge
        title = "Step 1: Collect Blocks";
        message = "Tap on the falling code blocks to collect them.\n\nThe blocks will automatically fill in the code!";
        icon = Icons.touch_app;
        break;
      case 2: // Bonus Game
        title = "Step 1: Read the Question";
        message = "Read the question carefully. You can switch between English and Tagalog using the translate button.";
        icon = Icons.quiz;
        break;
    }

    Future.delayed(Duration(milliseconds: 300), () {
      _showTutorialDialog(title, message, icon, mode);
    });
  }

  void _showTutorialStep2(int mode) {
    setState(() {
      _currentTutorialStep = 2;
      if (mode == 0) _showBlockHint = true;
    });

    String title = "";
    String message = "";
    IconData icon = Icons.code;

    switch (mode) {
      case 0: // Main Game
        title = "Step 2: Build the Code";
        message = "Now drag the other correct blocks:\n( ) and \"Hello World\"\n\nArrange them to form: print(\"Hello World\")";
        icon = Icons.code;
        break;
      case 1: // Daily Challenge
        title = "Step 2: Complete the Code";
        message = "Collect all required blocks to complete the code.\n\nRequired blocks are green, optional ones are blue.";
        icon = Icons.code;
        break;
      case 2: // Bonus Game
        title = "Step 2: Select Answer";
        message = "Tap on your chosen answer. You have 10 seconds to answer each question!";
        icon = Icons.help_outline;
        break;
    }

    Future.delayed(Duration(milliseconds: 300), () {
      _showTutorialDialog(title, message, icon, mode);
    });
  }

  void _showTutorialStep3(int mode) {
    setState(() {
      _currentTutorialStep = 3;
    });

    String title = "";
    String message = "";
    IconData icon = Icons.play_arrow;

    switch (mode) {
      case 0: // Main Game
        title = "Step 3: Run Your Code";
        message = "Once you have all the correct blocks, press the 'Run Code' button to check your solution!";
        icon = Icons.play_arrow;
        break;
      case 1: // Daily Challenge
        title = "Step 3: Submit Solution";
        message = "Press the 'SUBMIT CODE' button when you're done. Complete before time runs out!";
        icon = Icons.play_arrow;
        break;
      case 2: // Bonus Game
        title = "Step 3: Submit Answer";
        message = "Press the 'Submit Answer' button to check your answer. Score points for correct answers!";
        icon = Icons.check;
        break;
    }

    Future.delayed(Duration(milliseconds: 300), () {
      _showTutorialDialog(title, message, icon, mode);
    });
  }

  void _showTutorialDialog(String title, String message, IconData icon, int mode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: Colors.tealAccent),
            SizedBox(width: 10),
            Text(title, style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message,
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center),
        actions: [
          if (_currentTutorialStep < 3)
            TextButton(
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                if (_currentTutorialStep == 1) {
                  _showTutorialStep2(mode);
                } else if (_currentTutorialStep == 2) {
                  _showTutorialStep3(mode);
                }
              },
              child: Text("NEXT", style: TextStyle(color: Colors.tealAccent)),
            )
          else
            TextButton(
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                // Set tutorial to false only for the current mode
                _setTutorialCompleted(mode);
                _showReadyDialog(mode);
              },
              child: Text("GOT IT!", style: TextStyle(color: Colors.tealAccent)),
            ),
        ],
      ),
    );
  }

  void _setTutorialCompleted(int mode) {
    setState(() {
      switch (mode) {
        case 0:
          _showMainGameTutorial = false;
          break;
        case 1:
          _showDailyChallengeTutorial = false;
          break;
        case 2:
          _showBonusGameTutorial = false;
          break;
      }
      _currentTutorialStep = 0;
      _showBlockHint = false;
    });
  }

  bool _shouldShowTutorial(int mode) {
    switch (mode) {
      case 0:
        return _showMainGameTutorial;
      case 1:
        return _showDailyChallengeTutorial;
      case 2:
        return _showBonusGameTutorial;
      default:
        return true;
    }
  }

  void _showReadyDialog(int mode) {
    String title = "";
    String tips = "";
    IconData icon = Icons.emoji_events;

    switch (mode) {
      case 0: // Main Game
        title = "Ready to Play Main Game!";
        tips = "Remember:\n• Drag correct blocks\n• Avoid wrong ones\n• Complete before time runs out";
        icon = Icons.gamepad;
        break;
      case 1: // Daily Challenge
        title = "Ready for Daily Challenge!";
        tips = "Remember:\n• Tap falling blocks\n• Complete the code\n• Submit before time ends";
        icon = Icons.celebration;
        break;
      case 2: // Bonus Game
        title = "Ready for Bonus Game!";
        tips = "Remember:\n• Read questions carefully\n• Answer quickly\n• Score points for correct answers";
        icon = Icons.quiz;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: Colors.amber),
            SizedBox(width: 10),
            Text(title, style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tips,
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: mode == 0
                  ? Text('Correct: print ( "Hello World" )',
                  style: TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 12))
                  : mode == 1
                  ? Text('Goal: Complete the code',
                  style: TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 12))
                  : Text('Goal: Answer all questions',
                  style: TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('click.mp3');
              Navigator.pop(context);
            },
            child: Text("LET'S GO!", style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  // === MAIN GAME TRAINING METHODS ===
  void resetBlocks() {
    // Simple blocks for displaying "Hello World"
    List<String> correctBlocks = [
      'print',
      '(',
      '"Hello World"',
      ')'
    ];

    // Incorrect/distractor blocks
    List<String> incorrectBlocks = [
      'cout',
      'printf',
      'System.out.print',
      'echo',
    ];

    // Combine correct and incorrect blocks, then shuffle
    allBlocks = [
      ...correctBlocks,
      ...incorrectBlocks,
    ]..shuffle();
  }

  void startMainGameTraining() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    setState(() {
      _selectedTrainingMode = 0;
      _showModeSelection = false;
      gameStarted = true;
      score = 3;
      remainingSeconds = 180;
      droppedBlocks.clear();
      isAnsweredCorrectly = false;
      resetBlocks();
    });

    // Auto-show tutorial for main game if not completed yet
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && _shouldShowTutorial(0)) {
        _showWelcomeDialog(0);
      }
    });

    startTimer();
  }

  void startTimer() {
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
          showTimeUpDialog();
        }
      });
    });
  }

  void showTimeUpDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('time_up.mp3');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.timer, color: Colors.orange),
            SizedBox(width: 10),
            Text("⏰ Time's Up!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Score: $score", style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 10),
            Text("Don't worry! Try again.", style: TextStyle(color: Colors.white70)),
            if (score == 0)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text("💡 Tip: Look for 'print', '(', '\"Hello World\"', and ')'",
                    style: TextStyle(color: Colors.orange, fontSize: 12)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              musicService.playSoundEffect('click.mp3');
              resetMainGame();
              Navigator.pop(context);
            },
            child: Text("Try Again", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
  }

  void resetMainGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    setState(() {
      score = 3;
      remainingSeconds = 180;
      gameStarted = false;
      isAnsweredCorrectly = false;
      droppedBlocks.clear();
      countdownTimer?.cancel();
      resetBlocks();
      // Don't reset tutorial here - only reset when going back to mode selection
    });
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'cout',
      'printf',
      'System.out.print',
      'echo',
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("❌ You used incorrect code! -1 point"),
                SizedBox(height: 4),
                Text("Use only: print, (, \"Hello World\", )",
                    style: TextStyle(fontSize: 12, color: Colors.yellow)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        showGameOverDialog();
      }
      return;
    }

    // Check for correct answer: print("Hello World")
    String answer = droppedBlocks.join('');
    String normalizedAnswer = answer.replaceAll(' ', '').toLowerCase();
    String expected = 'print("helloworld")';

    if (normalizedAnswer == expected) {
      countdownTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      if (score == 3) {
        musicService.playSoundEffect('perfect.mp3');
      } else {
        musicService.playSoundEffect('success.mp3');
      }

      showSuccessDialog();
    } else {
      musicService.playSoundEffect('wrong.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("❌ Incorrect arrangement. -1 point"),
                SizedBox(height: 4),
                Text("Try: print ( \"Hello World\" )",
                    style: TextStyle(fontSize: 12, color: Colors.yellow)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        showGameOverDialog();
      }
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 10),
            Text("🎉 Congratulations!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Well done! You completed the training!",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text("Your Score: $score/3",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Code Output:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  Text("Hello World", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (score == 3)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text("⭐ Perfect Score! You're ready for the main game!",
                    style: TextStyle(color: Colors.amber, fontSize: 12)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('click.mp3');
              Navigator.pop(context);
              resetMainGame();
            },
            child: Text("Play Again", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
  }

  void showGameOverDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('game_over.mp3');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text("💀 Game Over", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Don't worry! Practice makes perfect.", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Text("💡 Remember:", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('Use: print ( "Hello World" )',
                      style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12)),
                  SizedBox(height: 5),
                  Text("Avoid: cout, printf, etc.",
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              musicService.playSoundEffect('click.mp3');
              Navigator.pop(context);
              resetMainGame();
            },
            child: Text("Try Again", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
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
                  'training.py',
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
                _buildUserCodeLine(getPreviewCode()),
                SizedBox(height: 8 * _scaleFactor),
                if (droppedBlocks.isEmpty)
                  Text(
                    "# Drag blocks from below to build your code...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10 * _scaleFactor,
                      fontFamily: 'monospace',
                      fontStyle: FontStyle.italic,
                    ),
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
          '',
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
                fontSize: 14 * _scaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getPreviewCode() {
    return droppedBlocks.join(' ');
  }

  // === DAILY CHALLENGE TRAINING METHODS ===
  void startDailyChallengeTraining() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    setState(() {
      _selectedTrainingMode = 1;
      _showModeSelection = false;
    });

    // Auto-show tutorial for daily challenge if not completed yet
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && _shouldShowTutorial(1)) {
        _showWelcomeDialog(1);
      }
    });

    _initializeDailyChallengeTraining();
  }

  void _initializeDailyChallengeTraining() {
    setState(() {
      _currentChallengeIndex = 0;
      _isCompleted = false;
      _showResult = false;
      _remainingTime = 300;
      _completionTime = '';
      _testResults = [];
      _collectedBlocks.clear();
      _fallingBlocks.clear();
      _codeController.text = dailyChallenges[_currentChallengeIndex]['incompleteCode'];
      _startTime = DateTime.now();

      final currentChallenge = dailyChallenges[_currentChallengeIndex];
      _requiredBlocks = Set.from(currentChallenge['requiredBlocks'] ?? []);
      _optionalBlocks = Set.from(currentChallenge['optionalBlocks'] ?? []);
    });

    _startDailyChallengeTimer();
    _initializeFallingBlocksGame();
  }

  void _startDailyChallengeTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        if (!_isCompleted) {
          _submitDailyChallenge();
        }
      }
    });
  }

  void _initializeFallingBlocksGame() {
    _blockSpawnTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (!_isCompleted && _remainingTime > 0) {
        _spawnFallingBlock();
      } else {
        timer.cancel();
      }
    });

    _startFallingAnimation();
  }

  void _startFallingAnimation() {
    _fallingAnimationTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_isCompleted || _remainingTime <= 0) {
        timer.cancel();
        return;
      }

      setState(() {
        for (var block in _fallingBlocks) {
          block.top += 3;
        }
        _fallingBlocks.removeWhere((block) => block.top > 180);
      });
    });
  }

  void _spawnFallingBlock() {
    final allBlocks = [..._requiredBlocks, ..._optionalBlocks];
    if (allBlocks.isEmpty) return;

    final randomIndex = _random.nextInt(allBlocks.length);
    final randomBlock = allBlocks[randomIndex];

    if (_fallingBlocks.length < 5) {
      setState(() {
        _fallingBlocks.add(FallingBlock(
          id: DateTime.now().millisecondsSinceEpoch,
          text: randomBlock,
          left: _random.nextDouble() * 250,
          top: 0,
          color: _getBlockColor(randomBlock),
        ));
      });
    }
  }

  Color _getBlockColor(String blockText) {
    if (_requiredBlocks.contains(blockText)) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  void _onBlockTap(FallingBlock block) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('block_collect.mp3');

    setState(() {
      _fallingBlocks.remove(block);
      _collectedBlocks.add(block.text);
      _updateCodeWithBlocks();
    });
  }

  void _updateCodeWithBlocks() {
    final currentChallenge = dailyChallenges[_currentChallengeIndex];
    String baseCode = currentChallenge['incompleteCode'];

    if (_collectedBlocks.isNotEmpty) {
      String newCode = baseCode.replaceFirst('______', _collectedBlocks.join('\n    '));
      _codeController.text = newCode;
    }
  }

  void _resetCollectedBlocks() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    setState(() {
      _collectedBlocks.clear();
      _codeController.text = dailyChallenges[_currentChallengeIndex]['incompleteCode'];
    });
  }

  void _submitDailyChallenge() {
    if (_isCompleted) return;

    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('compile.mp3');

    setState(() {
      _showResult = true;
      _isLoading = true;
    });

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    _completionTime = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    _runTestCases();

    final passedTests = _testResults.where((result) => result == 'PASSED').length;
    final totalTests = 1; // Simplified for training

    bool allTestsPassed = passedTests == totalTests;

    if (allTestsPassed) {
      _showDailyChallengeSuccessDialog();
    } else {
      _showDailyChallengeFailureDialog();
    }

    setState(() {
      _isCompleted = true;
      _isLoading = false;
    });

    _blockSpawnTimer?.cancel();
    _fallingAnimationTimer?.cancel();
  }

  void _runTestCases() {
    final currentChallenge = dailyChallenges[_currentChallengeIndex];
    final userCode = _codeController.text;
    final solution = currentChallenge['solution'];

    _testResults.clear();

    // Simplified validation for training
    bool passed = _validateCodeForTraining(userCode, solution);
    _testResults.add(passed ? 'PASSED' : 'FAILED');
  }

  bool _validateCodeForTraining(String userCode, String solution) {
    if (userCode.contains('______') ||
        userCode.trim() == dailyChallenges[_currentChallengeIndex]['incompleteCode'].trim()) {
      return false;
    }

    String cleanUserCode = userCode.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
    String cleanSolution = solution.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    return cleanUserCode.contains(cleanSolution) || _checkCodeLogic(userCode, solution);
  }

  bool _checkCodeLogic(String userCode, String solution) {
    String userLogic = _extractCoreLogic(userCode);
    String solutionLogic = _extractCoreLogic(solution);
    return userLogic.contains(solutionLogic) || solutionLogic.contains(userLogic);
  }

  String _extractCoreLogic(String code) {
    return code
        .replaceAll(RegExp(r'#.*?\n'), '')
        .replaceAll(RegExp(r'//.*?\n'), '')
        .replaceAll(RegExp(r'/\*.*?\*/'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  void _showDailyChallengeSuccessDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('perfect.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(Icons.celebration, color: Colors.green, size: 48),
              SizedBox(height: 10),
              Text('Challenge Completed! 🎉',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Great Job!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You completed the daily challenge training!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Time: $_completionTime',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('click.mp3');
                Navigator.of(context).pop();
                _retryDailyChallenge();
              },
              child: Text('PLAY AGAIN', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showDailyChallengeFailureDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('error.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 48),
              SizedBox(height: 10),
              Text('Challenge Failed',
                  style: TextStyle(color: Colors.orange, fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Try again! Practice makes perfect.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    Text('💡 Hint:', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(
                      'Collect the correct falling blocks to complete the code',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('click.mp3');
                Navigator.of(context).pop();
                _retryDailyChallenge();
              },
              child: Text('TRY AGAIN', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  void _retryDailyChallenge() {
    setState(() {
      _isCompleted = false;
      _showResult = false;
      _remainingTime = 300;
      _collectedBlocks.clear();
      _fallingBlocks.clear();
      _codeController.text = dailyChallenges[_currentChallengeIndex]['incompleteCode'];
      _startTime = DateTime.now();
    });

    _startDailyChallengeTimer();
    _initializeFallingBlocksGame();
  }

  Widget _buildFallingBlocksArea() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: _fallingBlocks.map<Widget>((block) {
          return Positioned(
            top: block.top,
            left: block.left,
            child: GestureDetector(
              onTap: () => _onBlockTap(block),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: block.color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Text(
                  block.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDailyChallengeCodeEditor() {
    final currentChallenge = dailyChallenges[_currentChallengeIndex];
    final language = currentChallenge['language'] ?? 'Python';
    final fileName = _getFileName(language);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.tealAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  fileName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Spacer(),
                if (!_isCompleted && _collectedBlocks.isNotEmpty)
                  InkWell(
                    onTap: _resetCollectedBlocks,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.red, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Reset Blocks',
                            style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    language.toUpperCase(),
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFF1E1E1E),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      border: Border(right: BorderSide(color: Colors.grey[800]!)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(8, (index) =>
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        child: _buildCodeWithSyntaxHighlighting(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeWithSyntaxHighlighting() {
    final currentChallenge = dailyChallenges[_currentChallengeIndex];
    final language = currentChallenge['language'];
    final code = _codeController.text;

    List<String> lines = code.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.asMap().entries.map((entry) {
        int lineNumber = entry.key;
        String line = entry.value;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: _buildSyntaxHighlightedLine(line, language),
        );
      }).toList(),
    );
  }

  Widget _buildSyntaxHighlightedLine(String line, String language) {
    List<TextSpan> spans = [];
    List<String> words = line.split(' ');

    for (String word in words) {
      Color color = Colors.white;

      if (_isKeyword(word, language)) {
        color = Color(0xFF569CD6);
      } else if (_isString(word)) {
        color = Color(0xFFCE9178);
      } else if (_isNumber(word)) {
        color = Color(0xFFB5CEA8);
      } else if (_isComment(word)) {
        color = Color(0xFF6A9955);
      } else if (_isFunction(word)) {
        color = Color(0xFFDCDCAA);
      }

      spans.add(TextSpan(
        text: '$word ',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  bool _isKeyword(String word, String language) {
    List<String> commonKeywords = ['def', 'function', 'public', 'class', 'return', 'if', 'else', 'for', 'while'];
    List<String> pythonKeywords = ['def', 'return', 'if', 'else', 'for', 'while', 'in', 'import'];
    List<String> jsKeywords = ['function', 'return', 'if', 'else', 'for', 'while', 'const', 'let', 'var'];
    List<String> javaKeywords = ['public', 'class', 'return', 'if', 'else', 'for', 'while', 'int', 'void'];

    switch (language) {
      case 'Python': return pythonKeywords.contains(word);
      case 'JavaScript': return jsKeywords.contains(word);
      case 'Java': return javaKeywords.contains(word);
      default: return commonKeywords.contains(word);
    }
  }

  bool _isString(String word) {
    return word.contains('"') || word.contains("'");
  }

  bool _isNumber(String word) {
    return double.tryParse(word) != null;
  }

  bool _isComment(String word) {
    return word.startsWith('#') || word.startsWith('//');
  }

  bool _isFunction(String word) {
    return word.contains('(') && word.contains(')');
  }

  String _getFileName(String language) {
    switch (language) {
      case 'Python': return 'challenge.py';
      case 'JavaScript': return 'challenge.js';
      case 'Java': return 'Challenge.java';
      default: return 'challenge.txt';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy': return Colors.green;
      case 'Medium': return Colors.orange;
      case 'Hard': return Colors.red;
      default: return Colors.tealAccent;
    }
  }

  // === BONUS GAME METHODS ===
  void startBonusGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    setState(() {
      _selectedTrainingMode = 2;
      _showModeSelection = false;
      _bonusGameStarted = true;
      _bonusCurrentScore = 0;
      _bonusQuestionsCorrect = 0;
      _bonusRemainingSeconds = 10;
      _bonusIsAnsweredCorrectly = false;
      _selectedAnswer = '';
      _bonusCurrentQuestionIndex = 0;
    });

    // Auto-show tutorial for bonus game if not completed yet
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && _shouldShowTutorial(2)) {
        _showWelcomeDialog(2);
      }
    });

    _startBonusTimer();
  }

  void _startBonusTimer() {
    _bonusCountdownTimer?.cancel();
    _bonusCountdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_bonusIsAnsweredCorrectly) {
        timer.cancel();
        return;
      }

      setState(() {
        _bonusRemainingSeconds--;
        if (_bonusRemainingSeconds <= 0) {
          timer.cancel();
          _handleBonusTimeUp();
        }
      });
    });
  }

  void _handleBonusTimeUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("⏰ Time's up!"),
        backgroundColor: Colors.orange[700],
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        _showBonusResultDialog(false);
      }
    });
  }

  void _selectBonusAnswer(String answer) {
    if (!_bonusIsAnsweredCorrectly) {
      setState(() {
        _selectedAnswer = answer;
      });
    }
  }

  void _checkBonusAnswer() {
    if (_bonusIsAnsweredCorrectly || _selectedAnswer.isEmpty) return;

    String correctAnswer = _currentBonusQuestion['correctAnswer'];
    _bonusCountdownTimer?.cancel();

    if (_selectedAnswer == correctAnswer) {
      setState(() {
        _bonusIsAnsweredCorrectly = true;
        _bonusQuestionsCorrect++;
        _bonusCurrentScore += (_currentBonusQuestion['points'] as int);
      });

      _showBonusResultDialog(true);
    } else {
      _showBonusResultDialog(false);
    }
  }

  void _showBonusResultDialog(bool isCorrect) {
    final musicService = Provider.of<MusicService>(context, listen: false);

    if (isCorrect) {
      musicService.playSoundEffect('success.mp3');
    } else {
      musicService.playSoundEffect('error.mp3');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red, size: 32),
            SizedBox(width: 10),
            Text(isCorrect ? "✅ Correct!" : "❌ Incorrect",
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCorrect ? "Great job! Your answer is correct!" : "Wrong answer!",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isCorrect ? Colors.green : Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💡 Explanation:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  Text(
                    _bonusIsTagalog ?
                    _currentBonusQuestion['tagalogExplanation'] :
                    _currentBonusQuestion['explanation'],
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Score: $_bonusCurrentScore/30",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              musicService.playSoundEffect('click.mp3');
              Navigator.of(context).pop();
              _nextBonusQuestion();
            },
            child: Text("NEXT QUESTION", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
  }

  void _nextBonusQuestion() {
    if (_bonusCurrentQuestionIndex < _bonusQuestions.length - 1) {
      setState(() {
        _bonusCurrentQuestionIndex++;
        _bonusIsAnsweredCorrectly = false;
        _selectedAnswer = '';
        _bonusRemainingSeconds = 10;
      });
      _startBonusTimer();
    } else {
      _showBonusGameCompleteDialog();
    }
  }

  void _showBonusGameCompleteDialog() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('perfect.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 48),
            SizedBox(height: 10),
            Text("🎉 Bonus Game Complete!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Congratulations! You completed all questions!",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  Text("Final Score", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 5),
                  Text("$_bonusCurrentScore/${_bonusQuestions.length * 10}",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  Text("Questions Correct: $_bonusQuestionsCorrect/${_bonusQuestions.length}",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              musicService.playSoundEffect('click.mp3');
              Navigator.of(context).pop();
              _resetBonusGame();
            },
            child: Text("PLAY AGAIN", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
  }

  void _resetBonusGame() {
    setState(() {
      _bonusGameStarted = false;
      _bonusIsAnsweredCorrectly = false;
      _selectedAnswer = '';
      _bonusCurrentScore = 0;
      _bonusQuestionsCorrect = 0;
      _bonusRemainingSeconds = 10;
      _bonusCurrentQuestionIndex = 0;
      _bonusCountdownTimer?.cancel();
    });
  }

  Widget puzzleBlock(String text, Color color) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 80 * _scaleFactor,
        maxWidth: 240 * _scaleFactor,
      ),
      margin: EdgeInsets.symmetric(horizontal: 3 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scaleFactor,
        vertical: 10 * _scaleFactor,
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
          fontSize: 12 * _scaleFactor,
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
        softWrap: true,
      ),
    );
  }

  void _backToModeSelection() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('click.mp3');

    // Cancel all timers
    countdownTimer?.cancel();
    _timer?.cancel();
    _blockSpawnTimer?.cancel();
    _fallingAnimationTimer?.cancel();
    _bonusCountdownTimer?.cancel();

    setState(() {
      _showModeSelection = true;
      gameStarted = false;
      _isCompleted = false;
      _bonusGameStarted = false;
      // Reset tutorial state when going back to mode selection
      _showMainGameTutorial = true;
      _showDailyChallengeTutorial = true;
      _showBonusGameTutorial = true;
      _currentTutorialStep = 0;
      _showBlockHint = false;
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _timer?.cancel();
    _blockSpawnTimer?.cancel();
    _fallingAnimationTimer?.cancel();
    _bonusCountdownTimer?.cancel();
    _codeController.dispose();

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
        title: Text("🎮 Training Mode", style: TextStyle(fontSize: 18 * _scaleFactor, color: Colors.white)),
        backgroundColor: Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: _showModeSelection ? null : IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _backToModeSelection,
        ),
        actions: _selectedTrainingMode == 0 && gameStarted ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18 * _scaleFactor, color: Colors.white),
                SizedBox(width: 4 * _scaleFactor),
                Text(formatTime(remainingSeconds), style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
                SizedBox(width: 16 * _scaleFactor),
                Icon(Icons.star, color: Colors.yellowAccent, size: 18 * _scaleFactor),
                Text(" $score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor, color: Colors.white)),
              ],
            ),
          ),
        ] : _selectedTrainingMode == 1 && !_showModeSelection ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18 * _scaleFactor, color: Colors.white),
                SizedBox(width: 4 * _scaleFactor),
                Text('${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
              ],
            ),
          ),
        ] : _selectedTrainingMode == 2 && _bonusGameStarted ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18 * _scaleFactor,
                    color: _bonusRemainingSeconds <= 3 ? Colors.red : Colors.white),
                SizedBox(width: 4 * _scaleFactor),
                Text('${_bonusRemainingSeconds}s',
                    style: TextStyle(fontSize: 14 * _scaleFactor,
                        color: _bonusRemainingSeconds <= 3 ? Colors.red : Colors.white)),
                SizedBox(width: 16 * _scaleFactor),
                Icon(Icons.star, color: Colors.yellowAccent, size: 18 * _scaleFactor),
                Text(" $_bonusCurrentScore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor, color: Colors.white)),
              ],
            ),
          ),
        ] : [],
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
        child: _showModeSelection
            ? _buildModeSelectionScreen()
            : (_selectedTrainingMode == 0
            ? (gameStarted ? buildGameUI() : buildMainGameStartScreen())
            : _selectedTrainingMode == 1
            ? buildDailyChallengeUI()
            : (_bonusGameStarted ? buildBonusGameUI() : buildBonusStartScreen())),
      ),
    );
  }

  Widget _buildModeSelectionScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20 * _scaleFactor),
              margin: EdgeInsets.only(bottom: 30 * _scaleFactor),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20 * _scaleFactor),
                border: Border.all(color: Colors.tealAccent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10 * _scaleFactor,
                    offset: Offset(0, 5 * _scaleFactor),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.school, size: 50 * _scaleFactor, color: Colors.tealAccent),
                  SizedBox(height: 16 * _scaleFactor),
                  Text(
                    "Training Mode",
                    style: TextStyle(
                      fontSize: 24 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Choose your training type to practice different coding skills",
                    style: TextStyle(
                      fontSize: 16 * _scaleFactor,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main Game Training Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16 * _scaleFactor),
              child: ElevatedButton(
                onPressed: startMainGameTraining,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 20 * _scaleFactor),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * _scaleFactor),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.gamepad, size: 40 * _scaleFactor),
                    SizedBox(height: 12 * _scaleFactor),
                    Text(
                      "Main Game Training",
                      style: TextStyle(
                        fontSize: 18 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8 * _scaleFactor),
                    Text(
                      "Learn basic block dragging and code building",
                      style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4 * _scaleFactor),
                    Container(
                      padding: EdgeInsets.all(8 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      ),
                      child: Text(
                        'Goal: print("Hello World")',
                        style: TextStyle(
                          fontSize: 10 * _scaleFactor,
                          color: Colors.green,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daily Challenge Training Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16 * _scaleFactor),
              child: ElevatedButton(
                onPressed: startDailyChallengeTraining,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 20 * _scaleFactor),
                  backgroundColor: Colors.purple[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * _scaleFactor),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.celebration, size: 40 * _scaleFactor),
                    SizedBox(height: 12 * _scaleFactor),
                    Text(
                      "Daily Challenge Training",
                      style: TextStyle(
                        fontSize: 18 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8 * _scaleFactor),
                    Text(
                      "Practice with falling code blocks and multiple languages",
                      style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4 * _scaleFactor),
                    Container(
                      padding: EdgeInsets.all(8 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      ),
                      child: Text(
                        'Multiple Challenges Available',
                        style: TextStyle(
                          fontSize: 10 * _scaleFactor,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bonus Game Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: startBonusGame,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 20 * _scaleFactor),
                  backgroundColor: Colors.amber[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * _scaleFactor),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.quiz, size: 40 * _scaleFactor),
                    SizedBox(height: 12 * _scaleFactor),
                    Text(
                      "Bonus Game",
                      style: TextStyle(
                        fontSize: 18 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8 * _scaleFactor),
                    Text(
                      "Test your knowledge with multiple choice questions",
                      style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4 * _scaleFactor),
                    Container(
                      padding: EdgeInsets.all(8 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      ),
                      child: Text(
                        '3 Questions - 10 Seconds Each',
                        style: TextStyle(
                          fontSize: 10 * _scaleFactor,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainGameStartScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20 * _scaleFactor),
              margin: EdgeInsets.only(bottom: 30 * _scaleFactor),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20 * _scaleFactor),
                border: Border.all(color: Colors.blue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10 * _scaleFactor,
                    offset: Offset(0, 5 * _scaleFactor),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.gamepad, size: 50 * _scaleFactor, color: Colors.blue),
                  SizedBox(height: 16 * _scaleFactor),
                  Text(
                    "Main Game Training",
                    style: TextStyle(
                      fontSize: 24 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Learn how to play the main game step by step",
                    style: TextStyle(
                      fontSize: 16 * _scaleFactor,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(12 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12 * _scaleFactor),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      '🎯 Goal: Create print("Hello World")',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14 * _scaleFactor,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('button_click.mp3');
                  startMainGameTraining();
                },
                icon: Icon(Icons.play_arrow, size: 24 * _scaleFactor),
                label: Text("Start Training", style: TextStyle(fontSize: 18 * _scaleFactor)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32 * _scaleFactor, vertical: 16 * _scaleFactor),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * _scaleFactor)),
                ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create: print("Hello World")',
                        style: TextStyle(fontSize: 14 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (_showBlockHint)
                        Padding(
                          padding: EdgeInsets.only(top: 4 * _scaleFactor),
                          child: Text(
                            '💡 Use: print, (, "Hello World", )',
                            style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🎯 Drop Blocks Here:',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 10 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 140 * _scaleFactor),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.blue, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<String>(
              onWillAccept: (data) => !droppedBlocks.contains(data),
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
                    children: droppedBlocks.isEmpty
                        ? [
                      Text(
                        'Drag blocks here to build your code...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14 * _scaleFactor,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    ]
                        : droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: Material(
                          color: Colors.transparent,
                          child: puzzleBlock(block, Colors.greenAccent),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.greenAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.greenAccent),
                        onDragStarted: () {
                          final musicService = Provider.of<MusicService>(context, listen: false);
                          musicService.playSoundEffect('block_pickup.mp3');
                        },
                        onDragEnd: (details) {
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

          Text('🧩 Available Blocks:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),

          Container(
            width: double.infinity,
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
                    child: puzzleBlock(block, Colors.blueAccent),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.blueAccent),
                  ),
                  child: puzzleBlock(block, Colors.blueAccent),
                  onDragStarted: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('block_pickup.mp3');
                  },
                  onDragEnd: (details) {
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

          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAnsweredCorrectly ? null : checkAnswer,
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Run Code", style: TextStyle(fontSize: 18 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32 * _scaleFactor, vertical: 16 * _scaleFactor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * _scaleFactor)),
              ),
            ),
          ),

          SizedBox(height: 10 * _scaleFactor),
          Center(
            child: TextButton.icon(
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                resetMainGame();
              },
              icon: Icon(Icons.refresh, size: 18 * _scaleFactor),
              label: Text("Restart Training", style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDailyChallengeUI() {
    final currentChallenge = dailyChallenges[_currentChallengeIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * _scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 6 * _scaleFactor),
                decoration: BoxDecoration(
                  color: _remainingTime <= 60 ? Colors.red.withOpacity(0.3) : Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20 * _scaleFactor),
                  border: Border.all(color: _remainingTime <= 60 ? Colors.red : Colors.purple),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white, size: 14 * _scaleFactor),
                    SizedBox(width: 6 * _scaleFactor),
                    Text(
                      '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 6 * _scaleFactor),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20 * _scaleFactor),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: Text(
                  'Training Mode',
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 12 * _scaleFactor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          SizedBox(height: 16 * _scaleFactor),

          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * _scaleFactor, vertical: 4 * _scaleFactor),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12 * _scaleFactor),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: Text(
                  currentChallenge['language'],
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 10 * _scaleFactor, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8 * _scaleFactor),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * _scaleFactor, vertical: 4 * _scaleFactor),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(currentChallenge['difficulty']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12 * _scaleFactor),
                  border: Border.all(color: _getDifficultyColor(currentChallenge['difficulty'])),
                ),
                child: Text(
                  currentChallenge['difficulty'],
                  style: TextStyle(
                    color: _getDifficultyColor(currentChallenge['difficulty']),
                    fontSize: 10 * _scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16 * _scaleFactor),

          Text(
            currentChallenge['question'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * _scaleFactor,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          SizedBox(height: 16 * _scaleFactor),

          if (!_isCompleted) ...[
            Text(
              'Tap the falling code blocks to complete your solution:',
              style: TextStyle(color: Colors.white70, fontSize: 12 * _scaleFactor),
            ),
            SizedBox(height: 8 * _scaleFactor),
            _buildFallingBlocksArea(),
            SizedBox(height: 16 * _scaleFactor),
          ],

          _buildDailyChallengeCodeEditor(),

          SizedBox(height: 16 * _scaleFactor),

          if (!_isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 45 * _scaleFactor,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitDailyChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * _scaleFactor),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 18 * _scaleFactor,
                  width: 18 * _scaleFactor,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'SUBMIT CODE',
                  style: TextStyle(
                    fontSize: 14 * _scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],

          if (_showResult) ...[
            SizedBox(height: 16 * _scaleFactor),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(
                  color: _testResults.every((result) => result == 'PASSED') ? Colors.green : Colors.orange,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8 * _scaleFactor),
                  Text(
                    'Time: $_completionTime',
                    style: TextStyle(color: Colors.white70, fontSize: 12 * _scaleFactor),
                  ),
                  SizedBox(height: 8 * _scaleFactor),
                  Wrap(
                    spacing: 6 * _scaleFactor,
                    children: _testResults.asMap().entries.map((entry) {
                      int index = entry.key;
                      String result = entry.value;
                      return Chip(
                        label: Text(
                          'Test ${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10 * _scaleFactor,
                          ),
                        ),
                        backgroundColor: result == 'PASSED' ? Colors.green : Colors.red,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildBonusStartScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20 * _scaleFactor),
              margin: EdgeInsets.only(bottom: 30 * _scaleFactor),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20 * _scaleFactor),
                border: Border.all(color: Colors.amber),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10 * _scaleFactor,
                    offset: Offset(0, 5 * _scaleFactor),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz, size: 50 * _scaleFactor, color: Colors.amber),
                  SizedBox(height: 16 * _scaleFactor),
                  Text(
                    "Bonus Game",
                    style: TextStyle(
                      fontSize: 24 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Test your knowledge with quick questions",
                    style: TextStyle(
                      fontSize: 16 * _scaleFactor,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(12 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12 * _scaleFactor),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      '🎯 3 Questions - 10 Seconds Each',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14 * _scaleFactor,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('button_click.mp3');
                  startBonusGame();
                },
                icon: Icon(Icons.play_arrow, size: 24 * _scaleFactor),
                label: Text("Start Game", style: TextStyle(fontSize: 18 * _scaleFactor)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32 * _scaleFactor, vertical: 16 * _scaleFactor),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * _scaleFactor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBonusGameUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * _scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('📖 Question ${_bonusCurrentQuestionIndex + 1} of ${_bonusQuestions.length}',
                    style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _bonusIsTagalog = !_bonusIsTagalog;
                  });
                },
                icon: Icon(Icons.translate, size: 16 * _scaleFactor, color: Colors.white),
                label: Text(_bonusIsTagalog ? 'English' : 'Tagalog',
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 10 * _scaleFactor),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.amber[100]!.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(
                  color: _bonusRemainingSeconds <= 3 ? Colors.red : Colors.amber[700]!,
                  width: 2 * _scaleFactor
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_bonusCurrentQuestionIndex + 1} of ${_bonusQuestions.length}',
                      style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor, vertical: 4 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: _bonusRemainingSeconds <= 3 ? Colors.red : Colors.amber[700],
                        borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      ),
                      child: Text(
                        '${_bonusRemainingSeconds}s',
                        style: TextStyle(
                          fontSize: 12 * _scaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * _scaleFactor),
                Text(
                  _bonusIsTagalog ? _currentBonusQuestion['tagalogQuestion'] : _currentBonusQuestion['question'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * _scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30 * _scaleFactor),
          Text('💡 Select your answer:',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          Wrap(
            spacing: 12 * _scaleFactor,
            runSpacing: 12 * _scaleFactor,
            alignment: WrapAlignment.center,
            children: _currentBonusQuestion['options'].map<Widget>((answer) {
              bool isSelected = _selectedAnswer == answer;
              return GestureDetector(
                onTap: () => _selectBonusAnswer(answer),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * _scaleFactor,
                    vertical: 15 * _scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber[600] : Colors.amber[700],
                    borderRadius: BorderRadius.circular(20 * _scaleFactor),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2 * _scaleFactor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4 * _scaleFactor,
                        offset: Offset(2 * _scaleFactor, 2 * _scaleFactor),
                      )
                    ],
                  ),
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 14 * _scaleFactor,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 30 * _scaleFactor),

          if (_selectedAnswer.isNotEmpty)
            ElevatedButton.icon(
              onPressed: _bonusIsAnsweredCorrectly ? null : _checkBonusAnswer,
              icon: Icon(Icons.check, size: 18 * _scaleFactor),
              label: Text("Submit Answer", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * _scaleFactor,
                  vertical: 16 * _scaleFactor,
                ),
              ),
            ),

          SizedBox(height: 10 * _scaleFactor),
          TextButton(
            onPressed: _resetBonusGame,
            child: Text("🔁 Restart Quiz", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class FallingBlock {
  final int id;
  final String text;
  double top;
  double left;
  final Color color;

  FallingBlock({
    required this.id,
    required this.text,
    required this.left,
    this.top = 0,
    required this.color,
  });
}