import '../../domain/repositories/data_export_repository.dart';
import '../datasources/data_export_local_ds.dart';

class DataExportRepositoryImpl implements DataExportRepository {
  DataExportRepositoryImpl(this._dataSource);

  final DataExportLocalDs _dataSource;

  @override
  Future<Map<String, dynamic>> exportAll() => _dataSource.exportAll();

  @override
  Future<void> importAll(Map<String, dynamic> data) =>
      _dataSource.importAll(data);

  @override
  Future<void> clearAll() => _dataSource.clearAll();
}
