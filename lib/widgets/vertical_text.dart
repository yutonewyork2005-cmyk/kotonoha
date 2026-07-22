import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 物語本文を縦書き(右から左へ、上から下へ)で表示するウィジェット。
///
/// テキスト中の改行(\n)ごとに1列(右側から順)とし、空行は列間の余白として扱う。
/// 長音記号や括弧など、縦書きで90度回転させたほうが自然な文字は回転させる。
class VerticalText extends StatelessWidget {
  const VerticalText({
    super.key,
    required this.text,
    this.style,
    this.columnWidth = 32,
  });

  final String text;
  final TextStyle? style;
  final double columnWidth;

  static const _rotateChars = {
    'ー', '−', '-', '~', '〜', // 長音・波ダッシュ
    '(', ')', '「', '」', '『', '』', '【', '】', '〈', '〉', '《', '》', '[', ']',
  };

  @override
  Widget build(BuildContext context) {
    const verticalPadding = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final usableHeight = constraints.maxHeight - verticalPadding;
        final maxRows = usableHeight.isFinite
            ? (usableHeight ~/ columnWidth).clamp(1, 1000)
            : 1000;

        final lines = text.split('\n');
        final columns = <Widget>[];
        for (final line in lines) {
          if (line.trim().isEmpty) {
            columns.add(SizedBox(width: columnWidth * 0.6));
            continue;
          }
          final chars = line.runes.map(String.fromCharCode).toList();
          // 画面に収まらない行は、続きを左隣の列に折り返す。
          for (var i = 0; i < chars.length; i += maxRows) {
            final chunk = chars.sublist(
              i,
              (i + maxRows).clamp(0, chars.length),
            );
            columns.add(
              _VerticalColumn(chars: chunk, style: style, cell: columnWidth),
            );
          }
        }
        // 横スクロールにすると PageView のページめくりスワイプと競合するため、
        // 列数が多いページは画面幅に収まるよう縮小して表示する(FittedBox)。
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: verticalPadding / 2),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              // 最初の行が右端(読み始めの位置)に来るよう逆順に並べる。
              children: columns.reversed.toList(),
            ),
          ),
        );
      },
    );
  }
}

class _VerticalColumn extends StatelessWidget {
  const _VerticalColumn({
    required this.chars,
    required this.style,
    required this.cell,
  });

  final List<String> chars;
  final TextStyle? style;
  final double cell;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final ch in chars)
          SizedBox(
            width: cell,
            height: cell,
            child: Center(
              child: VerticalText._rotateChars.contains(ch)
                  ? Transform.rotate(
                      angle: math.pi / 2,
                      child: Text(ch, style: style),
                    )
                  : Text(ch, style: style),
            ),
          ),
      ],
    );
  }
}
