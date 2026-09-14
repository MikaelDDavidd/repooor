import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repooor/main.dart';
import 'package:repooor/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const RepooorApp(),
      ),
    );
    expect(find.text('Repooor'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
