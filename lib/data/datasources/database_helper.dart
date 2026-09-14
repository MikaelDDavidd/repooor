import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_migrations.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'repooor.db');
    return openDatabase(
      path,
      version: DatabaseMigrations.currentVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }
}
