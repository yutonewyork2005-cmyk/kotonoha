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
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final textFile = data['text_file'] as String?;
      if (textFile != null) {
        final text = await rootBundle.loadString('assets/stories/$textFile');
        data['pages'] = _paginateText(text);
      }
      stories.add(Story.fromJson(data));
    }
    _cache = stories;
    return stories;
  }

  /// テキスト形式の収録作品を、読みやすい長さのページに区切る。
  List<String> _paginateText(String raw) {
    final paragraphs = raw
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty);

    const maxPageLength = 700;
    final pages = <String>[];
    final buffer = StringBuffer();
    for (final paragraph in paragraphs) {
      final extraLength = paragraph.length + (buffer.length == 0 ? 0 : 2);
      if (buffer.length > 0 && buffer.length + extraLength > maxPageLength) {
        pages.add(buffer.toString());
        buffer.clear();
      }
      if (buffer.length > 0) buffer.write('\n\n');
      buffer.write(paragraph);
    }
    if (buffer.length > 0) pages.add(buffer.toString());
    return pages;
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
