import '../entities/pantry_item.dart';
import '../repositories/pantry_repository.dart';

class GetPantryItems {
  GetPantryItems(this._repository);

  final PantryRepository _repository;

  Future<List<PantryItem>> call() => _repository.getAll();
}
