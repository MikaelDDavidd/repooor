import 'package:sqflite/sqflite.dart';
import '../../core/utils/string_normalizer.dart';

/// Funde produtos que ficaram duplicados por causa do matcher antigo
/// (dois "Arroz", dois "Feijão"...). Roda uma vez, na migração.
///
/// O vencedor de cada grupo é o que já tem item na despensa; havendo empate,
/// o que tem mais histórico de compra. Todo o histórico dos perdedores é
/// reapontado antes de removê-los, então nada de compra se perde.
class DuplicateProductMerger {
  DuplicateProductMerger._();

  static Future<int> run(Database db) async {
    if (!await _hasTables(db, const [
      'products',
      'pantry_items',
      'purchase_items',
    ])) {
      return 0;
    }
    final products = await db.query('products', columns: ['id', 'name']);
    final groups = <String, List<String>>{};
    for (final row in products) {
      final key = StringNormalizer.normalize(row['name'] as String);
      if (key.isEmpty) continue;
      groups.putIfAbsent(key, () => []).add(row['id'] as String);
    }

    var merged = 0;
    for (final ids in groups.values) {
      if (ids.length < 2) continue;
      final winner = await _pickWinner(db, ids);
      final losers = ids.where((id) => id != winner).toList();
      for (final loser in losers) {
        await _absorb(db, winner: winner, loser: loser);
        merged++;
      }
    }
    return merged;
  }

  static Future<bool> _hasTables(Database db, List<String> names) async {
    for (final name in names) {
      final found = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [name],
      );
      if (found.isEmpty) return false;
    }
    return true;
  }

  static Future<String> _pickWinner(Database db, List<String> ids) async {
    String? withPantry;
    var bestId = ids.first;
    var bestUses = -1;
    for (final id in ids) {
      final pantry = await db.query(
        'pantry_items',
        where: 'product_id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (pantry.isNotEmpty && withPantry == null) withPantry = id;
      final uses = await db.rawQuery(
        'SELECT COUNT(*) c FROM purchase_items WHERE product_id = ?',
        [id],
      );
      final count = (uses.first['c'] as num).toInt();
      if (count > bestUses) {
        bestUses = count;
        bestId = id;
      }
    }
    return withPantry ?? bestId;
  }

  static Future<void> _absorb(
    Database db, {
    required String winner,
    required String loser,
  }) async {
    await db.update(
      'purchase_items',
      {'product_id': winner},
      where: 'product_id = ?',
      whereArgs: [loser],
    );

    final loserPantry = await db.query(
      'pantry_items',
      where: 'product_id = ?',
      whereArgs: [loser],
    );
    if (loserPantry.isNotEmpty) {
      final winnerPantry = await db.query(
        'pantry_items',
        where: 'product_id = ?',
        whereArgs: [winner],
      );
      final loserCurrent = (loserPantry.first['current_quantity'] as num)
          .toDouble();
      final loserIdeal = (loserPantry.first['ideal_quantity'] as num)
          .toDouble();
      if (winnerPantry.isEmpty) {
        await db.update(
          'pantry_items',
          {'product_id': winner},
          where: 'product_id = ?',
          whereArgs: [loser],
        );
      } else {
        final current = (winnerPantry.first['current_quantity'] as num)
            .toDouble();
        final ideal = (winnerPantry.first['ideal_quantity'] as num).toDouble();
        await db.update(
          'pantry_items',
          {
            'current_quantity': current + loserCurrent,
            'ideal_quantity': ideal > loserIdeal ? ideal : loserIdeal,
          },
          where: 'id = ?',
          whereArgs: [winnerPantry.first['id']],
        );
        await db.delete(
          'pantry_items',
          where: 'product_id = ?',
          whereArgs: [loser],
        );
      }
    }

    await db.delete('products', where: 'id = ?', whereArgs: [loser]);
  }
}
