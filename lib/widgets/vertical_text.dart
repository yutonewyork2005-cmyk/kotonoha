import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 縦書きの1画面分のデータ。
///
/// [columns] は表示順(左から右へ配置する順)で、index 0 が一番右
/// (読み始めの位置)に来る。1列は上から下に読む文字のリスト。
/// 空リストの列は改行(段落区切り)のための余白列として扱う。
class VerticalPage {
  const VerticalPage(this.columns);
  final List<List<String>> columns;
}

/// 物語本文を、指定した画面サイズにちょうど収まるよう縦書き用に分割する。
///
/// フォントサイズを画面ごとに変えず一定に保つため、1文字あたりの
/// セルサイズ([cellSize])は固定し、代わりに収まりきらない分は
/// 新しい画面(ページ)として分割する。
class VerticalTextPaginator {
  const VerticalTextPaginator._();

  static List<VerticalPage> paginate({
    required String text,
    required double cellSize,
    required Size viewportSize,
  }) {
    final maxRows = math.max(1, (viewportSize.height / cellSize).floor());

    // まず改行(\n)ごとに列を作り、画面の高さに収まらない列は
    // 続きを新しい列(この段階ではまだ同じ画面内)に折り返す。
    final allColumns = <List<String>>[];
    for (final line in text.split('\n')) {
      if (line.trim().isEmpty) {
        allColumns.add(const []);
        continue;
      }
      final chars = line.runes.map(String.fromCharCode).toList();
      for (var i = 0; i < chars.length; i += maxRows) {
        allColumns.add(chars.sublist(i, math.min(i + maxRows, chars.length)));
      }
    }

    // 画面の幅に収まる列数ごとに画面(ページ)を分割する。
    final pages = <VerticalPage>[];
    var current = <List<String>>[];
    var widthUsed = 0.0;
    for (final col in allColumns) {
      final w = col.isEmpty ? cellSize * 0.6 : cellSize;
      if (current.isNotEmpty && widthUsed + w > viewportSize.width) {
        pages.add(VerticalPage(current.reversed.toList()));
        current = [];
        widthUsed = 0;
      }
      current.add(col);
      widthUsed += w;
    }
    if (current.isNotEmpty) {
      pages.add(VerticalPage(current.reversed.toList()));
    }
    if (pages.isEmpty) pages.add(const VerticalPage([]));
    return pages;
  }
}

/// 縦書きの1画面を表示するウィジェット。
class VerticalPageView extends StatelessWidget {
  const VerticalPageView({
    super.key,
    required this.page,
    this.style,
    this.cellSize = 42,
  });

  final VerticalPage page;
  final TextStyle? style;
  final double cellSize;

  static const _rotateChars = {
    'ー', '−', '-', '~', '〜', // 長音・波ダッシュ
    '(', ')', '（', '）', // 半角・全角括弧
    '「', '」', '『', '』', '【', '】', '〈', '〉', '《', '》', '[', ']',
  };

  // 句読点は縦書きではセルの右上寄りに置くのが自然。
  static const _leadingPunctuation = {'、', '。', ',', '.'};

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final col in page.columns)
          if (col.isEmpty)
            SizedBox(width: cellSize * 0.6)
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final ch in col)
                  SizedBox(
                    width: cellSize,
                    height: cellSize,
                    child: _charCell(ch),
                  ),
              ],
            ),
      ],
    );
  }

  Widget _charCell(String ch) {
    Widget text = Text(ch, style: style);
    if (_rotateChars.contains(ch)) {
      text = Transform.rotate(angle: math.pi / 2, child: text);
    }
    if (_leadingPunctuation.contains(ch)) {
      return Align(alignment: const Alignment(0.55, -0.6), child: text);
    }
    return Center(child: text);
  }
}
