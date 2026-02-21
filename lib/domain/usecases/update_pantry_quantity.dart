import '../repositories/pantry_repository.dart';

class UpdatePantryQuantity {
  UpdatePantryQuantity(this._repository);

  final PantryRepository _repository;

  Future<void> call(String id, double currentQuantity) =>
      _repository.updateQuantity(id, currentQuantity);
}
