import 'package:sqflite/sqflite.dart';
import 'duplicate_product_merger.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static const currentVersion = 7;

  static const syncedTables = [
    'categories',
    'products',
    'pantry_items',
    'purchases',
    'purchase_items',
  ];

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE purchase_items ADD COLUMN unit_price REAL');
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE purchases ADD COLUMN status TEXT NOT NULL DEFAULT 'completed'",
      );
      await db.execute(
        'ALTER TABLE purchase_items ADD COLUMN planned_quantity REAL',
      );
      await db.execute(
        'ALTER TABLE purchase_items ADD COLUMN planned_unit_price REAL',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE purchase_items ADD COLUMN picked INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      // Uma falha na limpeza não pode impedir o app de abrir: os dados
      // seguem utilizáveis com os duplicados.
      try {
        await DuplicateProductMerger.run(db);
      } catch (_) {}
    }
    if (oldVersion < 6) {
      // Limpa itens de compras que foram deletadas antes do delete em cascata
      // ser feito à mão (o sqflite não liga PRAGMA foreign_keys).
      try {
        await db.delete(
          'purchase_items',
          where: 'purchase_id NOT IN (SELECT id FROM purchases)',
        );
      } catch (_) {}
    }
    if (oldVersion < 7) {
      // Sem as colunas de sync o app continua funcionando 100% local, como era
      // até a v6 — melhor isso do que não abrir.
      try {
        await _addSyncColumns(db);
        await createSyncTables(db);
        await backfillUpdatedAt(db);
      } catch (_) {}
    }
  }

  static Future<void> _addSyncColumns(Database db) async {
    for (final table in syncedTables) {
      await _addColumnIfMissing(db, table, 'updated_at');
      await _addColumnIfMissing(db, table, 'deleted_at');
    }
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final existing = info.map((row) => row['name'] as String);
    if (existing.contains(column)) return;
    await db.execute('ALTER TABLE $table ADD COLUMN $column INTEGER');
  }

  static Future<void> createSyncTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id TEXT PRIMARY KEY,
        entity TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        op TEXT NOT NULL,
        payload TEXT,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_state (
        entity TEXT PRIMARY KEY,
        last_pulled_at INTEGER
      )
    ''');
  }

  static Future<void> backfillUpdatedAt(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final table in syncedTables) {
      await db.update(table, {'updated_at': now}, where: 'updated_at IS NULL');
    }
  }

  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        updated_at INTEGER,
        deleted_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        unit TEXT NOT NULL,
        updated_at INTEGER,
        deleted_at INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    batch.execute('''
      CREATE TABLE pantry_items (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL UNIQUE,
        current_quantity REAL NOT NULL DEFAULT 0,
        ideal_quantity REAL NOT NULL DEFAULT 0,
        updated_at INTEGER,
        deleted_at INTEGER,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    batch.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'completed',
        updated_at INTEGER,
        deleted_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE purchase_items (
        id TEXT PRIMARY KEY,
        purchase_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL,
        planned_quantity REAL,
        planned_unit_price REAL,
        picked INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER,
        deleted_at INTEGER,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await batch.commit(noResult: true);
    await createSyncTables(db);
  }
}
