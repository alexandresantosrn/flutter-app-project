import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  static const _kNotifications = 'notifications_enabled';
  static const _kNotificationTime = 'notification_time';
  static const _kDarkMode = 'dark_mode';
  static const _kDailyLessonSize = 'daily_lesson_size';
  static const _kLanguage = 'language';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get notificationsEnabled =>
      _prefs.getBool(_kNotifications) ?? true;
  static Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_kNotifications, v);

  static String get notificationTime =>
      _prefs.getString(_kNotificationTime) ?? '08:00';
  static Future<void> setNotificationTime(String v) =>
      _prefs.setString(_kNotificationTime, v);

  static bool get darkMode => _prefs.getBool(_kDarkMode) ?? false;
  static Future<void> setDarkMode(bool v) => _prefs.setBool(_kDarkMode, v);

  static int get dailyLessonSize => _prefs.getInt(_kDailyLessonSize) ?? 10;
  static Future<void> setDailyLessonSize(int v) =>
      _prefs.setInt(_kDailyLessonSize, v);

  static String get language => _prefs.getString(_kLanguage) ?? 'Inglês';
  static Future<void> setLanguage(String v) => _prefs.setString(_kLanguage, v);
}
