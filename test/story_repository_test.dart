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

  test('物語IDの重複がなく、連作の次話が正しくつながっている', () async {
    final index = jsonDecode(
      await rootBundle.loadString('assets/stories/index.json'),
    ) as Map<String, dynamic>;
    final registeredFiles = (index['stories'] as List<dynamic>).cast<String>();
    final stories = await StoryRepository.instance.loadAll();
    final ids = stories.map((story) => story.id).toList();

    expect(registeredFiles.toSet(), hasLength(registeredFiles.length));
    expect(ids.toSet(), hasLength(ids.length));

    for (final story in stories) {
      final nextId = story.seriesNextId;
      if (nextId == null) continue;

      final next =
          stories.where((candidate) => candidate.id == nextId).toList();
      expect(next, hasLength(1), reason: '${story.id} の次話');
      expect(next.single.seriesName, story.seriesName, reason: story.id);
      expect(next.single.seriesNum, (story.seriesNum ?? 0) + 1,
          reason: story.id);
    }
  });

  test('タイトル用ランダム選択は連作の第2話以降を候補にしない', () async {
    for (var i = 0; i < 50; i++) {
      final story = await StoryRepository.instance.random(
        includeSeriesContinuations: false,
      );

      expect(story, isNotNull);
      expect(story!.isSeries && (story.seriesNum ?? 1) > 1, isFalse);
    }
  });

  test('読了後のランダム選択は同じ連作では次話だけを候補に残す', () async {
    final current = await StoryRepository.instance.byId('shiki_goteihongi_1');
    expect(current, isNotNull);

    for (var i = 0; i < 100; i++) {
      final story = await StoryRepository.instance.random(
        excludeId: current!.id,
        excludedSeriesName: current.seriesName,
        allowedStoryIdInExcludedSeries: current.seriesNextId,
      );

      expect(story, isNotNull);
      if (story!.seriesName == current.seriesName) {
        expect(story.id, current.seriesNextId);
      }
    }
  });
}
