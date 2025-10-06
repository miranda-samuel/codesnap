import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';

class PythonBonusGame extends StatefulWidget {
  const PythonBonusGame({super.key});

  @override
  State<PythonBonusGame> createState() => _PythonBonusGameState();
}

class _PythonBonusGameState extends State<PythonBonusGame> {
  List<String> questionBlocks = [];
  List<String> answerBlocks = [];
  String selectedAnswer = '';
  bool gameStarted = false;
  bool isTagalog = true; // Default to Tagalog
  bool isAnsweredCorrectly = false;
  bool bonusCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 10; // 10 seconds per question
  Timer? countdownTimer;
  Map<String, dynamic>? currentUser;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  // Questions and Answers for Python
  List<Map<String, dynamic>> questions = [
    {
      'question': 'What is used to output text in Python?',
      'tagalogQuestion': 'Ano ang ginagamit para mag-output ng text sa Python?',
      'correctAnswer': 'print',
      'options': ['print', 'cout', 'printf', 'System.out.println']
    },
    {
      'question': 'What is the correct operator for comparison?',
      'tagalogQuestion': 'Ano ang tamang operator para sa comparison?',
      'correctAnswer': '==',
      'options': ['=', '==', '===', '!=']
    },
    {
      'question': 'What data type is used for whole numbers?',
      'tagalogQuestion': 'Ano ang data type para sa mga buong numero?',
      'correctAnswer': 'int',
      'options': ['String', 'float', 'int', 'char']
    },
    {
      'question': 'What indicates the start of a code block in Python?',
      'tagalogQuestion': 'Ano ang nag-i-indicate ng simula ng code block sa Python?',
      'correctAnswer': ':',
      'options': [',', ';', ':', '.', '{']
    },
    {
      'question': 'What is used for conditional statements?',
      'tagalogQuestion': 'Ano ang ginagamit para sa conditional statements?',
      'correctAnswer': 'if',
      'options': ['if', 'while', 'for', 'switch']
    }
  ];

  int currentQuestionIndex = 0;
  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _calculateScaleFactor();
    resetGame();
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

  void resetGame() {
    setState(() {
      score = 3; // Always reset to 3
      remainingSeconds = 10; // Reset to 10 seconds
      gameStarted = false;
      isAnsweredCorrectly = false;
      selectedAnswer = '';
      currentQuestionIndex = 0;
      answerBlocks = List.from(currentQuestion['options']);
      answerBlocks.shuffle();
    });
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      score = 3; // Always start with 3 points
      remainingSeconds = 10; // Start with 10 seconds
      isAnsweredCorrectly = false;
      selectedAnswer = '';
      currentQuestionIndex = 0;
      answerBlocks = List.from(currentQuestion['options']);
      answerBlocks.shuffle();
    });
    startTimers();
  }

  void startTimers() {
    // Cancel any existing timers
    countdownTimer?.cancel();

    // Start 10-second countdown for current question
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isAnsweredCorrectly) {
        timer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          // Time's up for this question
          timer.cancel();
          handleTimeUp();
        }
      });
    });
  }

  void handleTimeUp() {
    if (score > 1) {
      setState(() {
        score--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⏰ Time's up! -1 point. Current score: $score"),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      setState(() {
        score = 0;
      });
    }

    // Move to next question automatically
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && currentQuestionIndex < questions.length - 1) {
        nextQuestion();
      } else if (mounted) {
        // Last question completed
        completeBonusGame();
      }
    });
  }

  void completeBonusGame() {
    countdownTimer?.cancel();
    saveScoreToDatabase(score);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("🎉 Bonus Game Completed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 60, color: Colors.purple),
            SizedBox(height: 10),
            Text("You've completed the Python Bonus Game!"),
            SizedBox(height: 10),
            Text("Final Score: $score/3",
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: score == 3 ? Colors.green : Colors.orange)),
            SizedBox(height: 10),
            Text(
              "🔓 Level 4 is now unlocked!",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            if (score < 3)
              Text("Good job! You can now proceed to Level 4.",
                  style: TextStyle(color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/levels', arguments: 'Python');
            },
            child: Text("Go to Levels"),
          )
        ],
      ),
    );
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) return;

    try {
      // BONUS GAME: Use level 99 to avoid conflict with regular levels
      final response = await ApiService.saveScore(
        currentUser!['id'],
        'Python',
        99, // Use level 99 for bonus game
        score,
        true, // Always true for bonus game to unlock next levels
      );

      if (response['success'] == true) {
        setState(() {
          bonusCompleted = true; // Always completed for bonus game
          previousScore = score;
          hasPreviousScore = true;
        });

        // Also unlock Level 4 if bonus game is completed with any score
        if (score > 0) {
          await ApiService.saveScore(
            currentUser!['id'],
            'Python',
            4, // Unlock Level 4
            0, // No score yet
            true, // Mark as accessible
          );
        }
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
        final bonusData = scoresData['99']; // Check level 99 for bonus game data

        if (bonusData != null) {
          setState(() {
            previousScore = bonusData['score'] ?? 0;
            bonusCompleted = bonusData['completed'] ?? false;
            hasPreviousScore = true;
            // DON'T set current score to previous score - start fresh every time
          });
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || selectedAnswer.isEmpty) return;

    String correctAnswer = currentQuestion['correctAnswer'];

    // Stop the timer when answer is submitted
    countdownTimer?.cancel();

    if (selectedAnswer == correctAnswer) {
      setState(() {
        isAnsweredCorrectly = true;
      });

      // Check if it's the last question
      bool isLastQuestion = currentQuestionIndex == questions.length - 1;

      if (isLastQuestion) {
        saveScoreToDatabase(score);
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Great job! Your answer is correct!"),
              SizedBox(height: 10),
              Text("Your Current Score: $score/3",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (isLastQuestion)
                Column(
                  children: [
                    Text(
                      "🎉 Bonus Game Completed!",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "🔓 Level 4 is now unlocked!",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              SizedBox(height: 10),
              Text("Explanation:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Question: ${isTagalog ? currentQuestion['tagalogQuestion'] : currentQuestion['question']}"),
                    Text("Your Answer: $selectedAnswer"),
                    Text("Correct Answer: $correctAnswer"),
                    SizedBox(height: 5),
                    Text("Time Remaining: ${remainingSeconds}s",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: remainingSeconds > 5 ? Colors.green : Colors.orange)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isLastQuestion) {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: 'Python');
                } else {
                  nextQuestion();
                }
              },
              child: Text(isLastQuestion ? "Go Back to Levels" : "Next Question"),
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
          SnackBar(
            content: Text("❌ Incorrect answer. -1 point. Current score: $score"),
            backgroundColor: Colors.red,
          ),
        );

        // Move to next question even if wrong
        Future.delayed(Duration(seconds: 1), () {
          if (mounted && currentQuestionIndex < questions.length - 1) {
            nextQuestion();
          } else if (mounted) {
            // Last question completed
            completeBonusGame();
          }
        });
      } else {
        setState(() {
          score = 0;
        });
        completeBonusGame();
      }
    }
  }

  void nextQuestion() {
    setState(() {
      currentQuestionIndex++;
      selectedAnswer = '';
      isAnsweredCorrectly = false;
      remainingSeconds = 10; // Reset to 10 seconds for new question
      answerBlocks = List.from(questions[currentQuestionIndex]['options']);
      answerBlocks.shuffle();
    });

    // Restart timer for new question
    startTimers();
  }

  void selectAnswer(String answer) {
    if (!isAnsweredCorrectly) {
      setState(() {
        selectedAnswer = answer;
      });
    }
  }

  String formatTime(int seconds) {
    return "$seconds"; // Just show seconds since it's only 10 seconds
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
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
        title: Text("🎁 Python - Bonus Game", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.purple,
        actions: gameStarted
            ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
                // Timer with color change when time is running out
                Icon(Icons.timer,
                    size: 18 * _scaleFactor,
                    color: remainingSeconds <= 3 ? Colors.red : Colors.white),
                SizedBox(width: 4 * _scaleFactor),
                Text("${formatTime(remainingSeconds)}s",
                    style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: remainingSeconds <= 3 ? Colors.red : Colors.white,
                        fontWeight: remainingSeconds <= 3 ? FontWeight.bold : FontWeight.normal)),
                SizedBox(width: 16 * _scaleFactor),
                Icon(Icons.star, color: Colors.yellowAccent, size: 18 * _scaleFactor),
                Text(" $score",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor)),
                SizedBox(width: 8 * _scaleFactor),
                Text("Q: ${currentQuestionIndex + 1}/${questions.length}",
                    style: TextStyle(fontSize: 12 * _scaleFactor)),
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
              onPressed: startGame,
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Start Bonus Game", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.purple,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            if (bonusCompleted)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Bonus Game Completed!",
                      style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "🔓 Level 4 is unlocked!",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    if (previousScore > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 5 * _scaleFactor),
                        child: Text(
                          "Your Best Score: $previousScore/3",
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 14 * _scaleFactor),
                          textAlign: TextAlign.center,
                        ),
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
                      style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Play again to improve your score!",
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 14 * _scaleFactor),
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
                color: Colors.purple[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎁 PYTHON BONUS GAME",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Complete this bonus game to unlock Level 4!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[700], fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Answer 5 questions about Python fundamentals!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Column(
                      children: [
                        Text(
                          "⏰ 10 Seconds Per Question!",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * _scaleFactor,
                          ),
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "• 5 multiple choice questions\n• 10 seconds to answer each\n• Test your Python knowledge\n• Based on previous levels",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12 * _scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "💡 Complete this bonus game to unlock Level 4!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.purple[600], fontStyle: FontStyle.italic),
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
                child: Text('📖 Question',
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

          // Question Card with timer indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.purple[100]!.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(
                  color: remainingSeconds <= 3 ? Colors.red : Colors.purple,
                  width: 2 * _scaleFactor
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor, vertical: 4 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: remainingSeconds <= 3 ? Colors.red : Colors.purple,
                        borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      ),
                      child: Text(
                        '${remainingSeconds}s',
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
                  isTagalog ? currentQuestion['tagalogQuestion'] : currentQuestion['question'],
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

          // Answer Options
          Wrap(
            spacing: 12 * _scaleFactor,
            runSpacing: 12 * _scaleFactor,
            alignment: WrapAlignment.center,
            children: answerBlocks.map((answer) {
              bool isSelected = selectedAnswer == answer;
              return GestureDetector(
                onTap: () => selectAnswer(answer),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * _scaleFactor,
                    vertical: 15 * _scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purpleAccent : Colors.purple,
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

          if (selectedAnswer.isNotEmpty)
            ElevatedButton.icon(
              onPressed: isAnsweredCorrectly ? null : checkAnswer,
              icon: Icon(Icons.check, size: 18 * _scaleFactor),
              label: Text("Submit Answer", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * _scaleFactor,
                  vertical: 16 * _scaleFactor,
                ),
              ),
            ),

          SizedBox(height: 10 * _scaleFactor),
          TextButton(
            onPressed: resetGame,
            child: Text("🔁 Restart Quiz", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}