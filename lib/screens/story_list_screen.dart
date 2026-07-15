import 'package:flutter/material.dart';

import '../models/story.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/story_repository.dart';
import '../services/user_service.dart';
import 'reading_screen.dart';

/// 物語一覧画面。タグ・読了状況でフィルタできる。
class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  static const _filters = ['すべて', '古文', '漢文', '未読', '読了済み'];
  String _filter = 'すべて';

  List<Story> _applyFilter(List<Story> stories, UserProfile? profile) {
    switch (_filter) {
      case '古文':
      case '漢文':
        return stories.where((s) => s.tag == _filter).toList();
      case '未読':
        return stories
            .where((s) => !(profile?.hasRead(s.id) ?? false))
            .toList();
      case '読了済み':
        return stories.where((s) => profile?.hasRead(s.id) ?? false).toList();
      default:
        return stories;
    }
  }

  Future<void> _readRandom() async {
    final story = await StoryRepository.instance.random();
    if (!mounted) return;
    if (story == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('物語がまだ登録されていません')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReadingScreen(story: story)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('物語をえらぶ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _readRandom,
        icon: const Icon(Icons.casino),
        label: const Text('ランダム'),
      ),
      body: FutureBuilder<List<Story>>(
        future: StoryRepository.instance.loadAll(),
        builder: (context, storySnap) {
          if (storySnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final stories = storySnap.data ?? const <Story>[];
          return StreamBuilder<UserProfile?>(
            stream: uid == null
                ? const Stream.empty()
                : UserService.instance.profileStream(uid),
            builder: (context, profileSnap) {
              final profile = profileSnap.data;
              final filtered = _applyFilter(stories, profile);
              return Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        for (final f in _filters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: _filter == f,
                              onSelected: (_) => setState(() => _filter = f),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                '物語がまだ登録されていません。\n'
                                'assets/stories に JSON を追加してください。\n'
                                '(追加方法は README.md を参照)',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final story = filtered[i];
                              final read =
                                  profile?.hasRead(story.id) ?? false;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: _TagChip(tag: story.tag),
                                  title: Text(
                                    story.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (story.source.isNotEmpty)
                                        story.source,
                                      if (story.isSeries &&
                                          story.seriesName != null)
                                        '連作: ${story.seriesName}'
                                            ' 第${story.seriesNum ?? '?'}話',
                                    ].join(' / '),
                                  ),
                                  trailing: read
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReadingScreen(story: story),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final color = tag == '漢文' ? Colors.indigo : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
