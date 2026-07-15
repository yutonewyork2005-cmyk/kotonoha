import 'package:flutter/material.dart';

import '../models/rewards.dart';
import '../models/story.dart';
import '../services/story_repository.dart';
import 'column_screen.dart';
import 'reading_screen.dart';
import 'story_list_screen.dart';

/// 読了後の画面。背景イラスト(assets/images/finished_bg.png)の上に
/// 実際のボタン(テキスト付き)を重ねて配置する。
class FinishedScreen extends StatefulWidget {
  const FinishedScreen({
    super.key,
    required this.story,
    this.newRewards = const [],
  });

  final Story story;
  final List<RewardItem> newRewards;

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  // 背景画像の元サイズ (幅 x 高さ)。ボタン位置はこの比率を基準にした割合で指定する。
  static const double _bgAspectRatio = 1048 / 1501;

  static const _borderColor = Color(0xFF8A6A3B);
  static const _textColor = Color(0xFF4A3B6B);

  @override
  void initState() {
    super.initState();
    if (widget.newRewards.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showRewardsDialog());
    }
  }

  void _showRewardsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange),
            SizedBox(width: 8),
            Text('新しい報酬を解禁!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final r in widget.newRewards)
              Text(
                '${r.type == RewardType.background ? "背景" : "衣装"}「${r.name}」',
              ),
            const SizedBox(height: 8),
            const Text(
              'きせかえ画面から設定できます',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<void> _readNext() async {
    Story? next;
    if (widget.story.seriesNextId != null) {
      next = await StoryRepository.instance.byId(widget.story.seriesNextId!);
    }
    next ??= await StoryRepository.instance.random(excludeId: widget.story.id);
    if (!mounted) return;
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

  Future<void> _readRandom() async {
    final next =
        await StoryRepository.instance.random(excludeId: widget.story.id);
    if (!mounted) return;
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

  void _openColumn() {
    final hasColumn =
        widget.story.column != null && !widget.story.column!.isEmpty;
    if (!hasColumn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('この物語にはコラムがありません')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ColumnScreen(story: widget.story)),
    );
  }

  void _backToList() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const StoryListScreen()));
  }

  void _backToTitle() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 画像全体を 0.0〜1.0 とした割合座標にボタンを配置する。
  Widget _positioned(
    BoxConstraints c, {
    required double left,
    required double top,
    required double width,
    required double height,
    required Widget child,
  }) {
    return Positioned(
      left: left * c.maxWidth,
      top: top * c.maxHeight,
      width: width * c.maxWidth,
      height: height * c.maxHeight,
      child: child,
    );
  }

  Widget _squareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF3E6C8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _textColor, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF3E6C8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: _borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _textColor, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF3E6C8),
      shape: const CircleBorder(
        side: BorderSide(color: _borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _textColor, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextLabel =
        widget.story.seriesNextId != null ? '続けて\nもう1話読む\n(連作の続き)' : '続けて\nもう1話読む';
    return Scaffold(
      backgroundColor: const Color(0xFF241C3A),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: _bgAspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/finished_bg.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    // 続けてもう1話読む
                    _positioned(
                      constraints,
                      left: 0.167,
                      top: 0.187,
                      width: 0.31,
                      height: 0.233,
                      child: _squareButton(
                        icon: Icons.auto_stories,
                        label: nextLabel,
                        onTap: _readNext,
                      ),
                    ),
                    // ランダムでもう1話読む
                    _positioned(
                      constraints,
                      left: 0.520,
                      top: 0.187,
                      width: 0.31,
                      height: 0.233,
                      child: _squareButton(
                        icon: Icons.casino,
                        label: 'ランダムで\nもう1話読む',
                        onTap: _readRandom,
                      ),
                    ),
                    // コラムを見る
                    _positioned(
                      constraints,
                      left: 0.234,
                      top: 0.456,
                      width: 0.534,
                      height: 0.173,
                      child: _pillButton(
                        icon: Icons.lightbulb,
                        label: 'コラムを見る',
                        onTap: _openColumn,
                      ),
                    ),
                    // タイトル画面に戻る
                    _positioned(
                      constraints,
                      left: 0.167,
                      top: 0.636,
                      width: 0.31,
                      height: 0.233,
                      child: _circleButton(
                        icon: Icons.castle,
                        label: 'タイトル画面\nに戻る',
                        onTap: _backToTitle,
                      ),
                    ),
                    // 物語一覧に戻る
                    _positioned(
                      constraints,
                      left: 0.520,
                      top: 0.636,
                      width: 0.31,
                      height: 0.233,
                      child: _circleButton(
                        icon: Icons.menu_book,
                        label: '物語一覧に\n戻る',
                        onTap: _backToList,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
