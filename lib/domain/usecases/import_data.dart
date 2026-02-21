import '../repositories/data_export_repository.dart';

class ImportData {
  ImportData(this._repository);

  final DataExportRepository _repository;

  Future<void> call(Map<String, dynamic> data) => _repository.importAll(data);
}
