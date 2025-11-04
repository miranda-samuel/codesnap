import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/user_preferences.dart';
import '../services/music_service.dart';
import 'profile_screen.dart';
import 'training_mode_screen.dart';

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

  // Season management - PERSISTENT ACROSS LOGINS
  int _currentSeason = 1;
  DateTime? _seasonStartDate;
  DateTime? _seasonEndDate;
  Timer? _seasonTimer;
  int _secondsRemaining = 86400; // 24 hours in seconds
  bool _isSeasonEnding = false;

  // Search functionality
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allUsers = [];
  bool _searchLoading = false;

  // Programming languages data
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
    _setupSearchListener();
    _loadAllUsers();
  }

  @override
  void dispose() {
    _seasonTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Season initialization - PERSISTENT ACROSS ALL USERS
  void _initializeSeason() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we have existing season data (GLOBAL - not user specific)
    final savedSeason = prefs.getInt('global_currentSeason');
    final savedStartDate = prefs.getString('global_seasonStartDate');
    final savedEndDate = prefs.getString('global_seasonEndDate');
    final savedSecondsRemaining = prefs.getInt('global_secondsRemaining');

    if (savedSeason != null && savedStartDate != null && savedEndDate != null) {
      // Continue existing GLOBAL season from saved data
      _currentSeason = savedSeason;
      _seasonStartDate = DateTime.parse(savedStartDate);
      _seasonEndDate = DateTime.parse(savedEndDate);

      final now = DateTime.now();

      if (now.isBefore(_seasonEndDate!)) {
        // Season is still ongoing - calculate remaining time
        _secondsRemaining = _seasonEndDate!.difference(now).inSeconds;
        print('Continuing GLOBAL season $_currentSeason');
        print('Season ends in: ${_formatTime(_secondsRemaining)}');
      } else {
        // Season has ended - automatically start new season
        print('GLOBAL Season $_currentSeason has ended. Starting season ${_currentSeason + 1}...');
        await _resetSeasonAutomatically();
        return;
      }
    } else {
      // No saved season - START FROM SEASON 1 (FIRST TIME APP LAUNCH)
      print('Starting fresh GLOBAL Season 1...');
      _currentSeason = 1;
      await _startNewSeason(prefs);
    }

    // Start timer after initialization
    _startSeasonTimer();
  }

  // Automatic season reset - CONTINUES FOR ALL USERS
  Future<void> _resetSeasonAutomatically() async {
    try {
      print('Automatically resetting GLOBAL season $_currentSeason...');

      final response = await ApiService.resetSeasonScores(_currentSeason);
      final prefs = await SharedPreferences.getInstance();

      // Increment season for continuation
      setState(() {
        _currentSeason++;
      });

      // Start new season
      await _startNewSeason(prefs);

      // Reload leaderboard data
      _loadLeaderboardData();

      print('Automatically started GLOBAL season $_currentSeason');

    } catch (e) {
      print('Error in automatic season reset: $e');
      // Fallback: start new season anyway
      final prefs = await SharedPreferences.getInstance();
      await _startNewSeason(prefs);
    }
  }

  // Start new season with proper saving - GLOBAL
  Future<void> _startNewSeason(SharedPreferences prefs) async {
    final now = DateTime.now();
    _seasonStartDate = now;
    _seasonEndDate = now.add(const Duration(days: 1)); // 24 hours
    _secondsRemaining = 86400;

    // Save to shared preferences as GLOBAL data
    await prefs.setInt('global_currentSeason', _currentSeason);
    await prefs.setString('global_seasonStartDate', _seasonStartDate!.toIso8601String());
    await prefs.setString('global_seasonEndDate', _seasonEndDate!.toIso8601String());
    await prefs.setInt('global_secondsRemaining', _secondsRemaining);

    print('Started GLOBAL season $_currentSeason');
    print('Season ends at: $_seasonEndDate');

    if (mounted) {
      setState(() {});
    }
  }

  // Season timer that handles automatic continuation - GLOBAL
  void _startSeasonTimer() {
    _seasonTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;

            // Show warning when 10 minutes remaining
            if (_secondsRemaining == 600 && !_isSeasonEnding) {
              _isSeasonEnding = true;
              _showSeasonEndingWarning();
            }

            // Save progress every minute
            if (_secondsRemaining % 60 == 0) {
              _saveSeasonProgress();
            }
          } else {
            // Season ended - reset automatically
            timer.cancel();
            _resetSeasonAutomatically();
          }
        });
      }
    });
  }

  // Show season ending warning
  void _showSeasonEndingWarning() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(child: Text('Season $_currentSeason ending in 10 minutes!')),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // Save season progress - GLOBAL
  Future<void> _saveSeasonProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('global_secondsRemaining', _secondsRemaining);
  }

  void _startShiningAnimation() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTop1Shining = !_isTop1Shining;
        });
        _startShiningAnimation();
      }
    });
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.length >= 2) {
        _searchUsers(query);
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    });
  }

  Future<void> _loadAllUsers() async {
    try {
      print('Loading all users from database...');
      final response = await ApiService.getAllUsers();
      print('Load All Users Response: $response');

      if (response['success'] == true && response['users'] != null) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(response['users']);
        });
        print('Successfully loaded ${_allUsers.length} users from database');
      } else {
        print('Failed to load users: ${response['message']}');
        _loadUsersFallback();
      }
    } catch (e) {
      print('Error loading all users: $e');
      _loadUsersFallback();
    }
  }

  Future<void> _loadUsersFallback() async {
    try {
      print('Trying fallback method to load users...');
      final response = await ApiService.getLeaderboard();
      if (response['success'] == true && response['leaderboard'] != null) {
        final leaderboard = List<Map<String, dynamic>>.from(response['leaderboard']);
        final users = leaderboard.map((user) {
          return {
            'id': user['user_id'] ?? 0,
            'username': user['username'] ?? 'unknown',
            'full_name': user['full_name'] ?? 'Unknown User'
          };
        }).toList();

        setState(() {
          _allUsers = users;
        });
        print('Fallback loaded ${_allUsers.length} users from leaderboard');
      }
    } catch (e) {
      print('Fallback also failed: $e');
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchLoading = false;
      });
      return;
    }

    setState(() {
      _searchLoading = true;
    });

    try {
      print('Searching for: $query');
      final response = await ApiService.searchUsers(query);
      print('API Search Response: $response');

      if (response['success'] == true && response['users'] != null) {
        final apiResults = List<Map<String, dynamic>>.from(response['users']);
        setState(() {
          _searchResults = apiResults;
          _searchLoading = false;
        });
        return;
      }

      print('API search failed, using local search...');
      final filteredUsers = _allUsers.where((user) {
        final username = user['username']?.toString().toLowerCase() ?? '';
        final fullName = user['full_name']?.toString().toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();

        return username.contains(searchTerm) || fullName.contains(searchTerm);
      }).toList();

      setState(() {
        _searchResults = filteredUsers;
        _searchLoading = false;
      });

    } catch (e) {
      print('Error searching users: $e');
      final filteredUsers = _allUsers.where((user) {
        final username = user['username']?.toString().toLowerCase() ?? '';
        final fullName = user['full_name']?.toString().toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();

        return username.contains(searchTerm) || fullName.contains(searchTerm);
      }).toList();

      setState(() {
        _searchResults = filteredUsers;
        _searchLoading = false;
      });
    }
  }

  void _exitSearchMode() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
      _searchLoading = false;
    });
  }

  void _viewUserProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
        settings: RouteSettings(arguments: {
          'id': user['id'],
          'username': user['username'],
          'full_name': user['full_name'] ?? user['fullName'],
        }),
      ),
    ).then((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await UserPreferences.getUser();
      if (!mounted) return;

      setState(() => currentUser = user);

      if (user['id'] != null) {
        await _loadUserPoints(_getInt(user['id']));
      }

      final response = await ApiService.getLeaderboard();

      if (!mounted) return;

      if (response['success'] == true) {
        if (response['leaderboard'] != null && response['leaderboard'] is List) {
          final rawData = List<Map<String, dynamic>>.from(response['leaderboard']);

          final filteredData = rawData.where((user) {
            final points = _getInt(user['points']);
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
          _errorMessage = _getString(response['message']) ?? 'Failed to load leaderboard';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          leaderboardData = [];
          _errorMessage = 'Connection error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserPoints(int userId) async {
    try {
      final response = await ApiService.getUserStats(userId);
      if (response['success'] == true && response['stats'] != null && mounted) {
        final stats = response['stats'];
        final totalPoints = _getInt(stats['totalPoints']);
        setState(() {
          _userPoints = totalPoints;
        });
      }
    } catch (e) {
      print('Error loading user points: $e');
    }
  }

  Future<void> _loadLeaderboardData() async {
    if (!mounted) return;

    try {
      final response = await ApiService.getLeaderboard();

      if (!mounted) return;

      if (response['success'] == true) {
        if (response['leaderboard'] != null && response['leaderboard'] is List) {
          final rawData = List<Map<String, dynamic>>.from(response['leaderboard']);

          final filteredData = rawData.where((user) {
            final points = _getInt(user['points']);
            return points > 0;
          }).toList();

          setState(() {
            leaderboardData = filteredData;
          });
        } else {
          setState(() {
            leaderboardData = [];
          });
        }
      } else {
        setState(() {
          leaderboardData = [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          leaderboardData = [];
        });
      }
    }
  }

  String _formatTime(int seconds) {
    int days = seconds ~/ 86400;
    int hours = (seconds % 86400) ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
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
          _getString(currentUser?['fullName']).substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
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
      case 'TrainingMode':
        Navigator.pushNamed(context, '/training_mode');
        break;
      case 'Logout':
        _logout(context);
        break;
    }
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
            ),
            TextButton(
              onPressed: () async {
                // IMPORTANT: Season continues even after logout
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

  Widget _buildUserCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B263B).withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.tealAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _getString(currentUser?['profile_photo']).isNotEmpty
                      ? Image.network(
                    _getString(currentUser?['profile_photo']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getString(currentUser?['fullName']),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.open_in_new, size: 14, color: Colors.tealAccent.withOpacity(0.7)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '@${_getString(currentUser?['username'])}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$_userPoints Points',
                        style: TextStyle(
                          fontSize: 11,
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
    );
  }

  Widget _buildTop10Card(Map<String, dynamic> user, int rank) {
    final username = _getString(user['username']);
    final points = _getInt(user['points']);
    final isCurrentUser = _getString(currentUser?['username']) == _getString(user['username']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
            const Color(0xFF415A77).withOpacity(0.8),
            const Color(0xFF1B263B).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3 ? _getRankColor(rank) : (isCurrentUser ? Colors.tealAccent : Colors.tealAccent.withOpacity(0.3)),
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: rank == 1
            ? [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: _isTop1Shining ? 15 : 12,
            spreadRadius: _isTop1Shining ? 2 : 1,
            offset: const Offset(0, 3),
          ),
        ]
            : rank <= 3
            ? [
          BoxShadow(
            color: _getRankColor(rank).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
              border: rank <= 3 ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rank <= 3 ? 16 : 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

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
                          fontSize: rank <= 3 ? 16 : 14,
                          fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.person, size: 14, color: Colors.tealAccent),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Season $_currentSeason',
                  style: TextStyle(
                    fontSize: 10,
                    color: rank <= 3 ? Colors.white.withOpacity(0.9) : Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(_getRankIcon(rank), size: rank <= 3 ? 16 : 14, color: rank <= 3 ? Colors.white : _getRankColor(rank)),
                  const SizedBox(width: 4),
                  Text(
                    '$points pts',
                    style: TextStyle(
                      fontSize: rank <= 3 ? 16 : 14,
                      color: rank <= 3 ? Colors.white : Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Rank: $rank',
                style: TextStyle(
                  fontSize: 10,
                  color: rank <= 3 ? Colors.white.withOpacity(0.9) : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTop10Season() {
    final usersWithPoints = leaderboardData.where((user) {
      final points = _getInt(user['points']);
      return points > 0;
    }).toList();

    final top10 = usersWithPoints.take(10).toList();

    if (top10.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.leaderboard_outlined, size: 40, color: Colors.tealAccent.withOpacity(0.5)),
            const SizedBox(height: 8),
            const Text(
              'No Top Coders Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Play games to earn points and appear on the leaderboard!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.tealAccent, size: 22),
                const SizedBox(width: 6),
                const Text(
                  'Top 10 Coders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: top10.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              final rank = index + 1;
              return _buildTop10Card(user, rank);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgrammingModulesButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.language, color: Colors.white, size: 22),
        label: const Text(
          'Programming Modules',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _showProgrammingModulesDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          shadowColor: Colors.tealAccent.withOpacity(0.5),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildTrainingModeButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.school, color: Colors.white, size: 22),
        label: const Text(
          'Training Mode',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/training_mode');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          shadowColor: Colors.tealAccent.withOpacity(0.5),
          elevation: 6,
        ),
      ),
    );
  }

  void _showProgrammingModulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.tealAccent, width: 2),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.tealAccent, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Programming Modules',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _programmingLanguages.length,
                    itemBuilder: (context, index) {
                      final language = _programmingLanguages[index];
                      return Card(
                        elevation: 4,
                        color: const Color(0xFF1B263B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.tealAccent.withOpacity(0.3), width: 1),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, _getString(language['route']));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (language['color'] as Color).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    language['icon'] as IconData,
                                    color: language['color'] as Color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getString(language['name']),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getString(language['description']),
                                  style: const TextStyle(
                                    fontSize: 10,
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
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Close', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FIXED: Add back the missing leaderboard dialog method
  void _showLeaderboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.tealAccent, width: 2),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.leaderboard, color: Colors.tealAccent, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Coders - Season $_currentSeason',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Top Players: ${leaderboardData.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.tealAccent.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<int>(
                        stream: Stream.periodic(const Duration(seconds: 1), (i) => _secondsRemaining - i),
                        initialData: _secondsRemaining,
                        builder: (context, snapshot) {
                          final remaining = snapshot.data ?? _secondsRemaining;
                          return Text(
                            'Time: ${_formatTime(remaining)}',
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                      Text(
                        'Season $_currentSeason',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildLeaderboardDialogContent(),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Close', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FIXED: Add back the missing leaderboard dialog content method
  Widget _buildLeaderboardDialogContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.tealAccent.withOpacity(0.5)),
              const SizedBox(height: 12),
              const Text(
                'Error loading leaderboard',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    final usersWithPoints = leaderboardData.where((user) {
      final points = _getInt(user['points']);
      return points > 0;
    }).toList();

    if (usersWithPoints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.leaderboard_outlined, size: 40, color: Colors.tealAccent.withOpacity(0.5)),
              const SizedBox(height: 12),
              const Text(
                'No active players yet',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                'Play games to earn points and appear on the leaderboard!',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      );
    }

    final top100 = usersWithPoints.take(100).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: top100.length,
      itemBuilder: (context, index) {
        final user = top100[index];
        final rank = index + 1;
        return _buildLeaderboardDialogItem(user, rank);
      },
    );
  }

  // FIXED: Add back the missing leaderboard dialog item method
  Widget _buildLeaderboardDialogItem(Map<String, dynamic> user, int rank) {
    final username = _getString(user['username']);
    final points = _getInt(user['points']);
    final levelsCompleted = _getInt(user['levels_completed']);
    final isCurrentUser = _getString(currentUser?['username']) == _getString(user['username']);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF415A77).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser ? Colors.tealAccent : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username.length > 12 ? '${username.substring(0, 12)}...' : username,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser ? Colors.tealAccent : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.person, size: 10, color: Colors.tealAccent),
                      ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '$levelsCompleted levels',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(_getRankIcon(rank), size: 10, color: _getRankColor(rank)),
                  const SizedBox(width: 2),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' pts',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'Rank $rank',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATED: Points info dialog
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
            Text("Season Reset: Every 24 hours", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Current Season: $_currentSeason", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_down, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "50% leaderboard points reduction each season",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Level progress and scores are preserved!",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text("🏅 Top 3 players earn special badges each season!", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("✅ Your level unlocks and completions are safe!", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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
      padding: EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
            onPressed: _exitSearchMode,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users by username or name...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade800,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.tealAccent),
            onPressed: () {
              _searchController.clear();
              _searchResults.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Search for Users',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Type username or full name to find other players',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No users found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No users found for "${_searchController.text}"',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final isCurrentUser = currentUser?['username'] == user['username'];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.tealAccent.withOpacity(0.3)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text(
                user['full_name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
            title: Text(
              user['full_name'] ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              '@${user['username'] ?? 'unknown'}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            onTap: () {
              if (!isCurrentUser) {
                _viewUserProfile({
                  'id': user['id'],
                  'username': user['username'],
                  'full_name': user['full_name'],
                });
              } else {
                _exitSearchMode();
              }
            },
          ),
        );
      },
    );
  }

  String _getString(dynamic value) {
    if (value == null) return 'Unknown';
    return value.toString();
  }

  int _getInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
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
          IconButton(
            icon: const Icon(Icons.search, color: Colors.tealAccent),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _searchFocusNode.requestFocus();
              });
            },
            tooltip: 'Search Users',
          ),
          // FIXED: This button should show leaderboard dialog, not points info
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.tealAccent),
            onPressed: () => _showLeaderboardDialog(context),
            tooltip: 'View Top Leaderboard',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.tealAccent, size: 24),
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Profile',
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.black87),
                  title: Text(
                    'Profile: ${_getString(currentUser?['username'])}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'PointsInfo',
                child: const ListTile(
                  leading: Icon(Icons.emoji_events, color: Colors.black87),
                  title: Text('Points System', style: TextStyle(color: Colors.black87)),
                ),
              ),
              PopupMenuItem(
                value: 'Settings',
                child: const ListTile(
                  leading: Icon(Icons.settings, color: Colors.black87),
                  title: Text('Settings', style: TextStyle(color: Colors.black87)),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'Logout',
                child: const ListTile(
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
          child: _isSearching
              ? Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildSearchResults()),
            ],
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildUserCard(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.code, color: Colors.white, size: 20),
                  label: const Text('Start Coding', style: TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/select_language').then((_) {
                      _loadData();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    shadowColor: Colors.tealAccent.withOpacity(0.5),
                    elevation: 6,
                  ),
                ),
                _buildTrainingModeButton(),
                _buildProgrammingModulesButton(),
                const SizedBox(height: 16),
                // FIXED: This will now show the Top 10 Coders section
                _buildTop10Season(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
