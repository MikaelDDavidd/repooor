abstract class PreferencesRepository {
  Future<bool> getHasSeenOnboarding();
  Future<void> setHasSeenOnboarding(bool value);
}
