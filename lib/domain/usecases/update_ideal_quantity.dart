import '../repositories/pantry_repository.dart';

class UpdateIdealQuantity {
  UpdateIdealQuantity(this._repository);

  final PantryRepository _repository;

  Future<void> call(String id, double idealQuantity) =>
      _repository.updateIdealQuantity(id, idealQuantity);
}
