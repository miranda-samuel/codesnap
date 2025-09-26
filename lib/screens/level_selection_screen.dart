import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late String selectedLanguage;
  Map<int, Map<String, dynamic>> scores = {};
  Map<String, dynamic>? currentUser;
  bool _isLoading = true;

  final levels = [
    'Level 1',
    'Level 2',
    'Level 3',
    'Level 4',
    'Level 5',
    'Level 6',
    'Level 7',
    'Level 8',
    'Level 9',
    'Level 10',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLanguage = ModalRoute.of(context)!.settings.arguments as String;
    _loadUserAndScores();
  }

  void _loadUserAndScores() async {
    final user = await UserPreferences.getUser();
    setState(() => currentUser = user);

    if (user['id'] != null) {
      _loadScores(user['id']);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadScores(int userId) async {
    try {
      final response = await ApiService.getScores(userId, selectedLanguage);

      if (response['success'] == true) {
        setState(() {
          scores = {};
          if (response['scores'] != null) {
            // Handle the scores data properly
            Map<String, dynamic> scoresData = response['scores'];
            scoresData.forEach((level, data) {
              int levelNum = int.tryParse(level) ?? 0;
              int scoreValue = data['score'] ?? 0;
              bool completed = data['completed'] ?? false;

              // Only show levels that have been completed (score > 0)
              if (levelNum > 0 && scoreValue > 0) {
                scores[levelNum] = {
                  'score': scoreValue,
                  'completed': completed
                };
              }
            });
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print('Failed to load scores: ${response['message']}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading scores: $e');
    }
  }

  Future<void> _resetScores() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.resetScores(currentUser!['id'], selectedLanguage);

      if (response['success'] == true) {
        // Clear local scores and update UI immediately
        setState(() {
          scores = {}; // Clear local scores
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All scores reset successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset scores: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting scores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Select Level: $selectedLanguage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt, color: Colors.white),
            onPressed: _resetScores,
            tooltip: 'Reset All Scores',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Levels',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final levelData = scores[levelNumber] ?? {'score': 0, 'completed': false};
                  final score = levelData['score'];
                  final isCompleted = levelData['completed'];

                  bool isUnlocked = true;
                  if (index > 0) {
                    final prevLevelData = scores[index] ?? {'score': 0, 'completed': false};
                    final prevCompleted = prevLevelData['completed'];
                    if (!prevCompleted || prevLevelData['score'] < 3) {
                      isUnlocked = false;
                    }
                  }

                  return Opacity(
                    opacity: isUnlocked ? 1.0 : 0.5,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.white.withOpacity(0.9),
                      child: ListTile(
                        leading: Icon(
                          isCompleted ? Icons.check_circle :
                          isUnlocked ? Icons.videogame_asset : Icons.lock,
                          color: isCompleted ? Colors.green :
                          isUnlocked ? Colors.teal.shade700 : Colors.grey,
                        ),
                        title: Text(
                          levels[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: Text(
                          'Score: $score/3',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: score == 3 ? Colors.green :
                            score > 0 ? Colors.orange : Colors.grey,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: isUnlocked ? Colors.teal.shade700 : Colors.grey),
                        onTap: () {
                          if (!isUnlocked) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("🔒 Level Locked"),
                                content: Text(
                                    "You need to complete ${levels[index - 1]} with a perfect score to unlock this level."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  )
                                ],
                              ),
                            );
                            return;
                          }

                          String route = '';
                          switch (selectedLanguage) {
                            case 'Python':
                              route = '/python_level${index + 1}';
                              break;
                            case 'Java':
                              route = '/java_level${index + 1}';
                              break;
                            case 'C++':
                              route = '/cpp_level${index + 1}';
                              break;
                            case 'PHP':
                              route = '/php_level${index + 1}';
                              break;
                            case 'SQL':
                              route = '/sql_level${index + 1}';
                              break;
                          }

                          Navigator.pushNamed(context, route);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}