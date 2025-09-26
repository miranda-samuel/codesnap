import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> leaderboardData = [];
  Map<String, dynamic>? currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await UserPreferences.getUser();
      setState(() => currentUser = user);

      // Load user points
      if (user['id'] != null) {
        await _loadUserPoints(user['id']!);
      }

      final response = await ApiService.getLeaderboard();
      print('Leaderboard response: $response');

      if (response['success'] == true) {
        if (response['leaderboard'] != null && response['leaderboard'] is List) {
          final rawData = List<Map<String, dynamic>>.from(response['leaderboard']);

          final filteredData = rawData.where((user) {
            final points = (user['points'] as num?)?.toInt() ?? 0;
            return points > 0;
          }).toList();

          setState(() {
            leaderboardData = filteredData;
            _errorMessage = '';
          });
        } else {
          setState(() {
            leaderboardData = [];
            _errorMessage = 'Invalid leaderboard data format';
          });
        }
      } else {
        setState(() {
          leaderboardData = [];
          _errorMessage = response['message'] ?? 'Failed to load leaderboard';
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        leaderboardData = [];
        _errorMessage = 'Connection error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPoints(int userId) async {
    try {
      final response = await ApiService.getUserStats(userId);
      if (response['success'] == true && response['stats'] != null) {
        final stats = response['stats'];
        final totalPoints = (stats['totalPoints'] as num?)?.toInt() ?? 0;
        setState(() {
          _userPoints = totalPoints;
        });
      }
    } catch (e) {
      print('Error loading user points: $e');
    }
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await UserPreferences.clearUser();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.teal;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.star;
      default:
        return Icons.person;
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.tealAccent.shade400,
      child: Center(
        child: Text(
          currentUser?['fullName']?.toString().substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'Profile':
        Navigator.pushNamed(context, '/profile');
        break;
      case 'PointsInfo':
        _showPointsInfo(context);
        break;
      case 'Settings':
      // Navigator.pushNamed(context, '/settings');
        break;
      case 'Logout':
        _logout(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Profile',
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Profile: ${currentUser?['username'] ?? 'Guest'}'),
                ),
              ),
              const PopupMenuItem(
                value: 'PointsInfo',
                child: ListTile(
                  leading: Icon(Icons.emoji_events),
                  title: Text('Points System'),
                ),
              ),
              const PopupMenuItem(
                value: 'Settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'Logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),

            // App Name
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Code',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  TextSpan(
                    text: 'S',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent.shade400,
                      fontFamily: 'monospace',
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.tealAccent.withOpacity(0.6),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: 'nap',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile View Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: currentUser?['profile_photo'] != null
                          ? Image.network(
                        currentUser!['profile_photo'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?['fullName'] ?? 'Guest User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${currentUser?['username'] ?? 'guest'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_userPoints Points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.tealAccent.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Start Coding Button
            ElevatedButton.icon(
              icon: const Icon(Icons.code),
              label: const Text('Start Coding', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.pushNamed(context, '/select_language').then((_) {
                  _loadData();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 30),

            // Leaderboard Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.leaderboard, color: Colors.amberAccent),
                  SizedBox(width: 10),
                  Text(
                    'Top Coders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _buildLeaderboardContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Error loading leaderboard',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (leaderboardData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 60, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No active players yet',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to play and earn points!',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      backgroundColor: Colors.teal,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          final user = leaderboardData[index];
          final rank = index + 1;
          final isCurrentUser = currentUser?['username'] == user['username'];

          final username = user['username']?.toString() ?? 'Unknown';
          final points = (user['points'] as num?)?.toInt() ?? 0;
          final levelsCompleted = (user['levels_completed'] as num?)?.toInt() ?? 0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Colors.teal.withOpacity(0.3)
                  : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: isCurrentUser
                  ? Border.all(color: Colors.tealAccent, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isCurrentUser ? Colors.tealAccent : Colors.black,
                            ),
                          ),
                          if (isCurrentUser)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.person, size: 16, color: Colors.teal),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '$levelsCompleted levels completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(_getRankIcon(rank), size: 18, color: _getRankColor(rank)),
                        const SizedBox(width: 4),
                        Text(
                          '$points pts',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rank: $rank',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPointsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 10),
            Text("🏆 Points System"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Each score point = 10 leaderboard points:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildPointsRow("Score 1/3", "10 points"),
            _buildPointsRow("Score 2/3", "20 points"),
            _buildPointsRow("Score 3/3", "30 points"),
            SizedBox(height: 10),
            Text("💡 Tip: Get perfect scores to climb the leaderboard faster!"),
            SizedBox(height: 10),
            Text("Note: Only players with points are shown on the leaderboard."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it!"),
          )
        ],
      ),
    );
  }

  Widget _buildPointsRow(String score, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.arrow_forward, size: 16, color: Colors.teal),
          SizedBox(width: 8),
          Text(score, style: TextStyle(fontWeight: FontWeight.w500)),
          Spacer(),
          Text(points, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}