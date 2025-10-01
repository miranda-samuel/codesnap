import 'package:flutter/material.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  // Coding challenges with incomplete code and draggable options
  final List<Map<String, dynamic>> challenges = [
    {
      'question': 'Complete the Python code to print "Hello World"',
      'incompleteCode': [
        {'text': '# Print Hello World', 'type': 'comment'},
        {'text': '______("Hello World")', 'type': 'blank'},
      ],
      'options': ['print', 'console.log', 'echo', 'System.out.println'],
      'correctAnswer': 'print',
      'language': 'Python',
      'fullSolution': 'print("Hello World")'
    },
    {
      'question': 'Complete the JavaScript variable declaration',
      'incompleteCode': [
        {'text': '// Declare a variable', 'type': 'comment'},
        {'text': '______ x = 5;', 'type': 'blank'},
      ],
      'options': ['variable', 'var', 'let', 'int'],
      'correctAnswer': 'var',
      'language': 'JavaScript',
      'fullSolution': 'var x = 5;'
    },
    {
      'question': 'Complete the for loop syntax',
      'incompleteCode': [
        {'text': '// Loop through numbers', 'type': 'comment'},
        {'text': 'for (______ i = 0; i < 10; i++) {', 'type': 'blank'},
        {'text': '  console.log(i);', 'type': 'code'},
        {'text': '}', 'type': 'code'},
      ],
      'options': ['let', 'var', 'int', 'while'],
      'correctAnswer': 'let',
      'language': 'JavaScript',
      'fullSolution': 'for (let i = 0; i < 10; i++) {\n  console.log(i);\n}'
    },
    {
      'question': 'Complete the if statement to check even number',
      'incompleteCode': [
        {'text': '// Check if number is even', 'type': 'comment'},
        {'text': 'if (x ______ 2 == 0) {', 'type': 'blank'},
        {'text': '  print("Even");', 'type': 'code'},
        {'text': '}', 'type': 'code'},
      ],
      'options': ['%', '/', '+', '*'],
      'correctAnswer': '%',
      'language': 'Python',
      'fullSolution': 'if (x % 2 == 0):\n  print("Even")'
    }
  ];

  int currentChallengeIndex = 0;
  String? draggedAnswer;
  String? currentAnswer;
  bool showResult = false;
  int score = 0;
  int totalQuestions = 0;

  void checkAnswer(String answer) {
    setState(() {
      currentAnswer = answer;
      showResult = true;
      totalQuestions++;

      if (answer == challenges[currentChallengeIndex]['correctAnswer']) {
        score++;
      }
    });
  }

  void nextChallenge() {
    setState(() {
      if (currentChallengeIndex < challenges.length - 1) {
        currentChallengeIndex++;
        draggedAnswer = null;
        currentAnswer = null;
        showResult = false;
      } else {
        _showFinalScore();
      }
    });
  }

  void resetChallenge() {
    setState(() {
      currentChallengeIndex = 0;
      draggedAnswer = null;
      currentAnswer = null;
      showResult = false;
      score = 0;
      totalQuestions = 0;
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Challenge Completed! 🎉',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Score: $score/$totalQuestions',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '${(score / totalQuestions * 100).toStringAsFixed(1)}% Correct',
                style: TextStyle(
                  color: score >= totalQuestions * 0.7 ? Colors.green : Colors.orange,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Come back tomorrow for new challenges!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetChallenge();
              },
              child: Text('TRY AGAIN', style: TextStyle(color: Colors.tealAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text('BACK HOME', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  Color _getOptionColor(String option) {
    if (!showResult) {
      return Colors.blue[800]!;
    }

    if (option == challenges[currentChallengeIndex]['correctAnswer']) {
      return Colors.green;
    } else if (option == currentAnswer && option != challenges[currentChallengeIndex]['correctAnswer']) {
      return Colors.red;
    }

    return Colors.blue[800]!;
  }

  Widget _buildCodeLine(Map<String, dynamic> line, int index) {
    if (line['type'] == 'blank') {
      return DragTarget<String>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: currentAnswer != null ? Colors.green[900] : Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: candidateData.isNotEmpty ? Colors.tealAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.ads_click,
                  color: Colors.white60,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  currentAnswer ?? '______',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
        onAccept: (data) {
          checkAnswer(data);
        },
      );
    } else {
      Color textColor = Colors.white;
      switch (line['type']) {
        case 'comment':
          textColor = Colors.green;
          break;
        case 'code':
          textColor = Colors.white;
          break;
      }

      return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Text(
          line['text'],
          style: TextStyle(
            color: textColor,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentChallenge = challenges[currentChallengeIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Daily Coding Challenge', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: resetChallenge,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress and Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Question ${currentChallengeIndex + 1}/${challenges.length}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Language Tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Text(
                    currentChallenge['language'],
                    style: TextStyle(color: Colors.tealAccent, fontSize: 12),
                  ),
                ),

                SizedBox(height: 20),

                // Question
                Text(
                  currentChallenge['question'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 20),

                // Code Editor - VSCode Style
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
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
                        // Editor Header
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.code, color: Colors.tealAccent, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'main.${currentChallenge['language'].toLowerCase()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  currentChallenge['language'],
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Code Area - FIXED: Made scrollable
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...currentChallenge['incompleteCode'].map<Widget>((line) {
                                  return _buildCodeLine(line, currentChallenge['incompleteCode'].indexOf(line));
                                }).toList(),

                                SizedBox(height: 16),

                                // Solution Preview when answered - FIXED: Smaller and scrollable
                                if (showResult)
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800]!.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Complete Solution:',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: SelectableText(
                                            currentChallenge['fullSolution'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Draggable Options
                Text(
                  'Drag the correct code snippet:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 15),

                // Options Grid - FIXED: Reduced flex value
                Expanded(
                  flex: 1, // Changed from 2 to 1 to give more space
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3,
                    ),
                    itemCount: currentChallenge['options'].length,
                    itemBuilder: (context, index) {
                      String option = currentChallenge['options'][index];
                      return Draggable<String>(
                        data: option,
                        feedback: Material(
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getOptionColor(option),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        childWhenDragging: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getOptionColor(option),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Next Button
                if (showResult)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: nextChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentChallengeIndex < challenges.length - 1
                            ? 'NEXT CHALLENGE'
                            : 'SEE RESULTS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}