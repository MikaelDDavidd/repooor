import 'package:shared_preferences/shared_preferences.dart';

class PreferencesLocalDs {
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, value);
  }
}
