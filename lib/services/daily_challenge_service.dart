import 'package:shared_preferences/shared_preferences.dart';

class DailyChallengeService {
  // KEYS FOR DAILY CHALLENGE SYSTEM
  static const String _lastChallengeDateKey = 'last_challenge_date';
  static const String _currentChallengeIndexKey = 'current_challenge_index';
  static const String _streakCountKey = 'streak_count';
  static const String _lastCompletionDateKey = 'last_completion_date';
  static const String _hintCardsKey = 'hint_cards_count';
  static const String _dailyCompletedKey = 'daily_completed';

  // USER-SPECIFIC KEYS
  static String _getUserKey(String baseKey, int? userId) {
    return userId != null ? '${baseKey}_$userId' : baseKey;
  }

  // HINT CARDS MANAGEMENT
  static Future<int> getUserHintCards(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_hintCardsKey, userId);
    return prefs.getInt(userKey) ?? 0;
  }

  static Future<void> addHintCard(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_hintCardsKey, userId);
    int currentHints = await getUserHintCards(userId);
    await prefs.setInt(userKey, currentHints + 1);
  }

  static Future<void> useHintCard(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_hintCardsKey, userId);
    int currentHints = await getUserHintCards(userId);
    if (currentHints > 0) {
      await prefs.setInt(userKey, currentHints - 1);
    }
  }

  // DAILY CHALLENGE COMPLETION
  static Future<void> markDailyChallengeCompleted(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Mark as completed for today
    final completedKey = _getUserKey(_dailyCompletedKey, userId);
    await prefs.setBool(completedKey, true);

    // Update last completion date
    final lastCompletionKey = _getUserKey(_lastCompletionDateKey, userId);
    await prefs.setString(lastCompletionKey, now.toString());

    // Add hint card as reward
    await addHintCard(userId);

    // Update streak
    await updateUserStreak(userId);
  }

  static Future<bool> hasUserCompletedToday(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedKey = _getUserKey(_dailyCompletedKey, userId);
    final lastCompletion = await getUserLastCompletionDate(userId);

    if (lastCompletion == null) return false;

    final now = DateTime.now();
    final isSameDay = now.year == lastCompletion.year &&
        now.month == lastCompletion.month &&
        now.day == lastCompletion.day;

    return isSameDay && (prefs.getBool(completedKey) ?? false);
  }

  // STREAK MANAGEMENT
  static Future<int> getUserStreakCount(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_streakCountKey, userId);
    return prefs.getInt(userKey) ?? 0;
  }

  static Future<void> updateUserStreak(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final streakKey = _getUserKey(_streakCountKey, userId);
    final lastCompletionKey = _getUserKey(_lastCompletionDateKey, userId);

    final currentStreak = await getUserStreakCount(userId);
    final lastCompletion = await getUserLastCompletionDate(userId);

    if (lastCompletion == null) {
      // First time completion
      await prefs.setInt(streakKey, 1);
    } else {
      final difference = now.difference(lastCompletion).inDays;

      if (difference == 1) {
        // Consecutive day
        await prefs.setInt(streakKey, currentStreak + 1);
      } else if (difference > 1) {
        // Streak broken
        await prefs.setInt(streakKey, 1);
      }
      // If difference == 0, same day - don't change streak
    }

    await prefs.setString(lastCompletionKey, now.toString());
  }

  static Future<DateTime?> getUserLastCompletionDate(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_lastCompletionDateKey, userId);
    final lastDate = prefs.getString(userKey);
    return lastDate != null ? DateTime.parse(lastDate) : null;
  }

  // CHALLENGE SELECTION AND SCHEDULING
  static Future<DateTime?> getUserLastChallengeDate(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_lastChallengeDateKey, userId);
    final lastDate = prefs.getString(userKey);
    return lastDate != null ? DateTime.parse(lastDate) : null;
  }

  static Future<void> updateUserLastChallengeDate(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_lastChallengeDateKey, userId);
    await prefs.setString(userKey, DateTime.now().toString());

    // Reset daily completion status for new day
    final completedKey = _getUserKey(_dailyCompletedKey, userId);
    await prefs.setBool(completedKey, false);
  }

  static Future<bool> isNewDayForUser(int? userId) async {
    final lastChallenge = await getUserLastChallengeDate(userId);
    if (lastChallenge == null) return true;

    final now = DateTime.now();
    return now.year != lastChallenge.year ||
        now.month != lastChallenge.month ||
        now.day != lastChallenge.day;
  }

  static Future<int> getUserCurrentChallengeIndex(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_currentChallengeIndexKey, userId);
    return prefs.getInt(userKey) ?? 0;
  }

  static Future<void> setUserCurrentChallengeIndex(int? userId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(_currentChallengeIndexKey, userId);
    await prefs.setInt(userKey, index);
  }

  // RESET DAILY CHALLENGE (for testing or admin purposes)
  static Future<void> resetDailyChallenge(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedKey = _getUserKey(_dailyCompletedKey, userId);
    await prefs.setBool(completedKey, false);
  }

  // GET USER DAILY CHALLENGE STATUS
  static Future<Map<String, dynamic>> getUserDailyChallengeStatus(int? userId) async {
    final hasCompleted = await hasUserCompletedToday(userId);
    final streakCount = await getUserStreakCount(userId);
    final hintCards = await getUserHintCards(userId);
    final lastCompletion = await getUserLastCompletionDate(userId);

    return {
      'completed': hasCompleted,
      'streak': streakCount,
      'hint_cards': hintCards,
      'last_completion': lastCompletion?.toString(),
    };
  }

  // OLD METHODS (for backward compatibility - without user ID)
  static Future<DateTime?> getLastChallengeDate() async {
    return await getUserLastChallengeDate(null);
  }

  static Future<void> updateLastChallengeDate() async {
    await updateUserLastChallengeDate(null);
  }

  static Future<int> getCurrentChallengeIndex() async {
    return await getUserCurrentChallengeIndex(null);
  }

  static Future<void> setCurrentChallengeIndex(int index) async {
    await setUserCurrentChallengeIndex(null, index);
  }

  static Future<int> getStreakCount() async {
    return await getUserStreakCount(null);
  }

  static Future<void> updateStreak() async {
    await updateUserStreak(null);
  }

  static Future<DateTime?> getLastCompletionDate() async {
    return await getUserLastCompletionDate(null);
  }

  static Future<bool> hasCompletedToday() async {
    return await hasUserCompletedToday(null);
  }

  static Future<bool> isNewDay() async {
    return await isNewDayForUser(null);
  }

  static Future<int> getHintCards() async {
    return await getUserHintCards(null);
  }

  static Future<void> addHintCardToUser() async {
    await addHintCard(null);
  }
}
