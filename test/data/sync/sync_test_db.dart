import 'package:repooor/data/datasources/database_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openSyncTestDatabase() {
  return databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      singleInstance: false,
      version: DatabaseMigrations.currentVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    ),
  );
}

Future<void> seedProduct(
  Database db,
  String id, {
  String name = 'Arroz',
  String categoryId = 'cat-1',
  String unit = 'kg',
  int updatedAt = 1750000000000,
}) {
  return db.insert('products', {
    'id': id,
    'name': name,
    'category_id': categoryId,
    'unit': unit,
    'updated_at': updatedAt,
  });
}

Future<void> seedCategory(
  Database db,
  String id, {
  String name = 'Mercearia',
  int updatedAt = 1750000000000,
}) {
  return db.insert('categories', {
    'id': id,
    'name': name,
    'icon': 100,
    'color': 200,
    'updated_at': updatedAt,
  });
}
