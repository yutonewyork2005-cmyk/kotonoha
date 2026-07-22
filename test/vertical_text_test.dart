import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/widgets/vertical_text.dart';

void main() {
  testWidgets('各文字が1つずつ表示され、空行は列間の余白になる', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: VerticalText(text: 'こんにちは\n\n「元気？」'),
          ),
        ),
      ),
    );

    for (final ch in 'こんにちは元気'.runes.map(String.fromCharCode)) {
      expect(find.text(ch), findsOneWidget);
    }
    // 長音記号などの回転対象文字も個別の文字として表示される。
    expect(find.text('「'), findsOneWidget);
    expect(find.text('」'), findsOneWidget);
    expect(find.text('？'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('長音記号は回転して表示される', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: VerticalText(text: 'コーヒー'),
          ),
        ),
      ),
    );

    final rotated = tester.widgetList<Transform>(find.byType(Transform));
    expect(rotated, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
