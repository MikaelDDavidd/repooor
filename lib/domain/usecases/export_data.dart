import '../repositories/data_export_repository.dart';

class ExportData {
  ExportData(this._repository);

  final DataExportRepository _repository;

  Future<Map<String, dynamic>> call() => _repository.exportAll();
}
