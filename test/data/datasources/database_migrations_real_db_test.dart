import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/data/datasources/database_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Valida a migração contra um banco real extraído do aparelho, que o banco
// sintético não cobre (ids de verdade, nulos, linhas órfãs).
//
//   REPOOOR_REAL_DB=/caminho/repooor.db flutter test \
//     test/data/datasources/database_migrations_real_db_test.dart
//
// Sem a variável o teste é pulado. O arquivo apontado nunca é alterado: a
// migração roda sempre sobre uma cópia temporária.
void main() {
  final source = Platform.environment['REPOOOR_REAL_DB'];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'upgrades a real device database to v7 without losing a row',
    () async {
      final original = File(source!);
      final copy = original.copySync(
        '${Directory.systemTemp.createTempSync('repooor_real').path}/copy.db',
      );
      addTearDown(() => copy.parent.deleteSync(recursive: true));

      final db = await databaseFactory.openDatabase(copy.path);
      addTearDown(db.close);

      Future<int> countOf(String table) async {
        final rows = await db.rawQuery('SELECT COUNT(*) FROM $table');
        return rows.first.values.first as int;
      }

      final before = {
        for (final table in DatabaseMigrations.syncedTables)
          table: await countOf(table),
      };
      final version =
          (await db.rawQuery('PRAGMA user_version')).first.values.first as int;

      await DatabaseMigrations.onUpgrade(db, version, 7);

      for (final table in DatabaseMigrations.syncedTables) {
        expect(await countOf(table), before[table], reason: 'tabela $table');

        final info = await db.rawQuery('PRAGMA table_info($table)');
        final columns = info.map((row) => row['name'] as String).toSet();
        expect(columns, containsAll(['updated_at', 'deleted_at']));

        final missing = await db.rawQuery(
          'SELECT COUNT(*) FROM $table WHERE updated_at IS NULL',
        );
        expect(
          missing.first.values.first,
          0,
          reason: 'tabela $table ficou com updated_at nulo',
        );
      }

      final integrity = await db.rawQuery('PRAGMA integrity_check');
      expect(integrity.first.values.first, 'ok');
    },
    skip: source == null ? 'defina REPOOOR_REAL_DB para rodar' : null,
  );
}
