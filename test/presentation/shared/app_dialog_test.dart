import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/core/theme/app_colors.dart';
import 'package:repooor/presentation/shared/widgets/app_dialog.dart';
import 'package:repooor/presentation/shared/widgets/app_sheet.dart';
import 'package:repooor/presentation/shared/widgets/confirm_dialog.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: dialog)));
    await tester.pump();
  }

  group('AppDialog', () {
    testWidgets('renders title, message and icon', (tester) async {
      await pumpDialog(
        tester,
        const AppDialog(
          title: 'Título',
          message: 'Mensagem de apoio',
          icon: Icons.help_outline,
        ),
      );

      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Mensagem de apoio'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('uses rounded corners consistently', (tester) async {
      await pumpDialog(tester, const AppDialog(title: 'Título'));

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      final shape = dialog.shape as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('destructive tone paints the primary action red', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: 'Apagar',
          tone: AppDialogTone.destructive,
          primaryAction: AppDialogAction(
            label: 'Apagar',
            tone: AppDialogTone.destructive,
            onPressed: () {},
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final background = button.style!.backgroundColor!.resolve({});

      expect(background, AppColors.error);
    });

    testWidgets('renders custom content between message and actions', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        const AppDialog(title: 'Título', content: Text('conteúdo customizado')),
      );

      expect(find.text('conteúdo customizado'), findsOneWidget);
    });

    testWidgets('works without icon, message or actions', (tester) async {
      await pumpDialog(tester, const AppDialog(title: 'Só título'));

      expect(find.text('Só título'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long text does not overflow', (tester) async {
      await pumpDialog(
        tester,
        const AppDialog(
          title: 'Um título bastante longo para testar o limite do dialog',
          message:
              'Uma mensagem longa o suficiente para ocupar várias linhas dentro do dialog e verificar que nada estoura na horizontal nem na vertical.',
          icon: Icons.warning_amber_rounded,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('ConfirmDialog', () {
    testWidgets('is built on top of AppDialog', (tester) async {
      await pumpDialog(
        tester,
        const ConfirmDialog(title: 'Confirmar?', content: 'Detalhe'),
      );

      expect(find.byType(AppDialog), findsOneWidget);
    });

    testWidgets('destructive variant shows a warning icon', (tester) async {
      await pumpDialog(
        tester,
        const ConfirmDialog(
          title: 'Remover',
          content: 'Detalhe',
          isDestructive: true,
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('returns true on confirm and false on cancel', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ConfirmDialog.show(
                    context,
                    title: 'Confirmar?',
                    content: 'Detalhe',
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });

  group('AppSheet', () {
    testWidgets('shows the handle and the title', (tester) async {
      await pumpDialog(
        tester,
        const AppSheet(title: 'Nova compra', child: Text('corpo')),
      );

      expect(find.text('Nova compra'), findsOneWidget);
      expect(find.text('corpo'), findsOneWidget);
    });

    testWidgets('subtitle is optional', (tester) async {
      await pumpDialog(
        tester,
        const AppSheet(
          title: 'Nova compra',
          subtitle: 'Escolha o tipo',
          child: Text('corpo'),
        ),
      );

      expect(find.text('Escolha o tipo'), findsOneWidget);
    });

    testWidgets('renders without a title', (tester) async {
      await pumpDialog(tester, const AppSheet(child: Text('corpo')));

      expect(find.text('corpo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
