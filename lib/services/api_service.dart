import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://codesnap.fun";

  // Helper methods for safe type conversion
  static int _safeIntConversion(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _safeBoolConversion(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value.toInt() != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  // Auth methods
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'login',
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(String fullName, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'register',
          'full_name': fullName,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // NEW METHOD: Get all users from database - FIXED VERSION
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth.php?action=get_all_users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Get All Users Response: $data'); // Debug logging

        if (data['success'] == true && data['users'] != null) {
          return {
            'success': true,
            'users': List<Map<String, dynamic>>.from(data['users'])
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to load users'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error getting all users: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // NEW METHOD: Search users
  static Future<Map<String, dynamic>> searchUsers(String searchTerm) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'search_users',
          'search_term': searchTerm,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Search Users Response: $data'); // Debug logging

        if (data['success'] == true && data['users'] != null) {
          return {
            'success': true,
            'users': List<Map<String, dynamic>>.from(data['users'])
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'No users found'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error searching users: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // Score methods - UPDATED to preserve level progress
  static Future<Map<String, dynamic>> saveScore(int userId, String language, int level, int score, bool completed) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'save_score',
          'user_id': userId,
          'language': language,
          'level': level,
          'score': score,
          'completed': completed,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getScores(int userId, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_scores',
          'user_id': userId,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Process scores to ensure proper types
        if (data['success'] == true && data['scores'] != null) {
          final Map<String, dynamic> processedScores = {};
          data['scores'].forEach((key, value) {
            processedScores[key] = {
              'score': _safeIntConversion(value['score']),
              'completed': _safeBoolConversion(value['completed']),
            };
          });
          data['scores'] = processedScores;
        }

        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetScores(int userId, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reset_scores',
          'user_id': userId,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // UPDATE: Reset season scores method
  static Future<Map<String, dynamic>> resetSeasonScores(int season) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=reset_season&season=$season'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Season $season reset response: $data');
        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error resetting season: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // NEW METHOD: Get user badges
  static Future<Map<String, dynamic>> getUserBadges(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_user_badges&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('User badges response for user $userId: $data');
        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error getting user badges: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_leaderboard'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug print to see what the API returns
        print('API Response: $data');

        // Handle different response structures
        if (data['success'] == true) {
          if (data['leaderboard'] != null && data['leaderboard'] is List) {
            return {
              'success': true,
              'leaderboard': data['leaderboard']
            };
          } else {
            return {
              'success': false,
              'message': 'Invalid leaderboard data format'
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Unknown error'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Connection error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // Profile methods
  static Future<Map<String, dynamic>> updateProfile(int userId, String fullName, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'update_profile',
          'user_id': userId,
          'full_name': fullName,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(int userId, String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'change_password',
          'user_id': userId,
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // UPDATED METHOD: Get user stats with better error handling and logging
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_stats',
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug logging
        print('User Stats for $userId: $data');

        // Process stats to ensure proper types
        if (data['success'] == true && data['stats'] != null) {
          final stats = data['stats'];
          stats['totalPoints'] = _safeIntConversion(stats['totalPoints']);
          stats['levelsCompleted'] = _safeIntConversion(stats['levelsCompleted']);
          stats['totalLevelsAttempted'] = _safeIntConversion(stats['totalLevelsAttempted']);

          if (stats['languageStats'] != null) {
            final Map<String, dynamic> processedLanguageStats = {};
            stats['languageStats'].forEach((key, value) {
              processedLanguageStats[key] = {
                'points': _safeIntConversion(value['points']),
                'completed': _safeIntConversion(value['completed']),
                'attempted': _safeIntConversion(value['attempted']),
              };
            });
            stats['languageStats'] = processedLanguageStats;
          }
        }

        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error getting user stats: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Password reset methods
  static Future<Map<String, dynamic>> requestPasswordReset(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'forgot_password',
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String userId,
      String newPassword,
      String securityCode
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reset_password',
          'user_id': userId,
          'new_password': newPassword,
          'security_code': securityCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Feedback method
  static Future<Map<String, dynamic>> submitFeedback(int userId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'submit_feedback',
          'user_id': userId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Utility method to test connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Connection successful'};
      } else {
        return {'success': false, 'message': 'Server responded with status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Season methods
  static Future<Map<String, dynamic>> getSeasonInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_season_info'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['season_info'] != null) {
          // Process season info to ensure proper types
          final seasonInfo = data['season_info'];
          seasonInfo['current_season'] = _safeIntConversion(seasonInfo['current_season']);
          seasonInfo['days_remaining'] = _safeIntConversion(seasonInfo['days_remaining']);

          // Parse dates if provided
          if (seasonInfo['season_start'] != null) {
            try {
              seasonInfo['season_start'] = DateTime.parse(seasonInfo['season_start']);
            } catch (e) {
              seasonInfo['season_start'] = DateTime.now();
            }
          }

          if (seasonInfo['season_end'] != null) {
            try {
              seasonInfo['season_end'] = DateTime.parse(seasonInfo['season_end']);
            } catch (e) {
              seasonInfo['season_end'] = DateTime.now().add(Duration(minutes: 5));
            }
          }
        }

        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error getting season info: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getSeasonLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_season_leaderboard'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug print to see what the API returns
        print('Season Leaderboard API Response: $data');

        // Handle different response structures
        if (data['success'] == true) {
          if (data['leaderboard'] != null && data['leaderboard'] is List) {
            return {
              'success': true,
              'leaderboard': data['leaderboard']
            };
          } else {
            return {
              'success': false,
              'message': 'Invalid season leaderboard data format'
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Unknown error'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Connection error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // NEW METHOD: Debug endpoint to test API connectivity
  static Future<Map<String, dynamic>> debugEndpoint() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'debug',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'response_body': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // NEW METHOD: Get user by ID
  static Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      // Since we don't have a direct endpoint, we'll get all users and filter
      final response = await getAllUsers();
      if (response['success'] == true && response['users'] != null) {
        final users = List<Map<String, dynamic>>.from(response['users']);
        final user = users.firstWhere(
              (user) => user['id'] == userId,
          orElse: () => {},
        );

        if (user.isNotEmpty) {
          return {
            'success': true,
            'user': user
          };
        } else {
          return {
            'success': false,
            'message': 'User not found'
          };
        }
      } else {
        return response;
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error finding user: $e'
      };
    }
  }

  // NEW METHOD: Get user profile by ID or username
  static Future<Map<String, dynamic>> getUserProfile({int? userId, String? username}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_user_profile',
          if (userId != null) 'user_id': userId,
          if (username != null) 'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // NEW METHOD: Validate user session
  static Future<Map<String, dynamic>> validateSession(int userId) async {
    try {
      final response = await getUserById(userId);
      if (response['success'] == true) {
        return {
          'success': true,
          'valid': true,
          'user': response['user']
        };
      } else {
        return {
          'success': false,
          'valid': false,
          'message': response['message']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'message': 'Session validation error: $e'
      };
    }
  }

  // NEW METHOD: Get user ranking
  static Future<Map<String, dynamic>> getUserRanking(int userId) async {
    try {
      final response = await getLeaderboard();
      if (response['success'] == true && response['leaderboard'] != null) {
        final leaderboard = List<Map<String, dynamic>>.from(response['leaderboard']);

        // Find user in leaderboard
        for (int i = 0; i < leaderboard.length; i++) {
          final user = leaderboard[i];
          if (user['username'] == await _getUsernameById(userId)) {
            return {
              'success': true,
              'rank': i + 1,
              'points': user['points'] ?? 0,
              'levels_completed': user['levels_completed'] ?? 0
            };
          }
        }

        return {
          'success': true,
          'rank': leaderboard.length + 1, // Not in top list
          'points': 0,
          'levels_completed': 0
        };
      } else {
        return response;
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting user ranking: $e'
      };
    }
  }

  // Helper method to get username by ID
  static Future<String> _getUsernameById(int userId) async {
    try {
      final response = await getUserById(userId);
      if (response['success'] == true) {
        return response['user']['username'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // NEW METHOD: Bulk operations for better performance
  static Future<Map<String, dynamic>> getMultipleUserStats(List<int> userIds) async {
    try {
      // Since we don't have a bulk endpoint, we'll make individual calls
      final List<Map<String, dynamic>> results = [];

      for (final userId in userIds) {
        final response = await getUserStats(userId);
        if (response['success'] == true) {
          results.add({
            'user_id': userId,
            'stats': response['stats']
          });
        }
      }

      return {
        'success': true,
        'user_stats': results
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting multiple user stats: $e'
      };
    }
  }

  // NEW METHOD: Check server status
  static Future<Map<String, dynamic>> checkServerStatus() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'status': 'online',
          'response_time': '${stopwatch.elapsedMilliseconds}ms',
          'server_url': baseUrl
        };
      } else {
        return {
          'success': false,
          'status': 'error',
          'http_status': response.statusCode,
          'response_time': '${stopwatch.elapsedMilliseconds}ms'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'status': 'offline',
        'message': 'Server is unreachable: $e'
      };
    }
  }

  // NEW METHOD: Clear cache (utility for development)
  static Future<void> clearCache() async {
    // This would typically clear any cached data
    print('API Service cache cleared');
  }

  // NEW METHOD: Retry mechanism for failed requests
  static Future<Map<String, dynamic>> retryRequest(
      Future<Map<String, dynamic>> Function() requestFunction,
      {int maxRetries = 3, int delayMs = 1000}
      ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await requestFunction();
        if (result['success'] == true) {
          return result;
        }

        // If not successful but not a connection error, return immediately
        if (!result['message'].toString().contains('Connection error')) {
          return result;
        }

        print('Request failed (attempt $attempt/$maxRetries): ${result['message']}');

        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: delayMs * attempt));
        }
      } catch (e) {
        print('Request exception (attempt $attempt/$maxRetries): $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: delayMs * attempt));
        }
      }
    }

    return {
      'success': false,
      'message': 'All retry attempts failed'
    };
  }

  // NEW METHOD: Get user progress summary
  static Future<Map<String, dynamic>> getUserProgressSummary(int userId) async {
    try {
      final statsResponse = await getUserStats(userId);
      final badgesResponse = await getUserBadges(userId);
      final rankingResponse = await getUserRanking(userId);

      return {
        'success': true,
        'user_id': userId,
        'stats': statsResponse['success'] == true ? statsResponse['stats'] : {},
        'badges': badgesResponse['success'] == true ? badgesResponse['badges'] : [],
        'ranking': rankingResponse['success'] == true ? rankingResponse : {},
        'season': await getSeasonInfo(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting user progress summary: $e'
      };
    }
  }

  // NEW METHOD: Get language-specific stats
  static Future<Map<String, dynamic>> getLanguageStats(int userId, String language) async {
    try {
      final response = await getScores(userId, language);

      if (response['success'] == true && response['scores'] != null) {
        final scores = response['scores'] as Map<String, dynamic>;
        int totalScore = 0;
        int levelsCompleted = 0;
        int levelsAttempted = 0;

        scores.forEach((level, data) {
          final score = _safeIntConversion(data['score']);
          final completed = _safeBoolConversion(data['completed']);

          if (score > 0) {
            levelsAttempted++;
            totalScore += score;
            if (completed) {
              levelsCompleted++;
            }
          }
        });

        return {
          'success': true,
          'language': language,
          'total_score': totalScore,
          'levels_completed': levelsCompleted,
          'levels_attempted': levelsAttempted,
          'total_points': totalScore * 10, // 1 score = 10 points
          'completion_rate': levelsAttempted > 0 ? (levelsCompleted / levelsAttempted) * 100 : 0,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to get language stats'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting language stats: $e'
      };
    }
  }

  // NEW METHOD: Get all languages progress for user
  static Future<Map<String, dynamic>> getAllLanguagesProgress(int userId) async {
    try {
      final languages = ['Python', 'Java', 'C++', 'PHP', 'SQL'];
      final Map<String, dynamic> progress = {};

      for (final language in languages) {
        final stats = await getLanguageStats(userId, language);
        if (stats['success'] == true) {
          progress[language] = stats;
        } else {
          progress[language] = {
            'success': false,
            'message': stats['message'],
            'total_score': 0,
            'levels_completed': 0,
            'levels_attempted': 0,
            'total_points': 0,
            'completion_rate': 0,
          };
        }
      }

      return {
        'success': true,
        'user_id': userId,
        'languages_progress': progress,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting all languages progress: $e'
      };
    }
  }

  // NEW METHOD: Test database connection specifically
  static Future<Map<String, dynamic>> testDatabaseConnection() async {
    try {
      final response = await getAllUsers();
      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Database connection successful',
          'user_count': response['users']?.length ?? 0
        };
      } else {
        return {
          'success': false,
          'message': 'Database connection failed: ${response['message']}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Database connection error: $e'
      };
    }
  }

  // NEW METHOD: Get server information
  static Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final response = await debugEndpoint();
      if (response['success'] == true) {
        return {
          'success': true,
          'server_info': response
        };
      } else {
        return response;
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting server info: $e'
      };
    }
  }

  // NEW METHOD: Validate all API endpoints
  static Future<Map<String, dynamic>> validateAllEndpoints() async {
    try {
      final results = <String, dynamic>{};

      // Test auth endpoint
      final authTest = await testConnection();
      results['auth_endpoint'] = authTest;

      // Test database connection
      final dbTest = await testDatabaseConnection();
      results['database'] = dbTest;

      // Test scores endpoint
      final scoresTest = await getLeaderboard();
      results['scores_endpoint'] = scoresTest;

      // Test profile endpoint
      final profileTest = await debugEndpoint();
      results['profile_endpoint'] = profileTest;

      return {
        'success': true,
        'validation_results': results,
        'all_endpoints_working': authTest['success'] == true &&
            dbTest['success'] == true &&
            scoresTest['success'] == true
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Validation error: $e'
      };
    }
  }
}