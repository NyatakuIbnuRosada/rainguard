import 'package:shared_preferences/shared_preferences.dart';
import 'session_service.dart';

class PremiumService {
  static DateTime? expiredAt;

  static String _key() =>
      'premium_expired_at_user_${SessionService.userId}';

  static Future<void> resetMemory() async {
    expiredAt = null;
  }

  static Future<void> loadPremium() async {
    try {
      if (SessionService.userId == null) {
        expiredAt = null;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_key());

      if (str == null) {
        expiredAt = null;
        return;
      }

      // 🔥 ANTI CRASH
      expiredAt = DateTime.tryParse(str);
    } catch (e) {
      print('LOAD PREMIUM ERROR: $e');
      expiredAt = null;
    }
  }

  static Future<void> setPremiumFromServer(DateTime date) async {
    try {
      if (SessionService.userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      expiredAt = date;
      await prefs.setString(_key(), date.toIso8601String());
    } catch (e) {
      print('SET PREMIUM ERROR: $e');
    }
  }

  static Future<void> buyPremium() async {
    try {
      if (SessionService.userId == null) return;

      expiredAt = DateTime.now().add(const Duration(minutes: 2));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(), expiredAt!.toIso8601String());
    } catch (e) {
      print('BUY PREMIUM ERROR: $e');
    }
  }

  static bool isPremiumActive() {
    if (expiredAt == null) return false;
    return DateTime.now().isBefore(expiredAt!);
  }

  static int remainingSeconds() {
    if (!isPremiumActive()) return 0;
    return expiredAt!.difference(DateTime.now()).inSeconds;
  }
}
