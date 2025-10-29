import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';
import 'level6.dart';

class SQLBonusGame1 extends StatefulWidget {
  const SQLBonusGame1({super.key});

  @override
  State<SQLBonusGame1> createState() => _SQLBonusGame1State();
}

class _SQLBonusGame1State extends State<SQLBonusGame1> {
  List<String> sqlKeywords = [];
  List<String> answerBlocks = [];
  List<String> selectedAnswer = [];
  String correctAnswer = '';
  bool gameStarted = false;
  bool isTagalog = true;
  bool isAnsweredCorrectly = false;
  bool bonusCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int currentScore = 0;
  int totalPossibleScore = 50;
  int questionsCorrect = 0;
  int remainingSeconds = 15;
  Timer? countdownTimer;
  Map<String, dynamic>? currentUser;

  // Scaling factors
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  // Questions and Answers for SQL - Now with multiple parts
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Complete the SQL query to get all customers from London:',
      'tagalogQuestion': 'Kumpletuhin ang SQL query para makuha ang lahat ng customer mula sa London:',
      'correctAnswer': 'SELECT * FROM customers WHERE city = "London"',
      'sqlKeywords': ['SELECT', '*', 'FROM', 'customers', 'WHERE', 'city', '=', '"London"'],
      'distractors': ['INSERT', 'UPDATE', 'DELETE', 'name', 'age', '>', '<', 'LIKE'],
      'points': 10
    },
    {
      'question': 'Complete the SQL query to update product price to 25 where id is 5:',
      'tagalogQuestion': 'Kumpletuhin ang SQL query para i-update ang presyo ng product sa 25 kung saan ang id ay 5:',
      'correctAnswer': 'UPDATE products SET price = 25 WHERE id = 5',
      'sqlKeywords': ['UPDATE', 'products', 'SET', 'price', '=', '25', 'WHERE', 'id', '=', '5'],
      'distractors': ['SELECT', 'INSERT', 'DELETE', 'name', 'category', '>', '<', 'FROM'],
      'points': 10
    },
    {
      'question': 'Complete the SQL query to insert a new employee:',
      'tagalogQuestion': 'Kumpletuhin ang SQL query para mag-insert ng bagong employee:',
      'correctAnswer': 'INSERT INTO employees (name, salary) VALUES ("John", 50000)',
      'sqlKeywords': ['INSERT', 'INTO', 'employees', '(', 'name', ',', 'salary', ')', 'VALUES', '(', '"John"', ',', '50000', ')'],
      'distractors': ['UPDATE', 'DELETE', 'SELECT', 'age', 'department', 'SET', 'WHERE', 'FROM'],
      'points': 10
    },
    {
      'question': 'Complete the SQL query to delete orders older than 2023:',
      'tagalogQuestion': 'Kumpletuhin ang SQL query para mag-delete ng mga order na mas luma sa 2023:',
      'correctAnswer': 'DELETE FROM orders WHERE year < 2023',
      'sqlKeywords': ['DELETE', 'FROM', 'orders', 'WHERE', 'year', '<', '2023'],
      'distractors': ['INSERT', 'UPDATE', 'SELECT', 'month', '=', '>', 'SET', 'VALUES'],
      'points': 10
    },
    {
      'question': 'Complete the SQL query to count products in each category:',
      'tagalogQuestion': 'Kumpletuhin ang SQL query para bilangin ang mga product sa bawat category:',
      'correctAnswer': 'SELECT category, COUNT(*) FROM products GROUP BY category',
      'sqlKeywords': ['SELECT', 'category', ',', 'COUNT', '(', '*', ')', 'FROM', 'products', 'GROUP BY', 'category'],
      'distractors': ['INSERT', 'UPDATE', 'DELETE', 'WHERE', 'SET', 'VALUES', 'name', 'price'],
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
      remainingSeconds = 15;
      gameStarted = false;
      isAnsweredCorrectly = false;
      selectedAnswer = [];
      correctAnswer = '';
      currentQuestionIndex = 0;
      _setupQuestion();
    });
  }

  void _setupQuestion() {
    List<String> allBlocks = [
      ...currentQuestion['sqlKeywords'],
      ...currentQuestion['distractors']
    ];
    allBlocks.shuffle();

    setState(() {
      sqlKeywords = List.from(currentQuestion['sqlKeywords']);
      answerBlocks = allBlocks;
      correctAnswer = currentQuestion['correctAnswer'];
    });
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      currentScore = 0;
      questionsCorrect = 0;
      remainingSeconds = 15;
      isAnsweredCorrectly = false;
      selectedAnswer = [];
      correctAnswer = '';
      currentQuestionIndex = 0;
      _setupQuestion();
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
            Text("You've completed the SQL Query Builder Game!"),
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
                Navigator.of(context).pop();
                _navigateToLevel6();
              },
              child: Text("Play Level 6"),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

      final response = await ApiService.saveScore(
        currentUser!['id'],
        'SQL',
        99,  // BONUS LEVEL
        score,
        true,
      );

      if (response['success'] == true) {
        print('✅ BONUS POINTS SAVED SUCCESSFULLY: $score points');

        setState(() {
          bonusCompleted = true;
          previousScore = score;
          hasPreviousScore = true;
        });

        if (score == totalPossibleScore) {
          print('🔓 UNLOCKING LEVEL 6...');
          await ApiService.saveScore(
            currentUser!['id'],
            'SQL',
            6,
            0,
            true,
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

    String userAnswer = selectedAnswer.join(' ');
    String expectedAnswer = sqlKeywords.join(' ');

    countdownTimer?.cancel();

    if (userAnswer == expectedAnswer) {
      setState(() {
        isAnsweredCorrectly = true;
        questionsCorrect++;
        currentScore += (currentQuestion['points'] as int);
      });

      bool isLastQuestion = currentQuestionIndex == questions.length - 1;

      if (isLastQuestion) {
        final finalScore = questionsCorrect == questions.length ? totalPossibleScore : 0;
        await saveScoreToDatabase(finalScore);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct SQL Query!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Great job! You built the correct SQL query!"),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Text(
                  correctAnswer,
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 14 * _scaleFactor,
                  ),
                ),
              ),
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
                Navigator.of(context).pop();
                if (isLastQuestion) {
                  if (questionsCorrect == questions.length) {
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
          content: Text("❌ Incorrect query. Moving to next question."),
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
      selectedAnswer = [];
      isAnsweredCorrectly = false;
      remainingSeconds = 15;
      _setupQuestion();
    });

    startTimers();
  }

  void addToAnswer(String keyword) {
    if (!isAnsweredCorrectly) {
      setState(() {
        selectedAnswer.add(keyword);
      });
    }
  }

  void removeFromAnswer(int index) {
    if (!isAnsweredCorrectly) {
      setState(() {
        selectedAnswer.removeAt(index);
      });
    }
  }

  void clearAnswer() {
    if (!isAnsweredCorrectly) {
      setState(() {
        selectedAnswer.clear();
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
        title: Text("🧩 SQL Query Builder", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.purple[700],
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
              Color(0xFF2D1B69),
              Color(0xFF4A2C8C),
              Color(0xFF6B46C1),
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
              label: Text("Start Query Builder", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.purple[700],
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            if (bonusCompleted)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Query Builder Completed!",
                      style: TextStyle(color: Colors.purple[300], fontSize: 16 * _scaleFactor),
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
                      "📊 Your previous score: $previousScore/$totalPossibleScore",
                      style: TextStyle(color: Colors.purple[300], fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Play again to get perfect score and unlock Level 6!",
                      style: TextStyle(color: Colors.purple[300], fontSize: 14 * _scaleFactor),
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
                    "🧩 SQL QUERY BUILDER",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[900]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Build SQL queries by dragging keywords",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[800], fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Drag SQL keywords to build correct queries in the right order",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[800]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(10 * _scaleFactor),
                    color: Colors.black,
                    child: Column(
                      children: [
                        Text(
                          "⏰ 15 Seconds Per Query!",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * _scaleFactor,
                          ),
                        ),
                        SizedBox(height: 5 * _scaleFactor),
                        Text(
                          "• ${questions.length} SQL query building challenges\n• 15 seconds to build each query\n• Drag keywords in correct order\n• Perfect score unlocks Level 6",
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
                        color: Colors.purple[700],
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
          // Question
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.purple[100]!.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(
                  color: remainingSeconds <= 3 ? Colors.red : Colors.purple[700]!,
                  width: 2 * _scaleFactor
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Query ${currentQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor, vertical: 4 * _scaleFactor),
                      decoration: BoxDecoration(
                        color: remainingSeconds <= 3 ? Colors.red : Colors.purple[700],
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

          SizedBox(height: 20 * _scaleFactor),

          // Answer Builder Area
          Text('🧩 Build Your SQL Query:',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 10 * _scaleFactor),

          Container(
            width: double.infinity,
            height: 100 * _scaleFactor,
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
              border: Border.all(color: Colors.purple[300]!),
            ),
            child: selectedAnswer.isEmpty
                ? Center(
              child: Text(
                "Drag SQL keywords here to build your query...",
                style: TextStyle(color: Colors.grey, fontSize: 14 * _scaleFactor),
                textAlign: TextAlign.center,
              ),
            )
                : Wrap(
              spacing: 8 * _scaleFactor,
              runSpacing: 8 * _scaleFactor,
              children: List.generate(selectedAnswer.length, (index) {
                return GestureDetector(
                  onTap: () => removeFromAnswer(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 8 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.purple[600],
                      borderRadius: BorderRadius.circular(20 * _scaleFactor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedAnswer[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * _scaleFactor,
                          ),
                        ),
                        SizedBox(width: 4 * _scaleFactor),
                        Icon(Icons.close, size: 14 * _scaleFactor, color: Colors.white),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 10 * _scaleFactor),
          if (selectedAnswer.isNotEmpty)
            TextButton(
              onPressed: clearAnswer,
              child: Text("🗑️ Clear Query", style: TextStyle(fontSize: 12 * _scaleFactor, color: Colors.white)),
            ),

          SizedBox(height: 20 * _scaleFactor),

          // SQL Keywords
          Text('🔤 Available SQL Keywords:',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 10 * _scaleFactor),

          Wrap(
            spacing: 8 * _scaleFactor,
            runSpacing: 8 * _scaleFactor,
            alignment: WrapAlignment.center,
            children: answerBlocks.map((keyword) {
              bool isUsed = selectedAnswer.contains(keyword);
              bool isCorrectKeyword = currentQuestion['sqlKeywords'].contains(keyword);

              return GestureDetector(
                onTap: isUsed ? null : () => addToAnswer(keyword),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * _scaleFactor, vertical: 10 * _scaleFactor),
                  decoration: BoxDecoration(
                    color: isUsed ? Colors.grey : (isCorrectKeyword ? Colors.purple[600] : Colors.red[400]),
                    borderRadius: BorderRadius.circular(20 * _scaleFactor),
                    border: Border.all(
                      color: isUsed ? Colors.transparent : Colors.white,
                      width: 1 * _scaleFactor,
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 14 * _scaleFactor,
                      color: Colors.white,
                    ),
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
              label: Text("Execute Query", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * _scaleFactor,
                  vertical: 16 * _scaleFactor,
                ),
              ),
            ),

          SizedBox(height: 10 * _scaleFactor),
          TextButton(
            onPressed: resetGame,
            child: Text("🔁 Restart Game", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}