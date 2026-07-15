import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/story.dart';

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
      final raw = await rootBundle.loadString('assets/stories/$file');
      stories.add(Story.fromJson(jsonDecode(raw) as Map<String, dynamic>));
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
    var candidates =
        (await loadAll()).where((s) => s.id != excludeId).toList();
    if (candidates.isEmpty) {
      candidates = await loadAll();
    }
    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }
}
