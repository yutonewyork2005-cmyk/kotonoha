import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

import '../models/story.dart';
import 'story_text.dart';

/// assets/stories 配下の物語 JSON を読み込むリポジトリ。
/// 物語の追加方法は README.md を参照。
class StoryRepository {
  StoryRepository._();
  static final StoryRepository instance = StoryRepository._();

  List<Story>? _cache;
  final _random = Random();

  Future<List<Story>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final indexRaw = await rootBundle.loadString('assets/stories/index.json');
    final files = ((jsonDecode(indexRaw) as Map<String, dynamic>)['stories']
            as List<dynamic>)
        .cast<String>();
    final stories = <Story>[];
    for (final file in files) {
      try {
        final raw = await rootBundle.loadString('assets/stories/$file');
        final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final textFile = data['text_file'] as String?;
        final String sourceText;
        if (textFile != null) {
          sourceText = await rootBundle.loadString('assets/stories/$textFile');
        } else {
          final pages =
              (data['pages'] as List<dynamic>? ?? const []).whereType<String>();
          sourceText = StoryText.fromPages(pages);
        }
        final text = StoryText.normalize(sourceText);
        data['pages'] = text.isEmpty ? const <String>[] : [text];
        stories.add(Story.fromJson(data));
      } catch (error) {
        // 1作品のファイル不備で、作品一覧全体が空にならないようにする。
        debugPrint('Skipping unreadable story asset $file: $error');
      }
    }
    _cache = stories;
    return stories;
  }

  Future<Story?> byId(String id) async {
    for (final s in await loadAll()) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// ランダムに1話選ぶ。[excludeId] は除外(読んだ直後の話など)。
  Future<Story?> random({String? excludeId}) async {
    var candidates = (await loadAll()).where((s) => s.id != excludeId).toList();
    if (candidates.isEmpty) {
      candidates = await loadAll();
    }
    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }
}
