import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

/// 司書からの一言メッセージを選ぶサービス。
/// 固定メッセージは assets/messages/librarian_messages.json で管理。
class LibrarianService {
  LibrarianService._();
  static final LibrarianService instance = LibrarianService._();

  List<String>? _generic;
  final _random = Random();

  Future<void> _ensureLoaded() async {
    if (_generic != null) return;
    final raw =
        await rootBundle.loadString('assets/messages/librarian_messages.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _generic = ((json['generic'] ?? []) as List<dynamic>).cast<String>();
  }

  Future<String> pickMessage({
    DateTime? memberSince,
    int totalReadCount = 0,
  }) async {
    await _ensureLoaded();
    final candidates = <String>[..._generic ?? []];
    if (memberSince != null) {
      final days = DateTime.now().difference(memberSince).inDays + 1;
      if (days == 7) {
        return '今日はあなたがこの図書館に来て1週間です!よく頑張っていますね!';
      }
      candidates.add('今日で来館$days日目ですね。ようこそ、ことのは文庫へ!');
    }
    if (totalReadCount > 0) {
      candidates.add('これまでに$totalReadCount冊読みましたね。すばらしいです!');
    }
    if (candidates.isEmpty) return 'ようこそ、ことのは文庫へ!';
    return candidates[_random.nextInt(candidates.length)];
  }
}
