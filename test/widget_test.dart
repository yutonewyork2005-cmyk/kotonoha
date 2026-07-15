import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/models/story.dart';

void main() {
  test('Story.fromJson が正しくパースできる', () {
    final json = jsonDecode('''
    {
      "id": "test",
      "title": "テスト物語",
      "original_title": "原作",
      "author": "作者",
      "tag": "漢文",
      "pages": ["ページ1", "ページ2"],
      "column": {
        "trivia": ["豆知識"],
        "quiz": [
          {"question": "Q", "choices": ["a", "b"], "answer_index": 1, "explanation": "E"}
        ]
      }
    }
    ''') as Map<String, dynamic>;
    final story = Story.fromJson(json);
    expect(story.id, 'test');
    expect(story.tag, '漢文');
    expect(story.pages.length, 2);
    expect(story.column!.quiz.first.answerIndex, 1);
  });
}
