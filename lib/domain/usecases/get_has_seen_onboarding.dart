import '../repositories/preferences_repository.dart';

class GetHasSeenOnboarding {
  GetHasSeenOnboarding(this._repository);

  final PreferencesRepository _repository;

  Future<bool> call() => _repository.getHasSeenOnboarding();
}
