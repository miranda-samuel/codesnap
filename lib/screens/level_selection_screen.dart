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
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          '$selectedLanguage - SELECT LEVEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xFF1B263B),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.tealAccent),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt, color: Colors.tealAccent),
            onPressed: _resetScores,
            tooltip: 'Reset All Scores',
          ),
        ],
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
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Color(0xFF1B263B).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.tealAccent, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CODE QUEST',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Complete levels to master $selectedLanguage',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Levels Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final levelNumber = index + 1;
                    final levelData = scores[levelNumber] ?? {'score': 0, 'completed': false};
                    final score = levelData['score'];
                    final isCompleted = levelData['completed'];

                    bool isUnlocked = levelNumber == 1 ||
                        (scores[levelNumber - 1]?['completed'] == true &&
                            scores[levelNumber - 1]?['score'] == 3);

                    return _buildLevelCard(
                      levelNumber: levelNumber,
                      title: levels[index],
                      score: score,
                      isCompleted: isCompleted,
                      isUnlocked: isUnlocked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required int levelNumber,
    required String title,
    required int score,
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isUnlocked) {
          _showLockedDialog(levelNumber);
          return;
        }

        String route = '';
        switch (selectedLanguage) {
          case 'Python':
            route = '/python_level$levelNumber';
            break;
          case 'Java':
            route = '/java_level$levelNumber';
            break;
          case 'C++':
            route = '/cpp_level$levelNumber';
            break;
          case 'PHP':
            route = '/php_level$levelNumber';
            break;
          case 'SQL':
            route = '/sql_level$levelNumber';
            break;
        }

        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
              Color(0xFF415A77).withOpacity(0.8),
              Color(0xFF1B263B).withOpacity(0.8),
            ]
                : [
              Colors.grey.withOpacity(0.3),
              Colors.grey.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.greenAccent.withOpacity(0.6)
                : isUnlocked
                ? Colors.tealAccent.withOpacity(0.4)
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            if (isUnlocked)
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: 8,
              top: 8,
              child: Icon(
                Icons.code,
                size: 40,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Level Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.tealAccent : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'LVL $levelNumber',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      if (!isUnlocked)
                        Icon(Icons.lock, color: Colors.white54, size: 20),
                      if (isCompleted)
                        Icon(Icons.verified, color: Colors.greenAccent, size: 20),
                    ],
                  ),

                  // Level Title
                  Text(
                    title,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),

                  // Score and Status
                  Row(
                    children: [
                      if (score > 0) ...[
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '$score/3',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.3)
                              : isUnlocked
                              ? Colors.tealAccent.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCompleted ? 'COMPLETED' : isUnlocked ? 'PLAY' : 'LOCKED',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.greenAccent
                                : isUnlocked
                                ? Colors.tealAccent
                                : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(int levelNumber) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.tealAccent.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 10),
            Text(
              "LEVEL LOCKED",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        content: Text(
          "Complete Level ${levelNumber - 1} with a perfect score (3/3) to unlock this level.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "UNDERSTOOD",
              style: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}