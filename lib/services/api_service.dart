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

  // Score methods
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

  // NEW: Season methods
  static Future<Map<String, dynamic>> resetSeasonScores() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reset_season',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Season reset response: $data');
        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error resetting season: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

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
              seasonInfo['season_end'] = DateTime.now().add(Duration(days: 60));
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
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Add these methods to your ApiService class
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
}