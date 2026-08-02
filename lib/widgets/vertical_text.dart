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

/// 物語本文を、本の組版に近いルールで縦書きページに分割する。
///
/// - 1列(縦1行)は約 [rowsPerColumn] 文字
/// - 1ページは約 [columnsPerPage] 列
/// - 段落頭は全角空白で字下げ(かぎ括弧などで始まる行を除く)
/// - 句読点や閉じ括弧が行頭に来る場合は前の行末にぶら下げる(行頭禁則)
class VerticalTextPaginator {
  const VerticalTextPaginator._();

  /// 1列(縦1行)あたりの文字数の目安。
  static const rowsPerColumn = 30;

  /// 行頭禁則のぶら下げで1列に追加してよい文字数。
  static const maxHangingChars = 2;

  /// 1ページあたりの列数の目安。
  static const columnsPerPage = 10;

  /// 字下げしない行頭文字(会話文・引用など)。
  static const _openingBrackets = {
    '「',
    '『',
    '（',
    '(',
    '【',
    '〈',
    '《',
    '[',
  };

  /// 行頭に来ると不自然な文字(行頭禁則)。前の列末尾にぶら下げる。
  static const _lineHeadForbidden = {
    '、',
    '。',
    '，',
    '．',
    ',',
    '.',
    '」',
    '』',
    '）',
    ')',
    '】',
    '〉',
    '》',
    ']',
    '？',
    '?',
    '！',
    '!',
    '…',
    '‥',
  };

  static List<VerticalPage> paginate({
    required String text,
    int columnsPerPage = VerticalTextPaginator.columnsPerPage,
  }) {
    assert(columnsPerPage > 0);
    // 空行で区切られた段落ごとに、字下げして列へ折り返す。
    // 段落内の改行は入力時の行送りなので、本文を連続して組む。
    final allColumns = <List<String>>[];
    final paragraphs = text.replaceAll('\r\n', '\n').split(RegExp(r'\n\s*\n+'));
    var hasPreviousParagraph = false;
    for (final rawParagraph in paragraphs) {
      final paragraph = rawParagraph
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .join();
      if (paragraph.isEmpty) continue;
      if (hasPreviousParagraph) allColumns.add(const []);
      hasPreviousParagraph = true;

      final chars = paragraph.runes.map(String.fromCharCode).toList();
      if (!_openingBrackets.contains(chars.first) && chars.first != '　') {
        chars.insert(0, '　');
      }
      var i = 0;
      while (i < chars.length) {
        var end = math.min(i + rowsPerColumn, chars.length);
        // 次の列の頭が句読点等になるなら、この列の末尾にぶら下げる。
        var hung = 0;
        while (end < chars.length &&
            hung < maxHangingChars &&
            _lineHeadForbidden.contains(chars[end])) {
          end++;
          hung++;
        }
        allColumns.add(chars.sublist(i, end));
        i = end;
      }
    }

    // 約10列ごとにページへまとめる。空白列(段落区切り)はページ頭・末尾に
    // 残さない。
    final pages = <VerticalPage>[];
    var current = <List<String>>[];
    for (final col in allColumns) {
      if (col.isEmpty && current.isEmpty) continue;
      if (current.isNotEmpty && current.length >= columnsPerPage) {
        while (current.isNotEmpty && current.last.isEmpty) {
          current.removeLast();
        }
        pages.add(VerticalPage(current.reversed.toList()));
        current = [];
      }
      if (col.isEmpty && current.isEmpty) continue;
      current.add(col);
    }
    while (current.isNotEmpty && current.last.isEmpty) {
      current.removeLast();
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

  static const _verticalBars = {
    'ー',
    'ｰ',
    '―',
    '—',
    '−',
    '-',
  };

  static const _rotateChars = {
    '~', '〜', '～', // 波ダッシュ
    '…', '‥', // 三点リーダー・二点リーダー
    '(', ')', '（', '）', // 半角・全角括弧
    '「', '」', '『', '』', '【', '】', '〈', '〉', '《', '》', '[', ']',
  };

  // 句読点は縦書きではセルの右上寄りに置くのが自然。
  static const _leadingPunctuation = {'、', '。', '，', '．', ',', '.'};

  static const _openingBrackets = {'「', '『', '（', '【', '〈', '《', '['};

  static const _closingBrackets = {'」', '』', '）', '】', '〉', '》', ']'};

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
    final text = Text(
      ch,
      style: style,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
    if (_verticalBars.contains(ch)) {
      return Center(
        child: Container(
          key: ValueKey('vertical-bar-$ch'),
          width: math.max(1, cellSize * 0.075),
          height: cellSize * 0.48,
          decoration: BoxDecoration(
            color: style?.color ?? Colors.black87,
            borderRadius: BorderRadius.circular(cellSize),
          ),
        ),
      );
    }
    if (_leadingPunctuation.contains(ch)) {
      // 、。は縦書きでセルの右上に置く。
      return Center(
        child: Transform.translate(
          offset: Offset(cellSize * 0.3, -cellSize * 0.3),
          child: text,
        ),
      );
    }
    if (_openingBrackets.contains(ch)) {
      return Center(
        child: Transform.translate(
          offset: Offset(cellSize * 0.24, -cellSize * 0.24),
          child: Transform.rotate(angle: math.pi / 2, child: text),
        ),
      );
    }
    if (_closingBrackets.contains(ch)) {
      return Center(
        child: Transform.translate(
          offset: Offset(-cellSize * 0.24, cellSize * 0.24),
          child: Transform.rotate(angle: math.pi / 2, child: text),
        ),
      );
    }
    if (_rotateChars.contains(ch)) {
      return Center(child: Transform.rotate(angle: math.pi / 2, child: text));
    }
    return Center(child: text);
  }
}
