import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_ds.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(this._dataSource);

  final PreferencesLocalDs _dataSource;

  @override
  Future<bool> getHasSeenOnboarding() => _dataSource.getHasSeenOnboarding();

  @override
  Future<void> setHasSeenOnboarding(bool value) =>
      _dataSource.setHasSeenOnboarding(value);
}
