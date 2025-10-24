import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';
import '../services/music_service.dart';

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
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('click.mp3');

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

  void _navigateToLevel(int levelNumber) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('click.mp3');

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

              // Levels Grid Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'LEVELS 1-10',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 10),

              // All Levels Grid (1-10)
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final levelNumber = index + 1;
                    final levelData = scores[levelNumber] ?? {'score': 0, 'completed': false};
                    final score = levelData['score'];
                    final isCompleted = levelData['completed'];

                    // UPDATED UNLOCKING LOGIC
                    bool isUnlocked = _isLevelUnlocked(levelNumber);

                    return _buildLevelCard(
                      levelNumber: levelNumber,
                      title: levels[levelNumber - 1],
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

  // NEW METHOD: Check if level is unlocked
  bool _isLevelUnlocked(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return true; // Level 1 is always unlocked

      case 2:
      // Level 2 unlocked if Level 1 completed with perfect score
        return scores[1]?['completed'] == true && scores[1]?['score'] == 3;

      case 3:
      // Level 3 unlocked if Level 2 completed with perfect score
        return scores[2]?['completed'] == true && scores[2]?['score'] == 3;

      case 4:
      // Level 4 unlocked if Level 3 completed with perfect score
        return scores[3]?['completed'] == true && scores[3]?['score'] == 3;

      case 5:
      // Level 5 unlocked if Level 4 completed with perfect score
        return scores[4]?['completed'] == true && scores[4]?['score'] == 3;

      case 6:
      // LEVEL 6: ONLY unlocked through Bonus Game (Level 99) with perfect score
      // Check if Bonus Game (Level 99) was completed with perfect score
        return scores[99]?['completed'] == true && scores[99]?['score'] == 3;

      case 7:
      // Level 7 unlocked if Level 6 completed with perfect score
        return scores[6]?['completed'] == true && scores[6]?['score'] == 3;

      case 8:
      // Level 8 unlocked if Level 7 completed with perfect score
        return scores[7]?['completed'] == true && scores[7]?['score'] == 3;

      case 9:
      // Level 9 unlocked if Level 8 completed with perfect score
        return scores[8]?['completed'] == true && scores[8]?['score'] == 3;

      case 10:
      // Level 10 unlocked if Level 9 completed with perfect score
        return scores[9]?['completed'] == true && scores[9]?['score'] == 3;

      default:
        return false;
    }
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
        _navigateToLevel(levelNumber);
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
                size: 30,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Level Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.tealAccent : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LVL $levelNumber',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      if (!isUnlocked)
                        Icon(Icons.lock, color: Colors.white54, size: 16),
                      if (isCompleted)
                        Icon(Icons.verified, color: Colors.greenAccent, size: 16),
                    ],
                  ),

                  // Level Title
                  Text(
                    title,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),

                  // Score and Status
                  Row(
                    children: [
                      if (score > 0) ...[
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 2),
                        Text(
                          '$score/3',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.3)
                              : isUnlocked
                              ? Colors.tealAccent.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCompleted ? 'DONE' : isUnlocked ? 'PLAY' : 'LOCKED',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.greenAccent
                                : isUnlocked
                                ? Colors.tealAccent
                                : Colors.grey,
                            fontSize: 8,
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
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('error.mp3');

    String message = "";

    // UPDATED MESSAGES FOR EACH LEVEL
    switch (levelNumber) {
      case 2:
        message = "Complete Level 1 with a perfect score (3/3) to unlock this level.";
        break;
      case 3:
        message = "Complete Level 2 with a perfect score (3/3) to unlock this level.";
        break;
      case 4:
        message = "Complete Level 3 with a perfect score (3/3) to unlock this level.";
        break;
      case 5:
        message = "Complete Level 4 with a perfect score (3/3) to unlock this level.";
        break;
      case 6:
      // UPDATED: Level 6 is ONLY unlocked through Bonus Game
        message = "Complete the C++ Bonus Game with a perfect score (3/3) to unlock Level 6!";
        break;
      case 7:
        message = "Complete Level 6 with a perfect score (3/3) to unlock this level.";
        break;
      case 8:
        message = "Complete Level 7 with a perfect score (3/3) to unlock this level.";
        break;
      case 9:
        message = "Complete Level 8 with a perfect score (3/3) to unlock this level.";
        break;
      case 10:
        message = "Complete Level 9 with a perfect score (3/3) to unlock this level.";
        break;
      default:
        message = "Complete the previous level with a perfect score (3/3) to unlock this level.";
    }

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
          message,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              musicService.playSoundEffect('click.mp3');
              Navigator.pop(context);
            },
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
