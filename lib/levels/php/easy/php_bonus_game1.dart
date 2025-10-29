import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';

class PhpBonusGame1 extends StatefulWidget {
  const PhpBonusGame1({super.key});

  @override
  State<PhpBonusGame1> createState() => _PhpBonusGame1State();
}

class _PhpBonusGame1State extends State<PhpBonusGame1> {
  List<String> answerBlocks = [];
  String selectedAnswer = '';
  bool gameStarted = false;
  bool isTagalog = true;
  bool isAnsweredCorrectly = false;
  bool bonusCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int currentScore = 0;
  int totalPossibleScore = 50; // 50 POINTS for perfect score
  int questionsCorrect = 0;
  int remainingSeconds = 10;
  Timer? countdownTimer;
  Map<String, dynamic>? currentUser;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  // Questions and Answers for PHP - Advanced Concepts
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Which keyword is used to declare a constant in PHP?',
      'tagalogQuestion': 'Aling keyword ang ginagamit para mag-declare ng constant sa PHP?',
      'correctAnswer': 'define',
      'options': ['define', 'const', 'constant', 'set'],
      'points': 10
    },
    {
      'question': 'What is the default method for form submission in PHP?',
      'tagalogQuestion': 'Ano ang default na method para sa form submission sa PHP?',
      'correctAnswer': 'GET',
      'options': ['GET', 'POST', 'REQUEST', 'SUBMIT'],
      'points': 10
    },
    {
      'question': 'Which function is used to start a session in PHP?',
      'tagalogQuestion': 'Aling function ang ginagamit para magsimula ng session sa PHP?',
      'correctAnswer': 'session_start()',
      'options': ['session_start()', 'start_session()', 'session_begin()', 'begin_session()'],
      'points': 10
    },
    {
      'question': 'What does PDO stand for in PHP?',
      'tagalogQuestion': 'Ano ang ibig sabihin ng PDO sa PHP?',
      'correctAnswer': 'PHP Data Objects',
      'options': ['PHP Data Objects', 'PHP Database Output', 'PHP Data Operations', 'PHP Development Objects'],
      'points': 10
    },
    {
      'question': 'Which method is used to prevent SQL injection in PHP?',
      'tagalogQuestion': 'Anong method ang ginagamit para maiwasan ang SQL injection sa PHP?',
      'correctAnswer': 'Prepared Statements',
      'options': ['Prepared Statements', 'String Escape', 'Query Filter', 'SQL Clean'],
      'points': 10
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
      currentScore = 0;
      questionsCorrect = 0;
      remainingSeconds = 10;
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
      currentScore = 0;
      questionsCorrect = 0;
      remainingSeconds = 10;
      isAnsweredCorrectly = false;
      selectedAnswer = '';
      currentQuestionIndex = 0;
      answerBlocks = List.from(currentQuestion['options']);
      answerBlocks.shuffle();
    });
    startTimers();
  }

  void startTimers() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isAnsweredCorrectly) {
        timer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          timer.cancel();
          handleTimeUp();
        }
      });
    });
  }

  void handleTimeUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("⏰ Time's up! Moving to next question."),
        backgroundColor: Colors.orange[700],
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      if (mounted && currentQuestionIndex < questions.length - 1) {
        nextQuestion();
      } else if (mounted) {
        completeBonusGame();
      }
    });
  }

  void completeBonusGame() {
    countdownTimer?.cancel();

    // Only give points if ALL questions were correct
    final finalScore = questionsCorrect == questions.length ? totalPossibleScore : 0;

    // Save score to database for leaderboard
    saveScoreToDatabase(finalScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("🎉 Bonus Game Completed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 60, color: Colors.amber[700]),
            SizedBox(height: 10),
            Text("You've completed the PHP Bonus Game!"),
            SizedBox(height: 10),
            Text("Questions Correct: $questionsCorrect/${questions.length}",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (questionsCorrect == questions.length)
              Column(
                children: [
                  Text("🎉 PERFECT SCORE!",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
                  SizedBox(height: 10),
                  Text("🚧 More advanced levels coming soon!",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  SizedBox(height: 10),
                  Text(
                    "✅ $totalPossibleScore points added to your leaderboard!",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else
              Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "⚠️ Get all ${questions.length} questions correct to earn bonus points!",
                    style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _navigateToLevels();
            },
            child: Text("Back to Levels"),
          )
        ],
      ),
    );
  }

  void _navigateToLevels() {
    Navigator.pushReplacementNamed(context, '/levels', arguments: 'PHP');
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) return;

    try {
      print('🎯 SAVING BONUS POINTS: $score/$totalPossibleScore');

      // SAVE BONUS POINTS TO LEVEL 98 (Bonus Game 1)
      final response = await ApiService.saveScore(
        currentUser!['id'],
        'PHP',
        98,  // BONUS GAME 1 LEVEL
        score, // 50 POINTS FOR PERFECT SCORE
        true,  // ALWAYS MARK AS COMPLETED IF PERFECT
      );

      if (response['success'] == true) {
        print('✅ BONUS POINTS SAVED SUCCESSFULLY: $score points');

        setState(() {
          bonusCompleted = true;
          previousScore = score;
          hasPreviousScore = true;
        });
      } else {
        print('❌ FAILED TO SAVE BONUS: ${response['message']}');
      }
    } catch (e) {
      print('❌ ERROR SAVING BONUS: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScores(currentUser!['id'], 'PHP');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final bonusData = scoresData['98']; // Bonus Game 1 level

        if (bonusData != null) {
          setState(() {
            previousScore = (bonusData['score'] ?? 0) as int;
            bonusCompleted = bonusData['completed'] ?? false;
            hasPreviousScore = true;
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
    countdownTimer?.cancel();

    if (selectedAnswer == correctAnswer) {
      setState(() {
        isAnsweredCorrectly = true;
        questionsCorrect++;
        currentScore += (currentQuestion['points'] as int);
      });

      bool isLastQuestion = currentQuestionIndex == questions.length - 1;

      // Save score immediately when last question is answered correctly
      if (isLastQuestion) {
        final finalScore = questionsCorrect == questions.length ? totalPossibleScore : 0;
        await saveScoreToDatabase(finalScore);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Great job! Your answer is correct!"),
              SizedBox(height: 10),
              Text("Current Progress: $questionsCorrect/${questions.length} correct",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (questionsCorrect == questions.length)
                Text(
                  "🎉 Perfect! 🚧 More advanced levels coming soon!!",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                )
              else if (isLastQuestion)
                Text(
                  "❌ Not perfect - No bonus points earned",
                  style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (isLastQuestion) {
                  if (questionsCorrect == questions.length) {
                    _navigateToLevels();
                  } else {
                    _navigateToLevels();
                  }
                } else {
                  nextQuestion();
                }
              },
              child: Text(
                  isLastQuestion
                      ? "Back to Levels"
                      : "Next Question"
              ),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Incorrect answer. Moving to next question."),
          backgroundColor: Colors.red,
        ),
      );

      Future.delayed(Duration(seconds: 1), () {
        if (mounted && currentQuestionIndex < questions.length - 1) {
          nextQuestion();
        } else if (mounted) {
          completeBonusGame();
        }
      });
    }
  }

  void nextQuestion() {
    setState(() {
      currentQuestionIndex++;
      selectedAnswer = '';
      isAnsweredCorrectly = false;
      remainingSeconds = 10;
      answerBlocks = List.from(questions[currentQuestionIndex]['options']);
      answerBlocks.shuffle();
    });

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
    return "$seconds";
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
        title: Text("🎁 PHP - Bonus Game", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.amber[700], // AMBER THEME like Java
        actions: gameStarted
            ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
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
                Icon(Icons.star,
                    color: questionsCorrect == questions.length ? Colors.yellowAccent : Colors.grey,
                    size: 18 * _scaleFactor),
                Text(" $currentScore/$totalPossibleScore",
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
              Color(0xFF1A1A00), // DARK GOLD/GREEN THEME like Java
              Color(0xFF333300),
              Color(0xFF4D4D00),
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
                backgroundColor: Colors.amber[700], // AMBER THEME
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            if (bonusCompleted)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Bonus Completed!",
                      style: TextStyle(color: Colors.amber[700], fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    if (previousScore == totalPossibleScore)
                      Column(
                        children: [
                          Text(
                            "🎉 You earned $totalPossibleScore bonus points!",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10 * _scaleFactor),
                        ],
                      )
                    else
                      Text(
                        "❌ Get perfect score to earn bonus points",
                        style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
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
                      "📊 Your previous bonus score: $previousScore/$totalPossibleScore",
                      style: TextStyle(color: Colors.amber[700], fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Play again to get perfect score and earn bonus points!",
                      style: TextStyle(color: Colors.amber[600], fontSize: 14 * _scaleFactor),
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
                color: Colors.amber[50]!.withOpacity(0.9), // AMBER THEME
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 PHP BONUS GAME",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.amber[900]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Advanced PHP Concepts Challenge",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.amber[800], fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Answer all ${questions.length} questions correctly to earn bonus points",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.amber[800]),
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
                          "• ${questions.length} multiple choice questions\n• 10 seconds to answer each\n• Any wrong answer = 0 points\n• Perfect score earns bonus points",
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
                    "🎁 Topics: Constants, Forms, Sessions, PDO, SQL Injection",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.amber[700],
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

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.amber[100]!.withOpacity(0.9), // AMBER THEME
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(
                  color: remainingSeconds <= 3 ? Colors.red : Colors.amber[700]!,
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
                        color: Colors.amber[900],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor, vertical: 4 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: remainingSeconds <= 3 ? Colors.red : Colors.amber[700],
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
                    color: isSelected ? Colors.amber[600] : Colors.amber[700], // AMBER THEME
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
                backgroundColor: Colors.amber[700], // AMBER THEME
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