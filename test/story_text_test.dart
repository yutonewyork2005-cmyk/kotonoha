import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/services/story_text.dart';

void main() {
  group('StoryText', () {
    test('ページ配列とテキストファイルの本文を同じ段落形式に整える', () {
      final fromPages = StoryText.fromPages([
        ' 一段落目\r\n二行目 ',
        '二段落目',
      ]);
      final fromTextFile = StoryText.normalize('一段落目\n二行目\n\n二段落目');

      expect(fromPages, fromTextFile);
    });

    test('連続する空行は一つの段落区切りにまとめる', () {
      expect(StoryText.normalize('\n\n本文\n\n\n次の段落\n'), '本文\n\n次の段落');
    });

    test('一文ごとに空行がある原稿は読みやすい段落へ自動結合する', () {
      const source = '''
一文目です。

二文目です。

三文目です。

四文目です。

五文目です。

六文目です。

七文目です。

八文目です。

九文目です。''';

      final normalized = StoryText.normalize(source);

      expect(normalized.split('\n\n'), hasLength(1));
      expect(
          normalized, '一文目です。二文目です。三文目です。四文目です。五文目です。六文目です。七文目です。八文目です。九文目です。');
    });
  });
}
