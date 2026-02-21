abstract class DataExportRepository {
  Future<Map<String, dynamic>> exportAll();
  Future<void> importAll(Map<String, dynamic> data);
  Future<void> clearAll();
}
