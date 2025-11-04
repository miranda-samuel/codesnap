import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.56.1/codesnap";

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

  // Helper function for min/max
  static int max(int a, int b) => a > b ? a : b;
  static int min(int a, int b) => a < b ? a : b;

  // ✅ FIXED: ACTUAL GAME SCORING - ALLOW SCORE 0
  static Future<Map<String, dynamic>> saveScore(int userId, String language, int level, int score, bool completed) async {
    try {
      // ✅ FIXED: Allow score 0, 1, 2, or 3 (not just 1-3)
      final actualScore = max(0, min(3, score)); // Allow scores 0-3

      print('🎮 SAVING SCORE - User: $userId, $language Level $level, Score: $actualScore/3, Completed: $completed');

      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'save_score',
          'user_id': userId,
          'language': language,
          'level': level,
          'score': actualScore, // ✅ ACTUAL SCORE (0,1,2,3) - NO REDUCTION
          'completed': completed,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ SCORE SAVED SUCCESS: $actualScore/3 for $language Level $level');
        print('📊 SERVER RESPONSE: $result');
        return result;
      } else {
        print('❌ SCORE SAVE FAILED: Server error ${response.statusCode}');
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ SCORE SAVE ERROR: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ FIXED: For Medium and Hard difficulties - ALLOW SCORE 0
  static Future<Map<String, dynamic>> saveScoreWithDifficulty(int userId, String language, String difficulty, int level, int score, bool completed) async {
    try {
      // ✅ FIXED: Allow score 0, 1, 2, or 3 (not just 1-3)
      final actualScore = max(0, min(3, score));

      // Use unique key for each difficulty
      String scoreKey = '${language}_$difficulty';

      print('🎮 SAVING SCORE WITH DIFFICULTY - User: $userId, $language $difficulty Level $level, Score: $actualScore/3, Completed: $completed');

      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'save_score',
          'user_id': userId,
          'language': scoreKey,
          'level': level,
          'score': actualScore, // ✅ ACTUAL SCORE (0,1,2,3) - NO REDUCTION
          'completed': completed,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ SCORE SAVED SUCCESS: $actualScore/3 for $language $difficulty Level $level');
        return result;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ FIXED: Get scores with proper debugging
  static Future<Map<String, dynamic>> getScores(int userId, String language) async {
    try {
      print('🔍 GETTING SCORES - User: $userId, Language: $language');

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
        print('📊 SCORES RESPONSE RAW: $data');

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

          print('🎯 PROCESSED SCORES: $processedScores');
        } else {
          print('⚠️ NO SCORES FOUND or ERROR: ${data['message']}');
        }

        return data;
      } else {
        print('❌ GET SCORES FAILED: Server error ${response.statusCode}');
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ GET SCORES ERROR: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ NEW: Get scores with difficulty support
  static Future<Map<String, dynamic>> getScoresWithDifficulty(int userId, String language, String difficulty) async {
    try {
      // Use unique key for each difficulty
      String scoreKey = '${language}_$difficulty';

      print('🔍 GETTING SCORES WITH DIFFICULTY - User: $userId, Language: $scoreKey');

      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_scores',
          'user_id': userId,
          'language': scoreKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 SCORES WITH DIFFICULTY RESPONSE: $data');

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

  // ✅ UPDATED: Get Game Configuration from database - FIXED VERSION
  static Future<Map<String, dynamic>> getGameConfig(String language, int level) async {
    try {
      print('🎮 GETTING GAME CONFIG - Language: $language, Level: $level');

      // Use POST instead of GET to avoid URL encoding issues
      final response = await http.post(
        Uri.parse('$baseUrl/get_game_config.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language': language,
          'level': level,
        }),
      ).timeout(Duration(seconds: 10));

      print('🔍 RESPONSE STATUS: ${response.statusCode}');
      print('📋 RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📋 GAME CONFIG RESPONSE SUCCESS: ${data['success']}');

        if (data['success'] == true && data['game'] != null) {
          print('✅ GAME CONFIG LOADED SUCCESSFULLY FROM DATABASE');

          // Parse the JSON strings from database
          final game = data['game'];

          // Parse correct_blocks JSON
          try {
            if (game['correct_blocks'] is String) {
              game['correct_blocks'] = json.decode(game['correct_blocks']);
            }
          } catch (e) {
            print('❌ Error parsing correct_blocks: $e');
            game['correct_blocks'] = [];
          }

          // Parse incorrect_blocks JSON
          try {
            if (game['incorrect_blocks'] is String) {
              game['incorrect_blocks'] = json.decode(game['incorrect_blocks']);
            }
          } catch (e) {
            print('❌ Error parsing incorrect_blocks: $e');
            game['incorrect_blocks'] = [];
          }

          // Parse code_structure JSON
          try {
            if (game['code_structure'] is String) {
              game['code_structure'] = json.decode(game['code_structure']);
            }
          } catch (e) {
            print('❌ Error parsing code_structure: $e');
            game['code_structure'] = [
              "#include <iostream>",
              "using namespace std;",
              "",
              "int main() {",
              "    // Your code here",
              "    return 0;",
              "}"
            ];
          }

          // Ensure timer_duration is int
          game['timer_duration'] = _safeIntConversion(game['timer_duration']);

          print('🎯 PARSED GAME CONFIG:');
          print('   Correct Blocks: ${game['correct_blocks']}');
          print('   Incorrect Blocks: ${game['incorrect_blocks']}');
          print('   Code Structure: ${game['code_structure']}');
          print('   Timer Duration: ${game['timer_duration']}');

          return data;
        } else {
          print('❌ GAME CONFIG NOT FOUND IN DATABASE: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Game configuration not found in database'
          };
        }
      } else {
        print('❌ SERVER ERROR: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } on TimeoutException {
      print('❌ TIMEOUT ERROR: Request timed out');
      return {
        'success': false,
        'message': 'Connection timeout. Please check your server.'
      };
    } catch (e) {
      print('❌ ERROR: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // ✅ NEW: Get game config with difficulty support
  static Future<Map<String, dynamic>> getGameConfigWithDifficulty(String language, String difficulty, int level) async {
    try {
      String languageKey = '${language}_$difficulty';
      print('🎮 GETTING GAME CONFIG WITH DIFFICULTY - Language: $languageKey, Level: $level');

      final response = await http.post(
        Uri.parse('$baseUrl/get_game_config.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language': languageKey,
          'level': level,
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['game'] != null) {
          print('✅ GAME CONFIG WITH DIFFICULTY LOADED SUCCESSFULLY');

          // Parse the JSON strings from database
          final game = data['game'];

          // Parse correct_blocks JSON
          try {
            if (game['correct_blocks'] is String) {
              game['correct_blocks'] = json.decode(game['correct_blocks']);
            }
          } catch (e) {
            print('❌ Error parsing correct_blocks: $e');
            game['correct_blocks'] = [];
          }

          // Parse incorrect_blocks JSON
          try {
            if (game['incorrect_blocks'] is String) {
              game['incorrect_blocks'] = json.decode(game['incorrect_blocks']);
            }
          } catch (e) {
            print('❌ Error parsing incorrect_blocks: $e');
            game['incorrect_blocks'] = [];
          }

          // Parse code_structure JSON
          try {
            if (game['code_structure'] is String) {
              game['code_structure'] = json.decode(game['code_structure']);
            }
          } catch (e) {
            print('❌ Error parsing code_structure: $e');
            game['code_structure'] = [
              "#include <iostream>",
              "using namespace std;",
              "",
              "int main() {",
              "    // Your code here",
              "    return 0;",
              "}"
            ];
          }

          // Ensure timer_duration is int
          game['timer_duration'] = _safeIntConversion(game['timer_duration']);

          return data;
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Game configuration not found in database'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please check your server.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> resetScores(int userId, String language) async {
    try {
      print('🔄 RESETTING SCORES - User: $userId, Language: $language');

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
        final result = jsonDecode(response.body);
        print('✅ SCORES RESET SUCCESS: $result');
        return result;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ NEW: Reset scores with difficulty support
  static Future<Map<String, dynamic>> resetScoresWithDifficulty(int userId, String language, String difficulty) async {
    try {
      // Use unique key for each difficulty
      String scoreKey = '${language}_$difficulty';

      print('🔄 RESETTING SCORES WITH DIFFICULTY - User: $userId, Language: $scoreKey');

      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reset_scores',
          'user_id': userId,
          'language': scoreKey,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ SCORES WITH DIFFICULTY RESET SUCCESS: $result');
        return result;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // AUTH METHODS
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔐 LOGIN ATTEMPT - Username: $username');

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
        final result = jsonDecode(response.body);
        print('✅ LOGIN RESPONSE: $result');
        return result;
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

  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      print('👥 GETTING ALL USERS');

      final response = await http.get(
        Uri.parse('$baseUrl/auth.php?action=get_all_users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

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
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // SEASON METHODS
  static Future<Map<String, dynamic>> resetSeasonScores(int season) async {
    try {
      print('🔄 RESETTING SEASON $season');

      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=reset_season&season=$season'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return {
            'success': true,
            'current_season': data['current_season'] ?? season,
            'next_season': data['next_season'] ?? (season + 1),
            'awarded_badges': data['awarded_badges'] ?? [],
            'top_users': data['top_users'] ?? [],
            'message': data['message'] ?? 'Season reset successfully - Levels preserved',
            'note': data['note'] ?? 'Level progress preserved, only leaderboard points reduced'
          };
        }
        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      print('🏆 GETTING LEADERBOARD');

      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_leaderboard'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['leaderboard'] != null && data['leaderboard'] is List) {
            return {
              'success': true,
              'leaderboard': data['leaderboard'],
              'current_season': data['current_season'] ?? 1,
              'note': data['note'] ?? ''
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
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getUserBadges(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_user_badges&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // PROFILE METHODS
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
      print('📊 GETTING USER STATS - User: $userId');

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

  // PASSWORD RESET METHODS
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

  // FEEDBACK METHOD
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

  // SEASON INFO METHODS
  static Future<Map<String, dynamic>> getSeasonInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/scores.php?action=get_season_info'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['season_info'] != null) {
          final seasonInfo = data['season_info'];
          seasonInfo['current_season'] = _safeIntConversion(seasonInfo['current_season']);
          seasonInfo['days_remaining'] = _safeIntConversion(seasonInfo['days_remaining']);

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
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // DEBUG METHOD
  static Future<Map<String, dynamic>> debugScoreSubmission(int userId, String language, int level, int score) async {
    try {
      print('🔍 DEBUG SCORE SUBMISSION:');
      print('   User: $userId');
      print('   Language: $language');
      print('   Level: $level');
      print('   Score: $score (should be 0, 1, 2, or 3)');

      final response = await http.post(
        Uri.parse('$baseUrl/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'save_score',
          'user_id': userId,
          'language': language,
          'level': level,
          'score': score,
          'completed': score == 3, // completed if perfect score
        }),
      );

      print('   Server Response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('   ERROR: $e');
      return {'success': false, 'message': 'Debug failed: $e'};
    }
  }

  // TEST CONNECTION
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

  // ✅ NEW: Get user profile with comprehensive stats
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      print('👤 GETTING USER PROFILE - User: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_user_profile',
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ✅ NEW: Get user rank
  static Future<Map<String, dynamic>> getUserRank(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_user_rank',
          'user_id': userId,
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

  // ✅ NEW: Get all users basic info
  static Future<Map<String, dynamic>> getAllUsersBasic() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_all_users_basic',
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

  // ✅ NEW: Debug endpoint
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
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
