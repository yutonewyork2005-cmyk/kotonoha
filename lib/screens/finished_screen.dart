import 'package:flutter/material.dart';

import '../models/rewards.dart';
import '../models/story.dart';
import '../services/story_repository.dart';
import 'column_screen.dart';
import 'reading_screen.dart';
import 'story_list_screen.dart';

/// 読了後の画面。次の行動と報酬解禁の通知を表示する。
class FinishedScreen extends StatelessWidget {
  const FinishedScreen({
    super.key,
    required this.story,
    this.newRewards = const [],
  });

  final Story story;
  final List<RewardItem> newRewards;

  Future<void> _readNext(BuildContext context) async {
    Story? next;
    if (story.seriesNextId != null) {
      next = await StoryRepository.instance.byId(story.seriesNextId!);
    }
    next ??= await StoryRepository.instance.random(excludeId: story.id);
    if (!context.mounted) return;
    if (next == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('他の物語がまだ登録されていません')),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ReadingScreen(story: next!)),
    );
  }

  Future<void> _readRandom(BuildContext context) async {
    final next = await StoryRepository.instance.random(excludeId: story.id);
    if (!context.mounted) return;
    if (next == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('他の物語がまだ登録されていません')),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ReadingScreen(story: next)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasColumn = story.column != null && !story.column!.isEmpty;
    final nextLabel =
        story.seriesNextId != null ? '続けてもう1話読む (連作の続き)' : '続けてもう1話読む';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 64,
                  color: Color(0xFF6D4C2F),
                ),
                const SizedBox(height: 16),
                Text(
                  '『${story.title}』\n読了おめでとうございます!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                if (newRewards.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: const Color(0xFFFFF3D6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.celebration, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                '新しい報酬を解禁!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final r in newRewards)
                            Text(
                              '${r.type == RewardType.background ? "背景" : "衣装"}'
                              '「${r.name}」',
                            ),
                          const SizedBox(height: 4),
                          const Text(
                            'きせかえ画面から設定できます',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (hasColumn) ...[
                  FilledButton.icon(
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('コラムを見る (豆知識・クイズ)'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ColumnScreen(story: story),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton.tonal(
                  onPressed: () => _readNext(context),
                  child: Text(nextLabel),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _readRandom(context),
                  child: const Text('ランダムでもう1話読む'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StoryListScreen(),
                      ),
                    );
                  },
                  child: const Text('物語一覧に戻る'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  child: const Text('タイトルに戻る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
