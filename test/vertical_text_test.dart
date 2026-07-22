import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/widgets/vertical_text.dart';

void main() {
  group('VerticalTextPaginator', () {
    test('画面に収まる場合は1画面になる', () {
      final pages = VerticalTextPaginator.paginate(
        text: 'こんにちは\n\n「元気？」',
        cellSize: 40,
        viewportSize: const Size(400, 400),
      );
      expect(pages.length, 1);
      // 最初の行(こんにちは)が一番右(最後の要素)に来る。
      expect(pages.first.columns.last, ['こ', 'ん', 'に', 'ち', 'は']);
    });

    test('画面の高さを超える行は左隣の列に折り返す', () {
      final pages = VerticalTextPaginator.paginate(
        text: 'あいうえおかきくけこ',
        cellSize: 40,
        viewportSize: const Size(400, 200), // 高さ200 / 40 = 5行分
      );
      expect(pages.first.columns.length, 2);
      expect(pages.first.columns.last, ['あ', 'い', 'う', 'え', 'お']);
      expect(pages.first.columns.first, ['か', 'き', 'く', 'け', 'こ']);
    });

    test('画面の幅を超える列数は複数画面に分割される', () {
      final pages = VerticalTextPaginator.paginate(
        text: 'あ\nい\nう\nえ\nお',
        cellSize: 40,
        viewportSize: const Size(120, 400), // 幅120 / 40 = 3列まで
      );
      expect(pages.length, 2);
      expect(pages[0].columns.length, 3);
      expect(pages[1].columns.length, 2);
    });

    test('空行は幅の狭い区切り列として扱われる', () {
      final pages = VerticalTextPaginator.paginate(
        text: 'あ\n\nい',
        cellSize: 40,
        viewportSize: const Size(400, 400),
      );
      expect(pages.first.columns.length, 3);
      expect(pages.first.columns[1], isEmpty);
    });
  });

  testWidgets('VerticalPageView は各文字を表示し、長音記号は回転する', (tester) async {
    final pages = VerticalTextPaginator.paginate(
      text: 'コーヒー、どうぞ。',
      cellSize: 40,
      viewportSize: const Size(400, 400),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: VerticalPageView(page: pages.first)),
      ),
    );

    for (final ch in 'コーヒーどうぞ、。'.split('')) {
      expect(find.text(ch), findsWidgets);
    }
    expect(find.byType(Transform), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
