import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:islami/main.dart';
import 'package:islami/dezeen/shiar.dart';

void main() {
  testWidgets('Islami app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
