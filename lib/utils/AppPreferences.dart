import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception("SharedPreferences not initialized. Call init() first.");
    }
    return _prefs!;
  }

  static const String LOGGED_IN_USER = "logged_in_user";
  static const String FIRST_TIME = "first_time";
  static const String IS_LOGGED_IN = "is_logged_in";
  static const String IS_ONBOARDING_COMPLETED = "is_onboarding_completed";

  static Future<void> clearAllPreferences() async {
    final prefs = instance;
    await prefs.clear();
  }

  static Future<void> setPreference<T>(String key, T value) async {
    final prefs = instance;
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
    // Add more type checks as needed
  }

  static Future<T?> getPreference<T>(String key) async {
    final prefs = instance;

    if (T == int && prefs.containsKey(key)) {
      return prefs.getInt(key) as T?;
    } else if (T == double && prefs.containsKey(key)) {
      return prefs.getDouble(key) as T?;
    } else if (T == bool && prefs.containsKey(key)) {
      return prefs.getBool(key) as T?;
    } else if (T == String && prefs.containsKey(key)) {
      return prefs.getString(key) as T?;
    } else if (T == (List<String>) && prefs.containsKey(key)) {
      return prefs.getStringList(key) as T?;
    }

    // Handle other types if needed
    return null;
  }

  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await setPreference<bool>(IS_LOGGED_IN, isLoggedIn);
  }

  static bool get isLoggedIn {
    bool? value = getPreference<bool>(IS_LOGGED_IN) as bool?;
    return value ?? false;
  }

  static Future<void> setOnboardingCompleted(bool isOnboardingCompleted) async {
    await setPreference<bool>(IS_ONBOARDING_COMPLETED, isOnboardingCompleted);
  }

  static bool get isOnboardingCompleted {
    bool? value = getPreference<bool>(IS_ONBOARDING_COMPLETED) as bool?;
    return value ?? false;
  }

  static Future<void> onLogout() async {
    await clearAllPreferences();
  }

// Add more methods as needed based on your requirements
}
