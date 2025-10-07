import 'package:shared_preferences/shared_preferences.dart';

class DailyChallengeService {
  static const String _lastChallengeDateKey = 'last_challenge_date';
  static const String _currentChallengeIndexKey = 'current_challenge_index';
  static const String _streakCountKey = 'streak_count';
  static const String _lastCompletionDateKey = 'last_completion_date';

  static Future<DateTime?> getLastChallengeDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastChallengeDateKey);
    return lastDate != null ? DateTime.parse(lastDate) : null;
  }

  static Future<void> updateLastChallengeDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastChallengeDateKey, DateTime.now().toString());
  }

  static Future<int> getCurrentChallengeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentChallengeIndexKey) ?? 0;
  }

  static Future<void> setCurrentChallengeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentChallengeIndexKey, index);
  }

  static Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastCompletion = await getLastCompletionDate();

    int currentStreak = await getStreakCount();

    if (lastCompletion == null) {
      // First time completion
      currentStreak = 1;
    } else {
      final difference = now.difference(lastCompletion).inDays;

      if (difference == 1) {
        // Consecutive day
        currentStreak++;
      } else if (difference > 1) {
        // Streak broken
        currentStreak = 1;
      }
      // If difference == 0, same day - don't change streak
    }

    await prefs.setInt(_streakCountKey, currentStreak);
    await prefs.setString(_lastCompletionDateKey, now.toString());
  }

  static Future<DateTime?> getLastCompletionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastCompletionDateKey);
    return lastDate != null ? DateTime.parse(lastDate) : null;
  }

  static Future<bool> hasCompletedToday() async {
    final lastCompletion = await getLastCompletionDate();
    if (lastCompletion == null) return false;

    final now = DateTime.now();
    return now.year == lastCompletion.year &&
        now.month == lastCompletion.month &&
        now.day == lastCompletion.day;
  }

  static Future<bool> isNewDay() async {
    final lastChallenge = await getLastChallengeDate();
    if (lastChallenge == null) return true;

    final now = DateTime.now();
    return now.year != lastChallenge.year ||
        now.month != lastChallenge.month ||
        now.day != lastChallenge.day;
  }
}