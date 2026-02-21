import '../repositories/pantry_repository.dart';

class RemoveFromPantry {
  RemoveFromPantry(this._repository);

  final PantryRepository _repository;

  Future<void> call(String id) => _repository.remove(id);
}
