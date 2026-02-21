import '../entities/pantry_item.dart';
import '../repositories/pantry_repository.dart';

class AddToPantry {
  AddToPantry(this._repository);

  final PantryRepository _repository;

  Future<void> call(PantryItem item) => _repository.add(item);
}
