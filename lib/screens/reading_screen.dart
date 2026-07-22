import 'package:flutter/material.dart';

import '../models/rewards.dart';
import '../models/story.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/vertical_text.dart';
import 'finished_screen.dart';

/// 読書画面。左スワイプでページをめくり、最終ページの先に読了ボタンが出る。
class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key, required this.story});

  final Story story;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
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
    final pageCount = story.pages.length;
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pageCount + 1,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                if (i == pageCount) {
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
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                  child: VerticalText(
                    text: story.pages[i],
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'serif',
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _page < pageCount ? '${_page + 1} / $pageCount' : '読了',
                style: TextStyle(color: Colors.brown.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
