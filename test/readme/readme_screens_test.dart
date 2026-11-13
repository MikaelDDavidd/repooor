// Gera as telas do README a partir do app real, com dados fictícios.
//
//   README_SCREENS=1 flutter test test/readme
//
// Os PNGs saem em build/readme_screens/ (ou em README_SCREENS_DIR). Fica fora da
// suíte normal: sem README_SCREENS, o teste é pulado.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:repooor/core/di/providers.dart';
import 'package:repooor/core/routes/app_router.dart';
import 'package:repooor/core/theme/app_text_styles.dart';
import 'package:repooor/core/theme/app_theme.dart';
import 'package:repooor/data/sync/sync_status.dart';
import 'package:repooor/domain/entities/auth/app_user.dart';
import 'package:repooor/domain/entities/pantry_item.dart';
import 'package:repooor/domain/entities/product.dart';
import 'package:repooor/domain/entities/purchase.dart';
import 'package:repooor/domain/entities/purchase_item.dart';
import 'package:repooor/presentation/pantry/pantry_page.dart';
import 'package:repooor/presentation/projection/market_projection_page.dart';
import 'package:repooor/presentation/providers/auth_providers.dart';
import 'package:repooor/presentation/providers/nfce_providers.dart';
import 'package:repooor/presentation/providers/sync_providers.dart';

const _logical = Size(393, 852);
const _ratio = 3.0;

final _outDir =
    Platform.environment['README_SCREENS_DIR'] ?? 'build/readme_screens';

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT']!;
  final dir = p.join(root, 'bin', 'cache', 'artifacts', 'material_fonts');
  final roboto = FontLoader('Roboto');
  for (final w in ['Light', 'Regular', 'Medium', 'Bold', 'Black']) {
    final bytes = File(p.join(dir, 'Roboto-$w.ttf')).readAsBytesSync();
    roboto.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  // Roboto não tem peso 600 estático e o tema usa w600 em títulos e botões;
  // é o Bold marcado como 600 (gerado com fontTools, mesma licença Apache 2.0).
  roboto.addFont(
    Future.value(
      ByteData.view(
        File('test/readme/fonts/Roboto-SemiBold.ttf').readAsBytesSync().buffer,
      ),
    ),
  );
  await roboto.load();
  // Estilos sem fontFamily (títulos e botões em w600) caem na fonte padrão do
  // flutter_test, que desenha caixas. No aparelho eles usam a fonte do sistema;
  // aqui o Roboto faz esse papel.
  final fallback = FontLoader('FlutterTest');
  for (final f in [
    p.join(dir, 'Roboto-Medium.ttf'),
    'test/readme/fonts/Roboto-SemiBold.ttf',
    p.join(dir, 'Roboto-Bold.ttf'),
  ]) {
    fallback.addFont(
      Future.value(ByteData.view(File(f).readAsBytesSync().buffer)),
    );
  }
  await fallback.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.view(
          File(
            p.join(dir, 'MaterialIcons-Regular.otf'),
          ).readAsBytesSync().buffer,
        ),
      ),
    );
  await icons.load();
}

/// Lê o primeiro produto do catálogo padrão cujo nome começa com [prefix].
Product _pick(List<Product> all, String prefix) => all.firstWhere(
  (x) => x.name.startsWith(prefix),
  orElse: () => all.firstWhere((x) => x.name.contains(prefix)),
);

Future<void> _seed(ProviderContainer c) async {
  await c.read(seedDefaultCategoriesProvider).call();
  final cats = await c.read(getAllCategoriesProvider).call();
  await c.read(seedDefaultProductsProvider).call(cats);
  final all = await c.read(getAllProductsProvider).call();

  // produto, tenho, quero, preço médio
  final pantry = <(String, double, double, double)>[
    ('Arroz Branco Tipo 1', 1, 4, 27.90),
    ('Feijão Carioca', 1, 4, 8.49),
    ('Leite Integral', 4, 12, 5.29),
    ('Pão de Forma', 1, 2, 8.99),
    ('Café em Pó', 1, 2, 18.90),
    ('Óleo de Soja', 1, 2, 7.99),
    ('Açúcar', 2, 2, 4.79),
    ('Macarrão Espaguete', 3, 4, 4.29),
    ('Banana Prata', 2, 6, 6.99),
    ('Tomate Salada', 1, 2, 7.49),
    ('Peito de Frango', 0, 2, 19.90),
    ('Queijo Mussarela', 1, 1, 49.90),
    ('Detergente', 2, 5, 2.79),
    ('Papel Higiênico 12', 1, 2, 19.90),
  ];

  final products = [for (final row in pantry) _pick(all, row.$1)];
  for (var i = 0; i < pantry.length; i++) {
    await c
        .read(addToPantryProvider)
        .call(
          PantryItem(
            id: 'pi$i',
            productId: products[i].id,
            currentQuantity: pantry[i].$2,
            idealQuantity: pantry[i].$3,
          ),
        );
  }

  // Compras do mês dos últimos quatro meses, com o preço subindo um pouco.
  final now = DateTime.now();
  for (var m = 3; m >= 0; m--) {
    final id = 'pu$m';
    final date = DateTime(now.year, now.month - m, 4, 10);
    await c
        .read(createPurchaseProvider)
        .call(Purchase(id: id, date: date, type: PurchaseType.main));
    for (var i = 0; i < pantry.length; i++) {
      final want = pantry[i].$3 - (i % 3 == 0 ? 1 : 0);
      await c
          .read(addPurchaseItemProvider)
          .call(
            PurchaseItem(
              id: '$id-$i',
              purchaseId: id,
              productId: products[i].id,
              quantity: want <= 0 ? 1 : want,
              unitPrice: double.parse(
                (pantry[i].$4 * (1 - 0.02 * m)).toStringAsFixed(2),
              ),
            ),
          );
    }
  }
}

const _receipt = r'''
<html><body>
<div id="u20">
  <span class="txtTopo">MERCADO BOA COMPRA LTDA</span>
  <div class="text">CNPJ: 00.000.000/0001-00</div>
  <div class="text">Av. Exemplo, 500 - Recife/PE</div>
</div>
<ul class="ui-Page"><li><strong>Emissão:</strong> 11/11/2026 18:42:30 - Via Consumidor</li></ul>
<table id="tabResult">
  <tr><td class="txtTit"><span class="txtTit2">ARROZ TIPO 1 5KG</span> (Código: 7890000000001)</td><td>Qtde.: 2 UN: UN Vl. Unit.: 27,90</td><td class="txtTit">Vl. Total 55,80</td></tr>
  <tr><td class="txtTit"><span class="txtTit2">FEIJAO CARIOCA TIPO 1 1KG</span> (Código: 7890000000002)</td><td>Qtde.: 3 UN: UN Vl. Unit.: 8,49</td><td class="txtTit">Vl. Total 25,47</td></tr>
  <tr><td class="txtTit"><span class="txtTit2">LEITE INTEGRAL UHT 1L</span> (Código: 7890000000003)</td><td>Qtde.: 8 UN: UN Vl. Unit.: 5,29</td><td class="txtTit">Vl. Total 42,32</td></tr>
  <tr><td class="txtTit"><span class="txtTit2">BANANA PRATA KG</span> (Código: 7890000000004)</td><td>Qtde.: 1,250 UN: KG Vl. Unit.: 6,99</td><td class="txtTit">Vl. Total 8,74</td></tr>
  <tr><td class="txtTit"><span class="txtTit2">DETERGENTE LIQUIDO 500ML</span> (Código: 7890000000005)</td><td>Qtde.: 3 UN: UN Vl. Unit.: 2,79</td><td class="txtTit">Vl. Total 8,37</td></tr>
  <tr><td class="txtTit"><span class="txtTit2">MOLHO DE TOMATE TRADICIONAL 340G</span> (Código: 7890000000006)</td><td>Qtde.: 2 UN: UN Vl. Unit.: 3,49</td><td class="txtTit">Vl. Total 6,98</td></tr>
</table>
<div id="totalNota"><strong>Valor a pagar R$:</strong> 147,68</div>
</body></html>
''';

/// O tema do app com 'Roboto' nos estilos que não dizem a fonte. No aparelho eles
/// usam a fonte do sistema; no flutter_test, sem isso, viram caixas.
ThemeData _theme() {
  final t = AppTheme.light;
  TextStyle r(TextStyle? s) =>
      (s ?? const TextStyle()).copyWith(fontFamily: 'Roboto');
  return t.copyWith(
    appBarTheme: t.appBarTheme.copyWith(
      titleTextStyle: r(t.appBarTheme.titleTextStyle),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: t.elevatedButtonTheme.style!.copyWith(
        textStyle: WidgetStatePropertyAll(r(AppTextStyles.button)),
      ),
    ),
    chipTheme: t.chipTheme.copyWith(labelStyle: r(t.chipTheme.labelStyle)),
    bottomNavigationBarTheme: t.bottomNavigationBarTheme.copyWith(
      selectedLabelStyle: r(t.bottomNavigationBarTheme.selectedLabelStyle),
      unselectedLabelStyle: r(t.bottomNavigationBarTheme.unselectedLabelStyle),
    ),
  );
}

Future<void> _settle(WidgetTester tester, [int rounds = 40]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _shot(WidgetTester tester, GlobalKey key, String name) async {
  await _settle(tester);
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _ratio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(p.join(_outDir, '$name.png'))
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    await _loadFonts();
  });

  testWidgets(
    'README screens',
    skip: Platform.environment['README_SCREENS'] == null,
    (tester) async {
      // flutter_test troca sombra por contorno preto; aqui queremos a sombra real.
      debugDisableShadows = false;
      tester.view.physicalSize = _logical * _ratio;
      tester.view.devicePixelRatio = _ratio;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (_) => Stream.value(
              const AppUser(id: 'demo', email: 'demo@example.com', name: 'Ana'),
            ),
          ),
          syncStatusProvider.overrideWith(
            (_) => Stream.value(const SyncStatus()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await databaseFactory.deleteDatabase(
          p.join(await databaseFactory.getDatabasesPath(), 'repooor.db'),
        );
        await _seed(container);
      });

      final key = GlobalKey();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: key,
            child: MaterialApp.router(
              theme: _theme(),
              debugShowCheckedModeBanner: false,
              routerConfig: container.read(routerProvider),
            ),
          ),
        ),
      );
      final router = container.read(routerProvider);

      router.go('/home');
      await _shot(tester, key, '1-home');

      router.go('/pantry');
      await _shot(tester, key, '2-pantry');

      Navigator.of(tester.element(find.byType(PantryPage))).push(
        MaterialPageRoute<void>(builder: (_) => const MarketProjectionPage()),
      );
      await _shot(tester, key, '3-projection');
      Navigator.of(tester.element(find.byType(MarketProjectionPage))).pop();
      await _settle(tester, 10);

      await tester.runAsync(
        () => container
            .read(nfceImportProvider.notifier)
            .loadMockHtml(uf: 'PE', chave: '2' * 44, html: _receipt),
      );
      router.push('/nfce/review');
      await _shot(tester, key, '4-receipt-review');

      router.go('/analytics');
      await _shot(tester, key, '5-analytics');

      debugDisableShadows = true;
    },
  );
}
