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
  testWidgets('背景イラストとタップ領域が表示される', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FinishedScreen(story: _story)),
    );
    await tester.pumpAndSettle();

    // 背景画像が読み込まれている
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/finished_bg.png',
    );

    // 5つのタップ領域 (Material+InkWell) が配置されている
    expect(find.byType(InkWell), findsNWidgets(5));
  });

  testWidgets('タイトル画面に戻るタップでクラッシュしない', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FinishedScreen(story: _story)),
    );
    await tester.pumpAndSettle();

    // 一番左下の丸ボタン (タイトル画面に戻る) をタップ
    final size = tester.getSize(find.byType(AspectRatio));
    final topLeft = tester.getTopLeft(find.byType(AspectRatio));
    await tester.tapAt(
      topLeft + Offset(size.width * 0.31, size.height * 0.74),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FinishedScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
