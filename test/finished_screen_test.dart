import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/models/story.dart';
import 'package:kotonoha/screens/finished_screen.dart';

const _story = Story(
  id: 'sangetsuki',
  title: '山月記 元エリート、虎になる',
  originalTitle: '山月記',
  author: '中島敦',
  tag: '漢文',
  pages: ['1ページ目', '2ページ目'],
);

void main() {
  testWidgets('読了メッセージと各ボタンが表示される', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FinishedScreen(story: _story)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('読了おめでとうございます'), findsOneWidget);
    expect(find.text('続けてもう1話読む'), findsOneWidget);
    expect(find.text('ランダムでもう1話読む'), findsOneWidget);
    expect(find.text('物語一覧に戻る'), findsOneWidget);
    expect(find.text('タイトルに戻る'), findsOneWidget);
    // コラムの無い物語ではコラムボタンは出ない。
    expect(find.textContaining('コラムを見る'), findsNothing);
  });

  testWidgets('タイトルに戻るタップでクラッシュしない', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FinishedScreen(story: _story)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('タイトルに戻る'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
