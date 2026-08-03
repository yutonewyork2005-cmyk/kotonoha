import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kotonoha/services/story_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('登録済みの全作品は共通の本文形式で読み込まれる', () async {
    final index = jsonDecode(
      await rootBundle.loadString('assets/stories/index.json'),
    ) as Map<String, dynamic>;
    final registeredFiles = (index['stories'] as List<dynamic>).cast<String>();

    final stories = await StoryRepository.instance.loadAll();

    expect(stories, hasLength(registeredFiles.length));
    for (final story in stories) {
      expect(story.pages, hasLength(1), reason: story.id);
      expect(story.pages.single, isNotEmpty, reason: story.id);
      expect(story.pages.single, isNot(contains('\r')), reason: story.id);
    }
  });
}
