import 'package:flutter/material.dart';

import '../models/rewards.dart';
import '../models/story.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/vertical_text.dart';
import 'finished_screen.dart';

/// 読書画面。右から左へスワイプしてページをめくり(縦書きの本と同じ向き)、
/// 最終ページの先に読了ボタンが出る。
class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key, required this.story});

  final Story story;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  static const _cellSize = 38.0;
  static const _contentPadding = EdgeInsets.fromLTRB(16, 16, 16, 16);
  static const _footerHeight = 40.0;
  static const _textStyle = TextStyle(fontSize: 21, fontFamily: 'serif');

  final _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    var newRewards = <RewardItem>[];
    try {
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null) {
        newRewards =
            await UserService.instance.markStoryRead(uid, widget.story.id);
      }
    } catch (_) {
      // 通信エラー時も読了画面へは進める(記録は次回読了時に再試行される)。
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FinishedScreen(
          story: widget.story,
          newRewards: newRewards,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF9F0),
        title: Column(
          children: [
            Text(
              story.title,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            if (story.source.isNotEmpty)
              Text(
                story.source,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.brown.shade400,
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(
              constraints.maxWidth - _contentPadding.horizontal,
              constraints.maxHeight - _footerHeight - _contentPadding.vertical,
            );
            // 元のページ区切り(横書き時代の目安)ごとに分割し直すと、
            // 各ページの末尾で余った分だけの画面ができ不自然な余白が
            // 生まれるため、物語全体を1本の文章としてつなげてから
            // 画面サイズに合わせて縦書き用に分割し直す。
            final screens = VerticalTextPaginator.paginate(
              text: story.pages.join('\n\n'),
              cellSize: _cellSize,
              viewportSize: viewport,
            );
            final screenCount = screens.length;
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    // 右から左へスワイプすると次のページに進む(縦書きの本と同じ向き)。
                    reverse: true,
                    itemCount: screenCount + 1,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      if (i == screenCount) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'おしまい',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: 220,
                                child: FilledButton(
                                  onPressed: _finishing ? null : _finish,
                                  child: _finishing
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('読み終わった!'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: _contentPadding,
                        child: VerticalPageView(
                          page: screens[i],
                          style: _textStyle,
                          cellSize: _cellSize,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: _footerHeight,
                  child: Center(
                    child: Text(
                      _page < screenCount
                          ? '${_page + 1} / $screenCount'
                          : '読了',
                      style: TextStyle(color: Colors.brown.shade400),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
