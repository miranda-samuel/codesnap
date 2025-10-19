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
  int _currentSeason = 1;
  DateTime? _seasonStartDate;
  DateTime? _seasonEndDate;

  // Programming languages data with correct icons
  final List<Map<String, dynamic>> _programmingLanguages = [
    {
      'name': 'PHP',
      'icon': Icons.developer_mode,
      'color': Colors.purple,
      'description': 'Server-side scripting language',
      'route': '/php_modules',
    },
    {
      'name': 'C++',
      'icon': Icons.memory,
      'color': Colors.blue,
      'description': 'High-performance programming',
      'route': '/cpp_modules',
    },
    {
      'name': 'Python',
      'icon': Icons.terminal,
      'color': Colors.yellow,
      'description': 'Easy to learn programming',
      'route': '/python_modules',
    },
    {
      'name': 'Java',
      'icon': Icons.coffee,
      'color': Colors.orange,
      'description': 'Object-oriented programming',
      'route': '/java_modules',
    },
    {
      'name': 'SQL',
      'icon': Icons.storage,
      'color': Colors.green,
      'description': 'Database management',
      'route': '/sql_modules',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeSeason();
    _loadData();
    _startShiningAnimation();
  }

  // NEW METHOD: Initialize season dates
  void _initializeSeason() {
    final now = DateTime.now();
    _seasonStartDate = now;
    _seasonEndDate = now.add(Duration(days: 60)); // 60 days season
  }

  // NEW METHOD: Check if season should reset
  Future<void> _checkSeasonReset() async {
    final now = DateTime.now();
    if (_seasonEndDate != null && now.isAfter(_seasonEndDate!)) {
      // Reset season
      await _resetSeason();
    }
  }

  // NEW METHOD: Reset season scores
  Future<void> _resetSeason() async {
    try {
      final response = await ApiService.resetSeasonScores();
      if (response['success'] == true) {
        setState(() {
          _currentSeason++;
          _seasonStartDate = DateTime.now();
          _seasonEndDate = DateTime.now().add(Duration(days: 60));
        });
        _loadData(); // Reload data after reset
      }
    } catch (e) {
      print('Error resetting season: $e');
    }
  }

  // NEW METHOD: Get days remaining in current season
  int get _daysRemaining {
    if (_seasonEndDate == null) return 0;
    final now = DateTime.now();
    final difference = _seasonEndDate!.difference(now);
    return difference.inDays.clamp(0, 60);
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
      await _checkSeasonReset(); // Check for season reset first

      final user = await UserPreferences.getUser();
      setState(() => currentUser = user);

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
        return Color(0xFFC0C0C0);
      case 3:
        return Color(0xFFCD7F32);
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
        Navigator.pushNamed(context, '/settings');
        break;
      case 'Logout':
        _logout(context);
        break;
    }
  }

  void _navigateToUserProfile(Map<String, dynamic> user) {
    Navigator.pushNamed(context, '/user_profile', arguments: user);
  }

  // UPDATED METHOD: Show Leaderboard Dialog - Fixed overflow
  void _showLeaderboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.tealAccent, width: 2),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95, // Added width constraint
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75, // Reduced max height
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header - Made more compact
                Container(
                  padding: EdgeInsets.all(16), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.leaderboard, color: Colors.tealAccent, size: 24), // Smaller icon
                      SizedBox(width: 10), // Reduced spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top 10 Coders - Season $_currentSeason',
                              style: TextStyle(
                                fontSize: 16, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2), // Minimal spacing
                            Text(
                              'Total Players: ${leaderboardData.length}',
                              style: TextStyle(
                                fontSize: 11, // Smaller font size
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Season Info - Made very compact
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Very compact padding
                  color: Colors.tealAccent.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Days: $_daysRemaining',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 12, // Smaller font
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Season $_currentSeason',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11, // Smaller font
                        ),
                      ),
                    ],
                  ),
                ),

                // Leaderboard Content - Made scrollable and compact
                Expanded(
                  child: _buildLeaderboardDialogContent(),
                ),

                // Close Button - Made compact
                Container(
                  padding: EdgeInsets.all(8), // Minimal padding
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Smaller radius
                      ),
                      minimumSize: Size(double.infinity, 45), // Smaller button
                      padding: EdgeInsets.symmetric(vertical: 8), // Compact padding
                    ),
                    child: Text('Close', style: TextStyle(fontSize: 14)), // Smaller font
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// UPDATED METHOD: Build Leaderboard Dialog Content - Fixed overflow
  Widget _buildLeaderboardDialogContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16), // Reduced padding
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to prevent expansion
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.tealAccent.withOpacity(0.5)), // Smaller icon
              SizedBox(height: 12), // Reduced spacing
              Text(
                'Error loading leaderboard',
                style: TextStyle(color: Colors.white, fontSize: 14), // Smaller font
              ),
              SizedBox(height: 6), // Reduced spacing
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.white70, fontSize: 12), // Smaller font
                textAlign: TextAlign.center,
                maxLines: 2, // Limit lines
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    if (leaderboardData.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to prevent expansion
            children: [
              Icon(Icons.leaderboard_outlined, size: 40, color: Colors.tealAccent.withOpacity(0.5)), // Smaller icon
              SizedBox(height: 12), // Reduced spacing
              Text(
                'No active players yet',
                style: TextStyle(color: Colors.white, fontSize: 14), // Smaller font
              ),
              SizedBox(height: 6), // Reduced spacing
              Text(
                'Be the first to play and earn points!',
                style: TextStyle(color: Colors.white70, fontSize: 12), // Smaller font
                textAlign: TextAlign.center,
                maxLines: 2, // Limit lines
              ),
            ],
          ),
        ),
      );
    }

    // Show up to top 10 players only
    final top10 = leaderboardData.take(10).toList();

    return ListView.builder(
      padding: EdgeInsets.all(8), // Minimal padding
      shrinkWrap: true, // Added to prevent expansion
      physics: AlwaysScrollableScrollPhysics(), // Ensure scrolling
      itemCount: top10.length,
      itemBuilder: (context, index) {
        final user = top10[index];
        final rank = index + 1;
        return _buildLeaderboardDialogItem(user, rank);
      },
    );
  }

// UPDATED METHOD: Build Leaderboard Item for Dialog - Made ultra compact
  Widget _buildLeaderboardDialogItem(Map<String, dynamic> user, int rank) {
    final username = user['username']?.toString() ?? 'Unknown';
    final points = (user['points'] as num?)?.toInt() ?? 0;
    final levelsCompleted = (user['levels_completed'] as num?)?.toInt() ?? 0;
    final isCurrentUser = currentUser?['username'] == user['username'];

    return Container(
      margin: EdgeInsets.only(bottom: 4), // Minimal margin
      padding: EdgeInsets.all(8), // Minimal padding
      decoration: BoxDecoration(
        color: Color(0xFF415A77).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8), // Smaller radius
        border: Border.all(
          color: isCurrentUser ? Colors.tealAccent : Colors.transparent,
          width: 1, // Thinner border
        ),
      ),
      child: Row(
        children: [
          // Rank Badge - Made very small
          Container(
            width: 28, // Very small
            height: 28, // Very small
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
                  fontSize: 10, // Very small font
                ),
              ),
            ),
          ),
          SizedBox(width: 8), // Minimal spacing

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username.length > 12 ? '${username.substring(0, 12)}...' : username, // Truncate long names
                        style: TextStyle(
                          fontSize: 12, // Small font
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser ? Colors.tealAccent : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.person, size: 10, color: Colors.tealAccent), // Very small icon
                      ),
                  ],
                ),
                SizedBox(height: 1), // Minimal spacing
                Text(
                  '$levelsCompleted levels',
                  style: TextStyle(
                    fontSize: 9, // Very small font
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(_getRankIcon(rank), size: 10, color: _getRankColor(rank)), // Very small icon
                  SizedBox(width: 2), // Minimal spacing
                  Text(
                    '$points',
                    style: TextStyle(
                      fontSize: 12, // Small font
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' pts',
                    style: TextStyle(
                      fontSize: 10, // Smaller font for "pts"
                      color: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1), // Minimal spacing
              Text(
                'Rank $rank',
                style: TextStyle(
                  fontSize: 9, // Very small font
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATED METHOD: Build Top 3 Season Display - FIXED overflow
  Widget _buildTop3Season() {
    final top3 = leaderboardData.take(3).toList();

    if (top3.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical margin
        padding: EdgeInsets.all(16), // Reduced padding
        decoration: BoxDecoration(
          color: Color(0xFF1B263B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.leaderboard_outlined, size: 40, color: Colors.tealAccent.withOpacity(0.5)), // Reduced icon size
            SizedBox(height: 8), // Reduced spacing
            Text(
              'No Top Coders Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6), // Reduced spacing
            Text(
              'Be the first to earn points this season!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12, // Reduced font size
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Season Header - FIXED: Made more compact
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12), // Reduced bottom padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.tealAccent, size: 22), // Reduced icon size
                    SizedBox(width: 6), // Reduced spacing
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top 3 Coders',
                          style: TextStyle(
                            fontSize: 18, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'Season $_currentSeason',
                          style: TextStyle(
                            fontSize: 12, // Reduced font size
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10), // Reduced border radius
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$_daysRemaining days left',
                    style: TextStyle(
                      fontSize: 11, // Reduced font size
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top 3 Cards - FIXED: Made more compact
          Column(
            children: top3.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              final rank = index + 1;
              return _buildTop3Card(user, rank);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // UPDATED METHOD: Build Top 3 Card - FIXED overflow
  Widget _buildTop3Card(Map<String, dynamic> user, int rank) {
    final username = user['username']?.toString() ?? 'Unknown';
    final points = (user['points'] as num?)?.toInt() ?? 0;
    final isCurrentUser = currentUser?['username'] == user['username'];

    return Container(
      margin: EdgeInsets.only(bottom: 8), // Reduced margin
      padding: EdgeInsets.all(12), // Reduced padding
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
        borderRadius: BorderRadius.circular(14), // Slightly reduced border radius
        border: Border.all(
          color: rank == 1
              ? Colors.amber
              : (isCurrentUser ? Colors.tealAccent : Colors.tealAccent.withOpacity(0.3)),
          width: rank == 1 ? 2 : 1, // Reduced border width
        ),
        boxShadow: rank == 1
            ? [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: _isTop1Shining ? 15 : 12, // Reduced blur radius
            spreadRadius: _isTop1Shining ? 2 : 1, // Reduced spread radius
            offset: const Offset(0, 3), // Reduced offset
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6, // Reduced blur radius
            offset: const Offset(0, 3), // Reduced offset
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge - Made smaller
          Container(
            width: 40, // Reduced size
            height: 40, // Reduced size
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
              border: rank == 1 ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rank == 1 ? 16 : 14, // Reduced font size
                ),
              ),
            ),
          ),
          SizedBox(width: 12), // Reduced spacing

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontSize: rank == 1 ? 16 : 14, // Reduced font size
                          fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
                          color: rank == 1 ? Colors.white : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.person, size: 14, color: rank == 1 ? Colors.white : Colors.tealAccent), // Reduced icon size
                      ),
                  ],
                ),
                SizedBox(height: 2), // Reduced spacing
                Text(
                  'Season $_currentSeason',
                  style: TextStyle(
                    fontSize: 10, // Reduced font size
                    color: rank == 1 ? Colors.white.withOpacity(0.9) : Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(_getRankIcon(rank), size: rank == 1 ? 16 : 14, color: rank == 1 ? Colors.white : _getRankColor(rank)), // Reduced icon size
                  SizedBox(width: 4), // Reduced spacing
                  Text(
                    '$points pts',
                    style: TextStyle(
                      fontSize: rank == 1 ? 16 : 14, // Reduced font size
                      color: rank == 1 ? Colors.white : Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2), // Reduced spacing
              Text(
                'Rank: $rank',
                style: TextStyle(
                  fontSize: 10, // Reduced font size
                  color: rank == 1 ? Colors.white.withOpacity(0.9) : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATED METHOD: Build Programming Modules Button
  Widget _buildProgrammingModulesButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Reduced vertical margin
      child: ElevatedButton.icon(
        icon: Icon(Icons.language, color: Colors.white, size: 22), // Reduced icon size
        label: Text(
          'Programming Modules',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold), // Reduced font size
        ),
        onPressed: () {
          _showProgrammingModulesDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Reduced padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Slightly reduced border radius
          shadowColor: Colors.tealAccent.withOpacity(0.5),
          elevation: 6, // Reduced elevation
        ),
      ),
    );
  }

  // UPDATED METHOD: Show Programming Modules Dialog - FIXED overflow
  void _showProgrammingModulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.tealAccent, width: 2),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7), // Reduced max height
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header - FIXED: Made more compact
                Container(
                  padding: EdgeInsets.all(16), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, color: Colors.tealAccent, size: 24), // Reduced icon size
                      SizedBox(width: 10), // Reduced spacing
                      Text(
                        'Programming Modules',
                        style: TextStyle(
                          fontSize: 18, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Modules Content - FIXED: Made more compact
                Expanded(
                  child: _buildProgrammingModulesDialogContent(),
                ),

                // Close Button - FIXED: Reduced padding
                Container(
                  padding: EdgeInsets.all(12), // Reduced padding
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 48), // Slightly reduced height
                    ),
                    child: Text('Close', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // UPDATED METHOD: Build Programming Modules Dialog Content - FIXED overflow
  Widget _buildProgrammingModulesDialogContent() {
    return GridView.builder(
      padding: EdgeInsets.all(12), // Reduced padding
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10, // Reduced spacing
        mainAxisSpacing: 10, // Reduced spacing
        childAspectRatio: 0.85, // Slightly reduced aspect ratio
      ),
      itemCount: _programmingLanguages.length,
      itemBuilder: (context, index) {
        final language = _programmingLanguages[index];
        return _buildLanguageCard(language);
      },
    );
  }

  // UPDATED METHOD: Build Language Card - FIXED overflow
  Widget _buildLanguageCard(Map<String, dynamic> language) {
    return Card(
      elevation: 4,
      color: Color(0xFF1B263B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Reduced border radius
        side: BorderSide(color: Colors.tealAccent.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(); // Close dialog first
          Navigator.pushNamed(context, language['route']);
        },
        borderRadius: BorderRadius.circular(10), // Reduced border radius
        child: Container(
          padding: EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: language['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  language['icon'],
                  color: language['color'],
                  size: 28, // Reduced icon size
                ),
              ),
              SizedBox(height: 8), // Reduced spacing
              Text(
                language['name'],
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4), // Reduced spacing
              Text(
                language['description'],
                style: TextStyle(
                  fontSize: 10, // Reduced font size
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          'CodeSnap',
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
          // Leaderboard Button - Now shows Top 100
          IconButton(
            icon: Icon(Icons.leaderboard, color: Colors.tealAccent),
            onPressed: () => _showLeaderboardDialog(context),
            tooltip: 'View Top 100 Leaderboard',
          ),
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
          child: SingleChildScrollView( // ADDED: Wrap in SingleChildScrollView to prevent overflow
            child: Column(
              children: [
                const SizedBox(height: 16), // Reduced spacing

                // Profile View Section
                GestureDetector(
                  onTap: () {
                    if (currentUser != null) {
                      _navigateToUserProfile(currentUser!);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20), // Reduced margin
                    padding: const EdgeInsets.all(14), // Reduced padding
                    decoration: BoxDecoration(
                      color: Color(0xFF1B263B).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(14), // Reduced border radius
                      border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6, // Reduced blur radius
                          offset: const Offset(0, 3), // Reduced offset
                        ),
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.1),
                          blurRadius: 8, // Reduced blur radius
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50, // Reduced size
                          height: 50, // Reduced size
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.tealAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4, // Reduced blur radius
                                offset: const Offset(0, 2), // Reduced offset
                              ),
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(0.2),
                                blurRadius: 6, // Reduced blur radius
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
                        const SizedBox(width: 14), // Reduced spacing

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    currentUser?['fullName'] ?? 'Guest User',
                                    style: const TextStyle(
                                      fontSize: 16, // Reduced font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6), // Reduced spacing
                                  Icon(Icons.open_in_new, size: 14, color: Colors.tealAccent), // Reduced icon size
                                ],
                              ),
                              const SizedBox(height: 3), // Reduced spacing
                              Text(
                                '@${currentUser?['username'] ?? 'guest'}',
                                style: TextStyle(
                                  fontSize: 12, // Reduced font size
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 5), // Reduced spacing
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // Reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10), // Reduced border radius
                                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                                ),
                                child: Text(
                                  '$_userPoints Points',
                                  style: TextStyle(
                                    fontSize: 11, // Reduced font size
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
                const SizedBox(height: 20), // Reduced spacing

                // Start Coding Button
                ElevatedButton.icon(
                  icon: Icon(Icons.code, color: Colors.white, size: 20), // Reduced icon size
                  label: Text('Start Coding', style: TextStyle(fontSize: 16, color: Colors.white)), // Reduced font size
                  onPressed: () {
                    Navigator.pushNamed(context, '/select_language').then((_) {
                      _loadData();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), // Reduced padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Reduced border radius
                    shadowColor: Colors.tealAccent.withOpacity(0.5),
                    elevation: 6, // Reduced elevation
                  ),
                ),

                // NEW: Programming Modules Button - Below Start Coding
                _buildProgrammingModulesButton(),

                const SizedBox(height: 16), // Reduced spacing

                // Top 3 Season Section
                _buildTop3Season(),

                const SizedBox(height: 16), // Added bottom spacing
              ],
            ),
          ),
        ),
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
            Text("Season Reset: All scores reset every 60 days", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Current Season: $_currentSeason (${_daysRemaining} days remaining)", style: TextStyle(color: Colors.white70)),
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