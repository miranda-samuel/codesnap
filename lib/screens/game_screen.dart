import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String language;
  late String level;
  late int levelNumber;
  Map<String, dynamic>? currentUser;

  final List<String> codeBlocks = ['print', '(', '"Hello World"', ')'];
  List<String> droppedBlocks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    language = args?['language'] ?? 'Python';
    level = args?['level'] ?? 'Level 1';
    levelNumber = int.tryParse(level.split(' ').last) ?? 1;
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() => currentUser = user);
  }

  void checkAnswer() async {
    String answer = droppedBlocks.join(' ');
    if (answer == 'print ( "Hello World" )') {
      // Save score to backend
      if (currentUser?['id'] != null) {
        final response = await ApiService.saveScore(
          currentUser!['id'],
          language,
          levelNumber,
          3, // Perfect score
          true, // Completed
        );

        if (response['success'] == true) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Correct!"),
              content: Text("Well done, $language programmer!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Next"),
                )
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving score: ${response['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please login to save your score")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CodeSnap - $language [$level]'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '👉 Arrange the blocks to print "Hello World":',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: droppedBlocks.length,
                    itemBuilder: (context, index) {
                      return codeBlock(droppedBlocks[index]);
                    },
                  );
                },
                onAccept: (data) {
                  setState(() {
                    droppedBlocks.add(data);
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              children: codeBlocks.map((block) {
                return Draggable<String>(
                  data: block,
                  feedback: codeBlock(block),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: codeBlock(block),
                  ),
                  child: codeBlock(block),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: checkAnswer,
              child: Text("Run Code"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  droppedBlocks.clear();
                });
              },
              child: Text("Reset"),
            )
          ],
        ),
      ),
    );
  }

  Widget codeBlock(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
