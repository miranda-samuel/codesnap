import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? displayedUser;
  Map<String, dynamic> userStats = {};
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allUsers = [];

  // User badges list
  List<Map<String, dynamic>> _userBadges = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Existing controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupSearchListener();
    _loadAllUsers();
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
      final response = await ApiService.getAllUsers();
      if (response['success'] == true && response['users'] != null) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(response['users']);
        });
        print('Loaded ${_allUsers.length} users from database');
      } else {
        print('Failed to load users: ${response['message']}');
      }
    } catch (e) {
      print('Error loading all users: $e');
    }
  }

  // Load user badges
  Future<void> _loadUserBadges() async {
    if (displayedUser?['id'] != null) {
      try {
        final response = await ApiService.getUserBadges(displayedUser!['id']);
        if (response['success'] == true && response['badges'] != null) {
          setState(() {
            _userBadges = List<Map<String, dynamic>>.from(response['badges']);
          });
          print('Loaded ${_userBadges.length} badges for user ${displayedUser!['id']}');
        } else {
          print('No badges found or error: ${response['message']}');
        }
      } catch (e) {
        print('Error loading user badges: $e');
      }
    } else {
      print('No user ID available for loading badges');
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Search from all users in database
      final filteredUsers = _allUsers.where((user) {
        final username = user['username']?.toString().toLowerCase() ?? '';
        final fullName = user['full_name']?.toString().toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();

        return username.contains(searchTerm) || fullName.contains(searchTerm);
      }).toList();

      setState(() {
        _searchResults = filteredUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await UserPreferences.getUser();
      setState(() => currentUser = user);

      final Map<String, dynamic>? arguments =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      print('Profile arguments: $arguments');

      if (arguments != null && arguments.isNotEmpty) {
        // FIXED: Properly handle visited user data
        setState(() => displayedUser = {
          'id': arguments['id'] ?? arguments['user_id'],
          'full_name': arguments['full_name'] ?? arguments['fullName'],
          'username': arguments['username'],
        });

        print('Displaying user profile: ${displayedUser!['username']} with ID: ${displayedUser!['id']}');

        // FIXED: Load stats for the visited user
        final visitedUserId = displayedUser!['id'];
        if (visitedUserId != null) {
          print('Loading stats for user ID: $visitedUserId');
          final response = await ApiService.getUserStats(visitedUserId);
          print('User stats response: $response');
          if (response['success'] == true) {
            setState(() => userStats = response['stats'] ?? {});
          } else {
            print('Failed to load user stats: ${response['message']}');
          }

          // FIXED: Load badges for the visited user
          _loadUserBadges();
        }

      } else {
        // No arguments, display current user
        setState(() => displayedUser = user);
        print('Displaying current user profile: ${user['username']} with ID: ${user['id']}');

        if (user['id'] != null) {
          final response = await ApiService.getUserStats(user['id']!);
          print('Current user stats response: $response');
          if (response['success'] == true) {
            setState(() => userStats = response['stats'] ?? {});
          }
        }
        _fullNameController.text = user['fullName'] ?? '';
        _usernameController.text = user['username'] ?? '';

        // Load badges for current user
        _loadUserBadges();
      }

    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to view another user's profile
  void _viewUserProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
        settings: RouteSettings(arguments: {
          'id': user['id'], // IMPORTANT: Ensure ID is passed
          'username': user['username'],
          'full_name': user['full_name'] ?? user['fullName'],
        }),
      ),
    );
  }

  // Function to exit search mode and return to current user profile
  void _exitSearchMode() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
      displayedUser = currentUser;
    });
    _loadUserData();
  }

  // Function to go back to previous screen properly
  void _goBack() {
    Navigator.pop(context);
  }

  // Build search results list
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
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
                'Search for users',
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('@${user['username'] ?? 'unknown'}'),
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
                    child: const Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
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
                  'id': user['id'], // IMPORTANT: Include user ID
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

  // Build user badges with season badges included
  Widget _buildUserBadges() {
    final int totalPoints = _safeIntConversion(userStats['totalPoints']);
    final int levelsCompleted = _safeIntConversion(userStats['levelsCompleted']);
    final int totalLevelsAttempted = _safeIntConversion(userStats['totalLevelsAttempted']);

    List<Widget> badges = [];

    // Season achievement badges
    for (var badge in _userBadges) {
      Color badgeColor;
      IconData badgeIcon;

      switch (badge['badge_type']) {
        case 'top1':
          badgeColor = Colors.amber;
          badgeIcon = Icons.emoji_events;
          break;
        case 'top2':
          badgeColor = const Color(0xFFC0C0C0);
          badgeIcon = Icons.workspace_premium;
          break;
        case 'top3':
          badgeColor = const Color(0xFFCD7F32);
          badgeIcon = Icons.star;
          break;
        default:
          badgeColor = Colors.tealAccent;
          badgeIcon = Icons.workspace_premium;
      }

      badges.add(_buildSeasonBadge(
        badgeIcon,
        '${badge['badge_name']}\nSeason ${badge['season_number']}',
        badgeColor,
      ));
    }

    // Existing game achievement badges
    // First Game Badge
    if (totalLevelsAttempted > 0) {
      badges.add(_buildIconBadge(Icons.play_arrow, 'First Game', Colors.green));
    }

    // Points Badges
    if (totalPoints >= 100) {
      badges.add(_buildIconBadge(Icons.emoji_events, '100+ Points', Colors.amber));
    } else if (totalPoints >= 50) {
      badges.add(_buildIconBadge(Icons.star, '50+ Points', Colors.yellow));
    }

    // Completion Badges
    if (levelsCompleted >= 10) {
      badges.add(_buildIconBadge(Icons.check_circle, '10+ Completed', Colors.green));
    } else if (levelsCompleted >= 5) {
      badges.add(_buildIconBadge(Icons.check_circle_outline, '5+ Completed', Colors.blue));
    }

    // Multi-language Badge
    if (userStats['languageStats'] != null && userStats['languageStats'] is Map) {
      final languageCount = (userStats['languageStats'] as Map).length;
      if (languageCount >= 3) {
        badges.add(_buildIconBadge(Icons.language, 'Multi-Language', Colors.purple));
      }
    }

    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Play more games to earn badges!',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: badges,
      ),
    );
  }

  // Icon-only badge widget
  Widget _buildIconBadge(IconData icon, String tooltip, Color color) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  // New method for season badges
  Widget _buildSeasonBadge(IconData icon, String tooltip, Color color) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  // FIXED: Updated header with proper back button logic
  Widget _buildHeader() {
    final bool isViewingOtherUser = displayedUser != null &&
        currentUser != null &&
        displayedUser!['username'] != currentUser!['username'];

    return Container(
      height: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // FIXED: Back Button - Proper navigation
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: _goBack,
            ),
          ),

          // Search Button (only show for current user's profile)
          if (!isViewingOtherUser)
            Positioned(
              top: 20,
              right: 70,
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 24),
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
            ),

          // Menu Button (only show for current user's profile)
          if (!isViewingOtherUser)
            Positioned(
              top: 20,
              right: 20,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onSelected: (value) => _handleMenuSelection(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit_profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Edit Profile'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'change_password',
                    child: ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Change Password'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'feedback',
                    child: ListTile(
                      leading: Icon(Icons.feedback),
                      title: Text('Feedback'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),

          // User Info
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.tealAccent.shade700,
                  child: Text(
                    displayedUser?['fullName']?.toString().substring(0, 1).toUpperCase() ??
                        displayedUser?['full_name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  displayedUser?['fullName'] ?? displayedUser?['full_name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Username
                Text(
                  '@${displayedUser?['username'] ?? 'unknown'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                // User Badges - ICON ONLY (SHOWS FOR ALL USERS)
                _buildUserBadges(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Handle menu selection
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit_profile':
        _showEditProfileDialog();
        break;
      case 'change_password':
        _showChangePasswordDialog();
        break;
      case 'feedback':
        _showFeedbackDialog();
        break;
      case 'logout':
        _logout(context);
        break;
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.tealAccent),
                  prefixIcon: Icon(Icons.person, color: Colors.tealAccent),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.tealAccent),
                  prefixIcon: Icon(Icons.alternate_email, color: Colors.tealAccent),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () {
              _updateProfile();
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.tealAccent),
                  prefixIcon: Icon(Icons.lock, color: Colors.tealAccent),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.tealAccent),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.tealAccent),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () {
              _changePassword();
              Navigator.pop(context);
            },
            child: const Text('Change Password', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
        title: const Text('Send Feedback', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We\'d love to hear your thoughts and suggestions!',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Feedback',
                  labelStyle: TextStyle(color: Colors.tealAccent),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  hintText: 'Tell us what you think...',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () {
              _sendFeedback();
              Navigator.pop(context);
            },
            child: const Text('Send Feedback', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_fullNameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (currentUser?['id'] != null) {
        final response = await ApiService.updateProfile(
          currentUser!['id'],
          _fullNameController.text.trim(),
          _usernameController.text.trim(),
        );

        if (response['success'] == true) {
          final updatedUser = {
            'id': currentUser!['id'],
            'fullName': _fullNameController.text.trim(),
            'username': _usernameController.text.trim(),
          };

          await UserPreferences.saveUser(updatedUser);

          setState(() {
            currentUser = updatedUser;
            displayedUser = updatedUser;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Update failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all password fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (currentUser?['id'] != null) {
        final response = await ApiService.changePassword(
          currentUser!['id'],
          _currentPasswordController.text,
          _newPasswordController.text,
        );

        if (response['success'] == true) {
          _currentPasswordController.clear();
          _newPasswordController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Password change failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (currentUser?['id'] != null) {
        final response = await ApiService.submitFeedback(
          currentUser!['id'],
          _feedbackController.text,
        );

        if (response['success'] == true) {
          _feedbackController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to send feedback'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.tealAccent, width: 2),
          ),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
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

  // Helper method to safely convert dynamic values to int
  int _safeIntConversion(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageProgress(String language, Map<String, dynamic> stats) {
    final int points = _safeIntConversion(stats['points']);
    final int completed = _safeIntConversion(stats['completed']);
    final int attempted = _safeIntConversion(stats['attempted']);
    final double progress = attempted > 0 ? completed / attempted.toDouble() : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.tealAccent),
            ),
            child: Center(
              child: Text(
                language[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed/$attempted levels',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '$points pts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Statistics content that works for both current user and other users
  Widget _buildStatisticsContent() {
    final bool isViewingOtherUser = displayedUser != null &&
        currentUser != null &&
        displayedUser!['username'] != currentUser!['username'];

    // FIXED: Ensure we have proper default values
    final int totalPoints = _safeIntConversion(userStats['totalPoints'] ?? 0);
    final int levelsCompleted = _safeIntConversion(userStats['levelsCompleted'] ?? 0);
    final int totalLevelsAttempted = _safeIntConversion(userStats['totalLevelsAttempted'] ?? 0);

    // FIXED: Process language stats properly
    final Map<String, dynamic> playedLanguages = {};
    if (userStats['languageStats'] != null && userStats['languageStats'] is Map) {
      (userStats['languageStats'] as Map).forEach((key, value) {
        if (value is Map) {
          final int points = _safeIntConversion(value['points'] ?? 0);
          final int completed = _safeIntConversion(value['completed'] ?? 0);
          final int attempted = _safeIntConversion(value['attempted'] ?? 0);

          // Include all languages that have been attempted or have points
          if (points > 0 || attempted > 0 || completed > 0) {
            playedLanguages[key] = {
              'points': points,
              'completed': completed,
              'attempted': attempted,
            };
          }
        }
      });
    }

    final int languagesCount = playedLanguages.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatsCard('Total Points', '$totalPoints', Icons.emoji_events, Colors.amber),
              _buildStatsCard('Levels Completed', '$levelsCompleted', Icons.check_circle, Colors.green),
              _buildStatsCard('Levels Attempted', '$totalLevelsAttempted', Icons.videogame_asset, Colors.blue),
              _buildStatsCard('Languages Played', '$languagesCount', Icons.code, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          if (playedLanguages.isNotEmpty) ...[
            Text(
              'Language Progress',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: playedLanguages.entries
                  .map((entry) => _buildLanguageProgress(entry.key, entry.value as Map<String, dynamic>))
                  .toList(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 60, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text(
                    isViewingOtherUser ? 'No Games Played Yet' : 'No Games Played Yet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isViewingOtherUser
                        ? 'This user hasn\'t played any games yet'
                        : 'Play some games to see your progress here!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build search bar for search mode
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
                hintText: 'Search users...',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: _isLoading && !_isSearching
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.tealAccent,
        ),
      )
          : Column(
        children: [
          if (!_isSearching) _buildHeader(),
          if (_isSearching) _buildSearchBar(),
          if (_isSearching)
            Expanded(child: _buildSearchResults())
          else
            Expanded(
              child: _buildStatisticsContent(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
}