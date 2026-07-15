import 'package:flutter/material.dart';

import '../models/rewards.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/librarian_service.dart';
import '../services/story_repository.dart';
import '../services/user_service.dart';
import '../widgets/librarian_avatar.dart';
import 'customize_screen.dart';
import 'reading_screen.dart';
import 'story_list_screen.dart';

/// タイトル画面。読書・司書メッセージ・きせかえへの入口。
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  String? _librarianMessage;
  bool _creatingProfile = false;

  Future<void> _onLibrarianTap(UserProfile profile) async {
    final message = await LibrarianService.instance.pickMessage(
      memberSince: profile.createdAt,
      totalReadCount: profile.totalReadCount,
    );
    if (mounted) setState(() => _librarianMessage = message);
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

  /// 旧アカウント等でプロフィールが無い場合に作成する。
  void _ensureProfile() {
    if (_creatingProfile) return;
    _creatingProfile = true;
    final user = AuthService.instance.currentUser;
    if (user != null) {
      UserService.instance
          .createProfile(uid: user.uid, email: user.email ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return StreamBuilder<UserProfile?>(
      stream: UserService.instance.profileStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          _ensureProfile();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final bg = RewardCatalog.backgroundById(profile.equippedBgId);
        final costume = RewardCatalog.costumeById(profile.equippedCostumeId);
        final darkBg = bg.colors.first.computeLuminance() < 0.4;
        final textColor = darkBg ? Colors.white : const Color(0xFF3A2A1A);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bg.colors,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.auto_stories, size: 18),
                          label: Text('読了 ${profile.totalReadCount}冊'),
                        ),
                        IconButton(
                          tooltip: 'ログアウト',
                          onPressed: () => AuthService.instance.signOut(),
                          icon: Icon(Icons.logout, color: textColor),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'ことのは文庫',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_librarianMessage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _librarianMessage!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      Text(
                        '司書をタップしてみましょう',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 8),
                    LibrarianAvatar(
                      costume: costume,
                      onTap: () => _onLibrarianTap(profile),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.menu_book),
                      label: const Text('本をえらぶ'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StoryListScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.casino),
                      label: const Text('ランダムに読む'),
                      onPressed: _readRandom,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: Icon(Icons.palette, color: textColor),
                      label: Text(
                        'きせかえ',
                        style: TextStyle(color: textColor),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomizeScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
