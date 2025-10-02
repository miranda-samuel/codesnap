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
      'fullSolution': 'print("Hello World")',
      'expectedOutput': 'Hello World'
    },
    {
      'question': 'Complete the JavaScript variable declaration',
      'incompleteCode': [
        {'text': '// Declare a variable', 'type': 'comment'},
        {'text': '______ x = 5;', 'type': 'blank'},
        {'text': 'console.log(x);', 'type': 'code'},
      ],
      'options': ['variable', 'var', 'let', 'int'],
      'correctAnswer': 'var',
      'language': 'JavaScript',
      'fullSolution': 'var x = 5;\nconsole.log(x);',
      'expectedOutput': '5'
    },
    {
      'question': 'Complete the for loop syntax',
      'incompleteCode': [
        {'text': '// Loop through numbers', 'type': 'comment'},
        {'text': 'for (______ i = 0; i < 3; i++) {', 'type': 'blank'},
        {'text': '  console.log(i);', 'type': 'code'},
        {'text': '}', 'type': 'code'},
      ],
      'options': ['let', 'var', 'int', 'while'],
      'correctAnswer': 'let',
      'language': 'JavaScript',
      'fullSolution': 'for (let i = 0; i < 3; i++) {\n  console.log(i);\n}',
      'expectedOutput': '0\n1\n2'
    },
    {
      'question': 'Complete the if statement to check even number',
      'incompleteCode': [
        {'text': '# Check if number is even', 'type': 'comment'},
        {'text': 'x = 4', 'type': 'code'},
        {'text': 'if x ______ 2 == 0:', 'type': 'blank'},
        {'text': '    print("Even")', 'type': 'code'},
        {'text': 'else:', 'type': 'code'},
        {'text': '    print("Odd")', 'type': 'code'},
      ],
      'options': ['%', '/', '+', '*'],
      'correctAnswer': '%',
      'language': 'Python',
      'fullSolution': 'x = 4\nif x % 2 == 0:\n    print("Even")\nelse:\n    print("Odd")',
      'expectedOutput': 'Even'
    }
  ];

  int currentChallengeIndex = 0;
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

      // Auto-show the output dialog after answering
      Future.delayed(Duration(milliseconds: 500), () {
        _showCodeOutput();
      });
    });
  }

  void nextChallenge() {
    setState(() {
      if (currentChallengeIndex < challenges.length - 1) {
        currentChallengeIndex++;
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
      currentAnswer = null;
      showResult = false;
      score = 0;
      totalQuestions = 0;
    });
  }

  void _showCodeOutput() {
    var currentChallenge = challenges[currentChallengeIndex];
    bool isCorrect = currentAnswer == currentChallenge['correctAnswer'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.error,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isCorrect ? 'Code Executed Successfully!' : 'Syntax Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Terminal Output
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terminal Output:',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SelectableText(
                          isCorrect
                              ? currentChallenge['expectedOutput']
                              : 'Error: Incorrect syntax\nExpected: ${currentChallenge['expectedOutput']}',
                          style: TextStyle(
                            color: isCorrect ? Colors.white : Colors.red,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Complete Solution
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF252526),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.code, color: Colors.tealAccent, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Complete Solution:',
                            style: TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
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

                SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'CLOSE',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (currentChallengeIndex < challenges.length - 1) {
                          nextChallenge();
                        } else {
                          _showFinalScore();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        currentChallengeIndex < challenges.length - 1
                            ? 'NEXT CHALLENGE'
                            : 'SEE RESULTS',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: currentAnswer != null
                  ? (currentAnswer == challenges[currentChallengeIndex]['correctAnswer']
                  ? Colors.green[900]!.withOpacity(0.3)
                  : Colors.red[900]!.withOpacity(0.3))
                  : Colors.grey[800]!.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: candidateData.isNotEmpty
                    ? Colors.tealAccent
                    : (currentAnswer != null
                    ? (currentAnswer == challenges[currentChallengeIndex]['correctAnswer']
                    ? Colors.green
                    : Colors.red)
                    : Colors.grey[600]!),
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
                  currentAnswer ?? 'Drag answer here',
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
        onWillAccept: (data) => true,
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
        padding: EdgeInsets.symmetric(vertical: 4),
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
            tooltip: 'Restart Challenge',
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
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
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
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                    border: Border.all(color: Colors.tealAccent),
                  ),
                  child: Text(
                    currentChallenge['language'],
                    style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
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
                                'challenge.${currentChallenge['language'].toLowerCase()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                                ),
                                child: Text(
                                  currentChallenge['language'],
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

                        // Code Area
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...currentChallenge['incompleteCode'].map<Widget>((line) {
                                  return _buildCodeLine(line, currentChallenge['incompleteCode'].indexOf(line));
                                }).toList(),
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
                  'Drag the correct code snippet to the blank:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 15),

                // Options Grid
                Expanded(
                  flex: 1,
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
                          elevation: 4,
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
                              border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
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
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                            border: Border.all(
                              color: Colors.tealAccent.withOpacity(0.3),
                            ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}