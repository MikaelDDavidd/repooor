import '../repositories/data_export_repository.dart';

class ClearAllData {
  ClearAllData(this._repository);

  final DataExportRepository _repository;

  Future<void> call() => _repository.clearAll();
}
