import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/widgets/vertical_text.dart';

const _cell = 20.0;
const _columnWidth = _cell * VerticalPageView.columnPitchFactor; // 26.0
const _blankWidth = _cell * VerticalPageView.blankColumnFactor; // 12.0

void main() {
  group('VerticalTextPaginator', () {
    test('段落頭は全角空白で字下げされる', () {
      final pages = VerticalTextPaginator.paginate(
        text: 'こんにちは',
        cellSize: _cell,
        maxWidth: 1000,
      );
      // 最初の行が一番右(最後の要素)に来る。
      expect(pages.first.columns.last, ['　', 'こ', 'ん', 'に', 'ち', 'は']);
    });

    test('かぎ括弧で始まる行は字下げしない', () {
      final pages = VerticalTextPaginator.paginate(
        text: '「元気？」',
        cellSize: _cell,
        maxWidth: 1000,
      );
      expect(pages.first.columns.last.first, '「');
    });

    test('31文字を超える行は次の列に折り返す', () {
      final text = 'あ' * 40; // 字下げ込みで41文字 -> 31 + 10
      final pages = VerticalTextPaginator.paginate(
        text: text,
        cellSize: _cell,
        maxWidth: 1000,
      );
      expect(pages.first.columns.length, 2);
      expect(pages.first.columns.last.length,
          VerticalTextPaginator.rowsPerColumn);
      expect(pages.first.columns.first.length, 10);
    });

    test('句読点は行頭に来ず前の列末尾にぶら下がる', () {
      // 字下げ込みでちょうど31文字目の次が「。」になるようにする。
      final text = '${'あ' * 30}。まだ続く';
      final pages = VerticalTextPaginator.paginate(
        text: text,
        cellSize: _cell,
        maxWidth: 1000,
      );
      final firstColumn = pages.first.columns.last;
      expect(firstColumn.length, VerticalTextPaginator.rowsPerColumn + 1);
      expect(firstColumn.last, '。');
      // 次の列は「。」で始まらない。
      expect(pages.first.columns.first.first, 'ま');
    });

    test('画面の横幅を超える列数は次のページに分かれる', () {
      // 幅ちょうど3列分(区切りなし)。4列目は入らない。
      final text = List.generate(5, (i) => 'あいう').join('\n\n');
      const maxWidth = _columnWidth * 3 + _blankWidth * 2 + 1;
      final pages = VerticalTextPaginator.paginate(
        text: text,
        cellSize: _cell,
        maxWidth: maxWidth,
      );
      expect(pages.length, greaterThan(1));
      final firstPageContentCols =
          pages.first.columns.where((c) => c.isNotEmpty).length;
      expect(firstPageContentCols, lessThanOrEqualTo(3));
    });

    test('段落区切りが少ないページでも実際の幅ぎりぎりまで列を詰める', () {
      // 区切り(空行)が全く無い、長い1本の文章。
      final text = 'あ' * 300;
      const maxWidth = _columnWidth * 10; // ちょうど10列分、区切りなし
      final pages = VerticalTextPaginator.paginate(
        text: text,
        cellSize: _cell,
        maxWidth: maxWidth,
      );
      final firstPageContentCols =
          pages.first.columns.where((c) => c.isNotEmpty).length;
      // 区切りが無いぶん、目安の10列より多く詰め込める。
      expect(firstPageContentCols, greaterThanOrEqualTo(10));
    });

    test('空行は列間の余白として扱われページ頭には残らない', () {
      final pages = VerticalTextPaginator.paginate(
        text: 'あ\n\nい',
        cellSize: _cell,
        maxWidth: 1000,
      );
      expect(pages.first.columns.length, 3);
      expect(pages.first.columns[1], isEmpty);
      expect(pages.first.columns.first, isNotEmpty);
      expect(pages.first.columns.last, isNotEmpty);
    });
  });

  testWidgets('VerticalPageView は各文字を表示し、長音記号は回転する', (tester) async {
    final pages = VerticalTextPaginator.paginate(
      text: 'コーヒー、どうぞ。',
      cellSize: _cell,
      maxWidth: 1000,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: VerticalPageView(page: pages.first, cellSize: 20)),
      ),
    );

    for (final ch in 'コーヒーどうぞ、。'.split('')) {
      expect(find.text(ch), findsWidgets);
    }
    expect(find.byType(Transform), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
