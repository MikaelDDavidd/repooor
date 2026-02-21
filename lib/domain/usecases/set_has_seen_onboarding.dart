import '../repositories/preferences_repository.dart';

class SetHasSeenOnboarding {
  SetHasSeenOnboarding(this._repository);

  final PreferencesRepository _repository;

  Future<void> call(bool value) => _repository.setHasSeenOnboarding(value);
}
