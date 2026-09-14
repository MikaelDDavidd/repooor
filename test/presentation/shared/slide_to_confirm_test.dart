import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repooor/presentation/shared/widgets/slide_confirm_dialog.dart';
import 'package:repooor/presentation/shared/widgets/slide_to_confirm.dart';

void main() {
  Future<void> pumpSlider(WidgetTester tester, VoidCallback onConfirmed) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SlideToConfirm(
              label: 'Arraste para desmarcar',
              onConfirmed: onConfirmed,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('SlideToConfirm', () {
    testWidgets('does not confirm on a simple tap', (tester) async {
      var confirmed = false;
      await pumpSlider(tester, () => confirmed = true);

      await tester.tap(find.byType(SlideToConfirm));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('does not confirm on a short drag', (tester) async {
      var confirmed = false;
      await pumpSlider(tester, () => confirmed = true);

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('does not confirm at half the track', (tester) async {
      var confirmed = false;
      await pumpSlider(tester, () => confirmed = true);

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(140, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('confirms when dragged to the end', (tester) async {
      var confirmed = false;
      await pumpSlider(tester, () => confirmed = true);

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('shows a check after confirming', (tester) async {
      await pumpSlider(tester, () {});

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('confirms only once even with repeated drags', (tester) async {
      var count = 0;
      await pumpSlider(tester, () => count++);

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byIcon(Icons.check), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(count, 1);
    });

    testWidgets('ignores a backwards drag', (tester) async {
      var confirmed = false;
      await pumpSlider(tester, () => confirmed = true);

      await tester.drag(
        find.byIcon(Icons.chevron_right),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('does not overflow', (tester) async {
      await pumpSlider(tester, () {});
      expect(tester.takeException(), isNull);
    });
  });

  group('SlideConfirmDialog', () {
    Future<bool?> showDialogAndDrag(
      WidgetTester tester,
      double distance,
    ) async {
      bool? result;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await SlideConfirmDialog.show(
                    context,
                    title: 'Tirar do carrinho?',
                    message: 'Arraste para confirmar.',
                    slideLabel: 'Arraste para desmarcar',
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

      if (distance != 0) {
        await tester.drag(
          find.byIcon(Icons.chevron_right),
          Offset(distance, 0),
        );
        await tester.pumpAndSettle();
      }
      return result;
    }

    testWidgets('returns true only after a full drag', (tester) async {
      expect(await showDialogAndDrag(tester, 400), isTrue);
    });

    testWidgets('stays open on a partial drag', (tester) async {
      final result = await showDialogAndDrag(tester, 80);

      expect(result, isNull);
      expect(find.text('Tirar do carrinho?'), findsOneWidget);
    });

    testWidgets('returns false when keeping the item', (tester) async {
      await showDialogAndDrag(tester, 0);

      await tester.tap(find.text('Manter marcado'));
      await tester.pumpAndSettle();

      expect(find.text('Tirar do carrinho?'), findsNothing);
    });
  });
}
