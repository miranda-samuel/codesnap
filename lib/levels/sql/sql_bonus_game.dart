import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../services/user_preferences.dart';
import 'level6.dart';

class SQLBonusGame extends StatefulWidget {
  const SQLBonusGame({super.key});

  @override
  State<SQLBonusGame> createState() => _SQLBonusGameState();
}

class _SQLBonusGameState extends State<SQLBonusGame> {
  List<String> answerBlocks = [];
  String selectedAnswer = '';
  bool gameStarted = false;
  bool isTagalog = true;
  bool isAnsweredCorrectly = false;
  bool bonusCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int currentScore = 0;
  int totalPossibleScore = 50;
  int questionsCorrect = 0;
  int remainingSeconds = 10;
  Timer? countdownTimer;
  Map<String, dynamic>? currentUser;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  // Questions and Answers for SQL
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Which SQL command is used to retrieve data from a database?',
      'tagalogQuestion': 'Aling SQL command ang ginagamit para kumuha ng data mula sa database?',
      'correctAnswer': 'SELECT',
      'options': ['SELECT', 'GET', 'RETRIEVE', 'FETCH'],
      'points': 10
    },
    {
      'question': 'Which clause is used to filter records in SQL?',
      'tagalogQuestion': 'Aling clause ang ginagamit para mag-filter ng mga record sa SQL?',
      'correctAnswer': 'WHERE',
      'options': ['WHERE', 'FILTER', 'HAVING', 'CONDITION'],
      'points': 10
    },
    {
      'question': 'Which SQL command is used to add new records to a table?',
      'tagalogQuestion': 'Aling SQL command ang ginagamit para magdagdag ng bagong records sa isang table?',
      'correctAnswer': 'INSERT',
      'options': ['INSERT', 'ADD', 'CREATE', 'NEW'],
      'points': 10
    },
    {
      'question': 'Which SQL command is used to update existing records?',
      'tagalogQuestion': 'Aling SQL command ang ginagamit para i-update ang mga existing na records?',
      'correctAnswer': 'UPDATE',
      'options': ['UPDATE', 'MODIFY', 'CHANGE', 'EDIT'],
      'points': 10
    },
    {
      'question': 'Which SQL command is used to delete records from a table?',
      'tagalogQuestion': 'Aling SQL command ang ginagamit para mag-delete ng records mula sa isang table?',
      'correctAnswer': 'DELETE',
      'options': ['DELETE', 'REMOVE', 'DROP', 'ERASE'],
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
            Text("You've completed the SQL Bonus Game!"),
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
                  Text("Bonus Points Earned: $totalPossibleScore",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  SizedBox(height: 10),
                  Text(
                    "🔓 Level 6 is now unlocked!",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
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
                    "⚠️ Get all ${questions.length} questions correct to unlock Level 6!",
                    style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
        actions: [
          if (questionsCorrect == questions.length)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _navigateToLevel6();
              },
              child: Text("Play Level 6"),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _navigateToLevels();
            },
            child: Text(questionsCorrect == questions.length ? "Back to Levels" : "Go to Levels"),
          )
        ],
      ),
    );
  }

  void _navigateToLevel6() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SqlLevel6(),
      ),
    );
  }

  void _navigateToLevels() {
    Navigator.pushReplacementNamed(context, '/levels', arguments: 'SQL');
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) return;

    try {
      print('🎯 SAVING BONUS POINTS: $score/$totalPossibleScore');

      // SAVE BONUS POINTS TO LEVEL 99
      final response = await ApiService.saveScore(
        currentUser!['id'],
        'SQL',
        99,  // BONUS LEVEL
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

        // UNLOCK LEVEL 6 IF PERFECT SCORE
        if (score == totalPossibleScore) {
          print('🔓 UNLOCKING LEVEL 6...');
          await ApiService.saveScore(
            currentUser!['id'],
            'SQL',
            6,  // LEVEL 6
            0,  // 0 POINTS - user needs to play level 6 to earn points
            true, // MARK AS UNLOCKED
          );
          print('✅ LEVEL 6 UNLOCKED');
        }
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
      final response = await ApiService.getScores(currentUser!['id'], 'SQL');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final bonusData = scoresData['99'];

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
                  "🎉 Perfect! You Unlocked Level 6",
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
                    // Navigate directly to Level 6 when perfect
                    _navigateToLevel6();
                  } else {
                    _navigateToLevels();
                  }
                } else {
                  nextQuestion();
                }
              },
              child: Text(
                  isLastQuestion
                      ? (questionsCorrect == questions.length ? "Next Level" : "Back to Levels")
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
        title: Text("🎁 SQL - Bonus Game", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.amber[700], // CHANGED TO AMBER THEME
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
              Color(0xFF1A1A00), // DARK GOLD
              Color(0xFF333300), // MEDIUM GOLD
              Color(0xFF4D4D00), // LIGHT GOLD
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
                backgroundColor: Colors.amber[700], // CHANGED TO AMBER THEME
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
                      style: TextStyle(color: Colors.amber[700], fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    if (previousScore == totalPossibleScore)
                      Column(
                        children: [
                          Text(
                            "🎉 You earned $totalPossibleScore bonus points! Level 6 is unlocked!",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10 * _scaleFactor),
                          ElevatedButton(
                            onPressed: _navigateToLevel6,
                            child: Text("Play Level 6 Now"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        "❌ Get perfect score to unlock Level 6",
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
                      "Play again to get perfect score and unlock Level 6!",
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
                color: Colors.amber[50]!.withOpacity(0.9), // CHANGED TO AMBER THEME
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.amber[200]!), // CHANGED TO AMBER THEME
              ),
              child: Column(
                children: [
                  Text(
                    "🎁 SQL BONUS GAME",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.amber[900]), // CHANGED TO AMBER THEME
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Get Perfect Score to unlock Level 6",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.amber[800], fontWeight: FontWeight.bold), // CHANGED TO AMBER THEME
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Answer all ${questions.length} questions correctly to unlock Level 6",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.amber[800]), // CHANGED TO AMBER THEME
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
                          "• ${questions.length} multiple choice questions\n• 10 seconds to answer each\n• Any wrong answer = 0 points\n• Perfect score unlocks Level 6",
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
                    "🎁 Get a perfect score (5/5) to unlock Level 6",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.amber[700], // CHANGED TO AMBER THEME
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
              color: Colors.amber[100]!.withOpacity(0.9), // CHANGED TO AMBER THEME
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(
                  color: remainingSeconds <= 3 ? Colors.red : Colors.amber[700]!, // CHANGED TO AMBER THEME
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
                        color: Colors.amber[900], // CHANGED TO AMBER THEME
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor, vertical: 4 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: remainingSeconds <= 3 ? Colors.red : Colors.amber[700], // CHANGED TO AMBER THEME
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
                    color: isSelected ? Colors.amber[600] : Colors.amber[700], // CHANGED TO AMBER THEME
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
                backgroundColor: Colors.amber[700], // CHANGED TO AMBER THEME
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