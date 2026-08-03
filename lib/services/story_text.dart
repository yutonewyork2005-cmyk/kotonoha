/// 物語本文を、端末サイズに応じた共通の縦書き組版へ渡すための整形処理。
///
/// JSON の `pages`、外部 `.txt`、stories_src から変換した JSON のいずれも
/// ここで同じ段落形式にそろえる。画面上のページ分割は行わず、
/// VerticalTextPaginator が端末の表示領域に合わせて決定する。
class StoryText {
  const StoryText._();

  /// JSON のページ配列を、段落を保った一つの本文にまとめる。
  static String fromPages(Iterable<String> pages) => normalize(
        pages.where((page) => page.trim().isNotEmpty).join('\n\n'),
      );

  /// 改行コード・行頭末尾の余白・連続した空行を統一する。
  static String normalize(String raw) {
    final lines = raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.trim());

    final paragraphs = <String>[];
    final paragraph = StringBuffer();
    for (final line in lines) {
      if (line.isEmpty) {
        if (paragraph.isNotEmpty) {
          paragraphs.add(paragraph.toString());
          paragraph.clear();
        }
      } else {
        paragraph.write(line);
      }
    }
    if (paragraph.isNotEmpty) {
      paragraphs.add(paragraph.toString());
    }

    final displayParagraphs = _hasSentencePerParagraphLayout(paragraphs)
        ? _mergeShortParagraphs(paragraphs)
        : paragraphs;
    return displayParagraphs.join('\n\n');
  }

  /// 一文ごとに空行を入れた原稿だけを検出する。
  ///
  /// 通常の段落（山月記など）はそのまま保ち、史記のように非常に短い
  /// 段落が連続する原稿は読みやすい長さへまとめる。
  static bool _hasSentencePerParagraphLayout(List<String> paragraphs) {
    if (paragraphs.length < 8) return false;
    final shortCount = paragraphs.where((text) => text.length <= 40).length;
    final averageLength =
        paragraphs.fold<int>(0, (total, text) => total + text.length) /
            paragraphs.length;
    return shortCount / paragraphs.length >= 0.85 && averageLength <= 40;
  }

  static List<String> _mergeShortParagraphs(List<String> paragraphs) {
    const targetLength = 110;
    final merged = <String>[];
    final buffer = StringBuffer();
    for (final paragraph in paragraphs) {
      if (buffer.isNotEmpty &&
          buffer.length + paragraph.length > targetLength) {
        merged.add(buffer.toString());
        buffer.clear();
      }
      buffer.write(paragraph);
    }
    if (buffer.isNotEmpty) merged.add(buffer.toString());
    return merged;
  }
}
