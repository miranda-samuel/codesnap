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
  bool _isTop1Shining = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Start animation for top 1 shining effect
    _startShiningAnimation();
  }

  void _startShiningAnimation() {
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTop1Shining = !_isTop1Shining;
        });
        _startShiningAnimation();
      }
    });
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
          backgroundColor: Color(0xFF1B263B),
          title: Text('Logout', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
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
              child: Text('Logout', style: TextStyle(color: Colors.red)),
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
        return Color(0xFFC0C0C0); // Silver
      case 3:
        return Color(0xFFCD7F32); // Bronze
      default:
        return Colors.tealAccent;
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
      color: Colors.tealAccent,
      child: Center(
        child: Text(
          currentUser?['fullName']?.toString().substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
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
        Navigator.pushNamed(context, '/settings'); // ENABLE THIS LINE
        break;
      case 'Logout':
        _logout(context);
        break;
    }
  }

  void _navigateToUserProfile(Map<String, dynamic> user) {
    // Navigate to profile page with user data
    Navigator.pushNamed(context, '/user_profile', arguments: user);
  }

  Widget _buildTopCoderBox(Map<String, dynamic> user, int rank) {
    final username = user['username']?.toString() ?? 'Unknown';
    final points = (user['points'] as num?)?.toInt() ?? 0;
    final levelsCompleted = (user['levels_completed'] as num?)?.toInt() ?? 0;
    final isCurrentUser = currentUser?['username'] == user['username'];

    return GestureDetector(
      onTap: () => _navigateToUserProfile(user),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: rank == 1
              ? LinearGradient(
            colors: _isTop1Shining
                ? [Colors.amber.shade300, Colors.orange.shade200, Colors.amber.shade300]
                : [Colors.amber.shade400, Colors.orange.shade300, Colors.amber.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              Color(0xFF415A77).withOpacity(0.8),
              Color(0xFF1B263B).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rank == 1
                ? Colors.amber
                : (isCurrentUser ? Colors.tealAccent : Colors.tealAccent.withOpacity(0.3)),
            width: rank == 1 ? 3 : 2,
          ),
          boxShadow: rank == 1
              ? [
            BoxShadow(
              color: Colors.amber.withOpacity(0.6),
              blurRadius: _isTop1Shining ? 20 : 15,
              spreadRadius: _isTop1Shining ? 3 : 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.tealAccent.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank Badge with special design for top 3
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
                border: rank == 1 ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: rank == 1
                    ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
                    : [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: rank == 1 ? 20 : 16,
                        shadows: rank == 1
                            ? [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.orange.shade800,
                          )
                        ]
                            : null,
                      ),
                    ),
                  ),
                  if (rank == 1)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
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
                          fontSize: rank == 1 ? 20 : 18,
                          fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
                          color: rank == 1
                              ? Colors.white
                              : (isCurrentUser ? Colors.tealAccent : Colors.white),
                          shadows: rank == 1
                              ? [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.orange.shade800,
                            )
                          ]
                              : null,
                        ),
                      ),
                      if (isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.person, size: 16, color: rank == 1 ? Colors.white : Colors.tealAccent),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: rank == 1 ? Colors.white : Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '$levelsCompleted levels completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: rank == 1 ? Colors.white.withOpacity(0.9) : Colors.white70,
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
                    Icon(
                        _getRankIcon(rank),
                        size: rank == 1 ? 22 : 18,
                        color: rank == 1 ? Colors.white : _getRankColor(rank)
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$points pts',
                      style: TextStyle(
                        fontSize: rank == 1 ? 18 : 16,
                        color: rank == 1 ? Colors.white : Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        shadows: rank == 1
                            ? [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.orange.shade800,
                          )
                        ]
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rank: $rank',
                  style: TextStyle(
                    fontSize: 12,
                    color: rank == 1 ? Colors.white.withOpacity(0.9) : Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.tealAccent, size: 24),
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Profile',
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.tealAccent),
                  title: Text('Profile: ${currentUser?['username'] ?? 'Guest'}'),
                ),
              ),
              PopupMenuItem(
                value: 'PointsInfo',
                child: ListTile(
                  leading: Icon(Icons.emoji_events, color: Colors.tealAccent),
                  title: Text('Points System'),
                ),
              ),
              PopupMenuItem(
                value: 'Settings',
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.tealAccent),
                  title: Text('Settings'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // App Name
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    TextSpan(
                      text: 'S',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile View Section - Now Clickable
              GestureDetector(
                onTap: () {
                  if (currentUser != null) {
                    _navigateToUserProfile(currentUser!);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B263B).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.tealAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
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
                            Row(
                              children: [
                                Text(
                                  currentUser?['fullName'] ?? 'Guest User',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.open_in_new, size: 16, color: Colors.tealAccent),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${currentUser?['username'] ?? 'guest'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                              ),
                              child: Text(
                                '$_userPoints Points',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.tealAccent,
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
              ),
              const SizedBox(height: 25),

              // Start Coding Button
              ElevatedButton.icon(
                icon: Icon(Icons.code, color: Colors.white),
                label: Text('Start Coding', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () {
                  Navigator.pushNamed(context, '/select_language').then((_) {
                    _loadData();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  shadowColor: Colors.tealAccent.withOpacity(0.5),
                  elevation: 8,
                ),
              ),
              const SizedBox(height: 30),

              // Leaderboard Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.leaderboard, color: Colors.tealAccent, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Top Coders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                        fontFamily: 'monospace',
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.tealAccent.withOpacity(0.3),
                          ),
                        ],
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
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.tealAccent));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.tealAccent.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Error loading leaderboard',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.white,
              ),
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
            Icon(Icons.leaderboard_outlined, size: 60, color: Colors.tealAccent.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No active players yet',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to play and earn points!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      backgroundColor: Colors.tealAccent,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          final user = leaderboardData[index];
          final rank = index + 1;
          return _buildTopCoderBox(user, rank);
        },
      ),
    );
  }

  void _showPointsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1B263B),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.tealAccent),
            SizedBox(width: 10),
            Text("🏆 Points System", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Each score point = 10 leaderboard points:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            _buildPointsRow("Score 1/3", "10 points"),
            _buildPointsRow("Score 2/3", "20 points"),
            _buildPointsRow("Score 3/3", "30 points"),
            SizedBox(height: 10),
            Text("💡 Tip: Get perfect scores to climb the leaderboard faster!", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text("Note: Only players with points are shown on the leaderboard.", style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it!", style: TextStyle(color: Colors.tealAccent)),
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
          Icon(Icons.arrow_forward, size: 16, color: Colors.tealAccent),
          SizedBox(width: 8),
          Text(score, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
          Spacer(),
          Text(points, style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}