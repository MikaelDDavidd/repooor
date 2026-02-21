import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repooor/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RepooorApp()));
    expect(find.text('Repooor'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
