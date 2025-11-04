// level_selection_screen.dart - UPDATED
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
  late String selectedDifficulty;
  Map<int, Map<String, dynamic>> scores = {};
  Map<String, dynamic>? currentUser;
  bool _isLoading = true;

  final levels = [
    'Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5',
    'Level 6', 'Level 7', 'Level 8', 'Level 9', 'Level 10',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    selectedLanguage = args?['language'] ?? 'C++';
    selectedDifficulty = args?['difficulty'] ?? 'Easy';

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
      // USE DIFFICULTY-BASED SCORES
      if (selectedDifficulty == 'Easy') {
        // For Easy, use original method (backward compatibility)
        final response = await ApiService.getScores(userId, selectedLanguage);
        _processScoresResponse(response);
      } else {
        // For Medium/Hard, use difficulty-based method
        final response = await ApiService.getScoresWithDifficulty(userId, selectedLanguage, selectedDifficulty);
        _processScoresResponse(response);
      }
    } catch (e) {
      print('Error loading scores: $e');
      setState(() => _isLoading = false);
    }
  }

  void _processScoresResponse(Map<String, dynamic> response) {
    if (response['success'] == true) {
      setState(() {
        scores = {};
        if (response['scores'] != null) {
          Map<String, dynamic> scoresData = response['scores'];
          scoresData.forEach((level, data) {
            int levelNum = int.tryParse(level) ?? 0;
            int scoreValue = data['score'] ?? 0;
            bool completed = data['completed'] ?? false;

            if (levelNum > 0 && levelNum <= 30) {
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
    }
  }

  bool _isLevelUnlocked(int levelNumber) {
    if (levelNumber == 1) return true;

    final previousLevelData = scores[levelNumber - 1];
    if (previousLevelData != null) {
      final previousScore = previousLevelData['score'] ?? 0;
      final previousCompleted = previousLevelData['completed'] ?? false;
      return previousCompleted && previousScore == 3;
    }

    return false;
  }

  void _navigateToLevel(int levelNumber) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('click.mp3');

    String route = '';

    // ROUTES BASED ON LANGUAGE AND DIFFICULTY
    switch (selectedLanguage) {
      case 'C++':
        if (selectedDifficulty == 'Easy') {
          route = '/cpp_level$levelNumber';
        } else if (selectedDifficulty == 'Medium') {
          route = '/cpp_level${levelNumber}_medium';
        } else if (selectedDifficulty == 'Hard') {
          route = '/cpp_level${levelNumber}_hard';
        }
        break;
      case 'Python':
        if (selectedDifficulty == 'Easy') {
          route = '/python_level$levelNumber';
        } else if (selectedDifficulty == 'Medium') {
          route = '/python_level${levelNumber}_medium';
        } else if (selectedDifficulty == 'Hard') {
          route = '/python_level${levelNumber}_hard';
        }
        break;
      case 'Java':
        if (selectedDifficulty == 'Easy') {
          route = '/java_level$levelNumber';
        } else if (selectedDifficulty == 'Medium') {
          route = '/java_level${levelNumber}_medium';
        } else if (selectedDifficulty == 'Hard') {
          route = '/java_level${levelNumber}_hard';
        }
        break;
      case 'PHP':
        if (selectedDifficulty == 'Easy') {
          route = '/php_level$levelNumber';
        } else if (selectedDifficulty == 'Medium') {
          route = '/php_level${levelNumber}_medium';
        } else if (selectedDifficulty == 'Hard') {
          route = '/php_level${levelNumber}_hard';
        }
        break;
      case 'SQL':
        if (selectedDifficulty == 'Easy') {
          route = '/sql_level$levelNumber';
        } else if (selectedDifficulty == 'Medium') {
          route = '/sql_level${levelNumber}_medium';
        } else if (selectedDifficulty == 'Hard') {
          route = '/sql_level${levelNumber}_hard';
        }
        break;
    }

    if (route.isNotEmpty) {
      Navigator.pushNamed(context, route).then((_) {
        if (currentUser?['id'] != null) {
          _loadScores(currentUser!['id']);
        }
      });
    } else {
      // Fallback to easy level if route doesn't exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Level for $selectedDifficulty is coming soon! Using Easy level.')),
      );
      Navigator.pushNamed(context, '/${selectedLanguage.toLowerCase()}_level$levelNumber');
    }
  }

  Future<void> _resetScores() async {
    if (currentUser?['id'] == null) return;

    try {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('click.mp3');

      Map<String, dynamic> response;

      // USE DIFFICULTY-BASED RESET
      if (selectedDifficulty == 'Easy') {
        response = await ApiService.resetScores(currentUser!['id'], selectedLanguage);
      } else {
        response = await ApiService.resetScoresWithDifficulty(currentUser!['id'], selectedLanguage, selectedDifficulty);
      }

      if (response['success'] == true) {
        setState(() {
          scores = {};
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
          '$selectedLanguage $selectedDifficulty - Levels',
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
                            '$selectedDifficulty LEVELS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Complete with 3/3 perfect score to unlock next level',
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
                    final bool isUnlocked = _isLevelUnlocked(levelNumber);

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

              // Level Locking Info
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Get 3/3 perfect score to unlock next level',
                        style: TextStyle(
                          color: Colors.white70,
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
    );
  }

  Widget _buildLevelCard({
    required int levelNumber,
    required String title,
    required int score,
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    final bool isLocked = !isUnlocked;

    return GestureDetector(
      onTap: isLocked ? null : () => _navigateToLevel(levelNumber),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked ? [
              Colors.grey.withOpacity(0.6),
              Color(0xFF1B263B).withOpacity(0.8),
            ] : [
              _getDifficultyColor().withOpacity(0.8),
              Color(0xFF1B263B).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.grey.withOpacity(0.6)
                : (isCompleted
                ? Colors.greenAccent.withOpacity(0.6)
                : _getDifficultyColor().withOpacity(0.4)),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            if (!isLocked)
              BoxShadow(
                color: _getDifficultyColor().withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            if (isLocked)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.grey : _getDifficultyColor(),
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
                      if (isCompleted && !isLocked)
                        Icon(Icons.verified, color: Colors.greenAccent, size: 16),
                    ],
                  ),

                  SizedBox(
                    height: 20,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isLocked ? Colors.white60 : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (isLocked)
                    Container(
                      height: 24,
                      child: Center(
                        child: Text(
                          'LOCKED',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 24,
                      child: Row(
                        children: [
                          Icon(
                            score > 0 ? Icons.star : Icons.star_border,
                            color: score > 0 ? Colors.amber : Colors.grey,
                            size: 14,
                          ),
                          SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '$score/3',
                              style: TextStyle(
                                color: score > 0 ? Colors.amber : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green.withOpacity(0.3)
                                  : _getDifficultyColor().withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isCompleted ? 'DONE' : 'PLAY',
                              style: TextStyle(
                                color: isCompleted
                                    ? Colors.greenAccent
                                    : _getDifficultyColor(),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
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

  Color _getDifficultyColor() {
    switch (selectedDifficulty) {
      case 'Easy': return Colors.green;
      case 'Medium': return Colors.orange;
      case 'Hard': return Colors.red;
      default: return Colors.tealAccent;
    }
  }
}
