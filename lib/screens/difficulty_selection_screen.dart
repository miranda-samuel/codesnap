// difficulty_selection_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';
import '../services/music_service.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  late String selectedLanguage;
  Map<String, dynamic>? currentUser;
  Map<int, Map<String, dynamic>> easyScores = {};
  Map<int, Map<String, dynamic>> mediumScores = {};
  Map<int, Map<String, dynamic>> hardScores = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _difficulties = [
    {
      'name': 'Easy',
      'description': 'Perfect for beginners - 1× points',
      'icon': Icons.flag,
      'color': Colors.green,
      'multiplier': 1,
      'levels': 10,
      'startLevel': 1,
    },
    {
      'name': 'Medium',
      'description': 'Challenge yourself - 2× points',
      'icon': Icons.landscape,
      'color': Colors.orange,
      'multiplier': 2,
      'levels': 10,
      'startLevel': 1,
    },
    {
      'name': 'Hard',
      'description': 'Expert level challenges - 3× points',
      'icon': Icons.terrain,
      'color': Colors.red,
      'multiplier': 3,
      'levels': 10,
      'startLevel': 1,
    },
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
      await _loadAllDifficultyScores(user['id']);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllDifficultyScores(int userId) async {
    try {
      // Load scores for ALL difficulties
      final easyResponse = await ApiService.getScores(userId, selectedLanguage);
      final mediumResponse = await ApiService.getScoresWithDifficulty(userId, selectedLanguage, 'Medium');
      final hardResponse = await ApiService.getScoresWithDifficulty(userId, selectedLanguage, 'Hard');

      setState(() {
        // Process Easy scores
        easyScores = {};
        if (easyResponse['success'] == true && easyResponse['scores'] != null) {
          Map<String, dynamic> scoresData = easyResponse['scores'];
          scoresData.forEach((level, data) {
            int levelNum = int.tryParse(level) ?? 0;
            int scoreValue = data['score'] ?? 0;
            bool completed = data['completed'] ?? false;

            if (levelNum > 0 && levelNum <= 30) {
              easyScores[levelNum] = {
                'score': scoreValue,
                'completed': completed
              };
            }
          });
        }

        // Process Medium scores
        mediumScores = {};
        if (mediumResponse['success'] == true && mediumResponse['scores'] != null) {
          Map<String, dynamic> scoresData = mediumResponse['scores'];
          scoresData.forEach((level, data) {
            int levelNum = int.tryParse(level) ?? 0;
            int scoreValue = data['score'] ?? 0;
            bool completed = data['completed'] ?? false;

            if (levelNum > 0 && levelNum <= 30) {
              mediumScores[levelNum] = {
                'score': scoreValue,
                'completed': completed
              };
            }
          });
        }

        // Process Hard scores
        hardScores = {};
        if (hardResponse['success'] == true && hardResponse['scores'] != null) {
          Map<String, dynamic> scoresData = hardResponse['scores'];
          scoresData.forEach((level, data) {
            int levelNum = int.tryParse(level) ?? 0;
            int scoreValue = data['score'] ?? 0;
            bool completed = data['completed'] ?? false;

            if (levelNum > 0 && levelNum <= 30) {
              hardScores[levelNum] = {
                'score': scoreValue,
                'completed': completed
              };
            }
          });
        }

        _isLoading = false;
      });

      print('✅ LOADED SCORES - Easy: ${easyScores.length}, Medium: ${mediumScores.length}, Hard: ${hardScores.length}');

    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading scores: $e');
    }
  }

  void _navigateToLevelSelection(String difficulty) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('click.mp3');

    Navigator.pushNamed(
      context,
      '/levels',
      arguments: {
        'language': selectedLanguage,
        'difficulty': difficulty,
      },
    ).then((_) {
      // Reload scores when returning
      if (currentUser?['id'] != null) {
        _loadAllDifficultyScores(currentUser!['id']);
      }
    });
  }

  Map<String, dynamic> _getDifficultyProgress(int difficultyIndex) {
    String difficultyName = _difficulties[difficultyIndex]['name'];
    int multiplier = _difficulties[difficultyIndex]['multiplier'];

    Map<int, Map<String, dynamic>> currentScores;

    switch (difficultyName) {
      case 'Easy':
        currentScores = easyScores;
        break;
      case 'Medium':
        currentScores = mediumScores;
        break;
      case 'Hard':
        currentScores = hardScores;
        break;
      default:
        currentScores = {};
    }

    int completed = 0;
    int totalScore = 0;
    int maxPossibleScore = 10 * 3 * multiplier;

    for (int level = 1; level <= 10; level++) {
      final levelData = currentScores[level];
      if (levelData != null) {
        int score = levelData['score'] ?? 0;
        bool isCompleted = levelData['completed'] ?? false;

        if (isCompleted) completed++;
        totalScore += score * multiplier;
      }
    }

    double progress = completed / 10;
    int percentage = (progress * 100).toInt();

    return {
      'completed': completed,
      'totalScore': totalScore,
      'progress': progress,
      'percentage': percentage,
      'maxPossibleScore': maxPossibleScore,
      'startLevel': 1,
      'multiplier': multiplier,
    };
  }

  Widget _buildDifficultyCard(int index) {
    final difficulty = _difficulties[index];
    final progress = _getDifficultyProgress(index);
    final bool isUnlocked = true;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            difficulty['color'].withOpacity(0.7),
            difficulty['color'].withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: difficulty['color'].withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: difficulty['color'].withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToLevelSelection(difficulty['name']),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        difficulty['icon'],
                        color: difficulty['color'],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty['name'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            difficulty['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Points Multiplier
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: difficulty['color'].withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: difficulty['color'].withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '${difficulty['multiplier']}× POINTS MULTIPLIER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: difficulty['color'],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Progress Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${progress['completed']}/10 Levels',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * progress['progress'],
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  difficulty['color'],
                                  difficulty['color'].withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Score and Percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: ${progress['totalScore']}/${progress['maxPossibleScore']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${progress['percentage']}% Complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: difficulty['color'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Play Button
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(
                      'PLAY ${difficulty['name'].toUpperCase()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => _navigateToLevelSelection(difficulty['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: difficulty['color'],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: difficulty['color'].withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          '$selectedLanguage - SELECT DIFFICULTY',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1B263B),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.tealAccent),
      ),
      body: Container(
        decoration: const BoxDecoration(
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
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.tealAccent, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHOOSE YOUR CHALLENGE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Difficulty Cards
            Expanded(
              child: ListView.builder(
                itemCount: _difficulties.length,
                itemBuilder: (context, index) {
                  return _buildDifficultyCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
