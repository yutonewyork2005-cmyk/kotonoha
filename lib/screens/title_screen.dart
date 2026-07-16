import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/librarian_service.dart';
import '../services/story_repository.dart';
import '../services/user_service.dart';
import 'customize_screen.dart';
import 'reading_screen.dart';
import 'story_list_screen.dart';

/// タイトル画面。読書・司書メッセージ・きせかえへの入口。
/// 背景イラスト(assets/images/title_bg.png)の上に実際のUIを重ねて配置する。
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  static const double _bgAspectRatio = 918 / 1257;
  static const _textColor = Color(0xFF4A3B6B);
  static const _borderColor = Color(0xFF8A6A3B);

  bool _creatingProfile = false;

  Future<void> _onLibrarianTap(UserProfile profile) async {
    final message = await LibrarianService.instance.pickMessage(
      memberSince: profile.createdAt,
      totalReadCount: profile.totalReadCount,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
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

  Widget _shelfButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFEBD6C5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: _borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _textColor, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, color: _textColor, size: 18),
            ],
          ),
        ),
      ),
    );
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
                            'assets/images/title_bg.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        // 司書タップ領域 (イラスト部分)
                        _positioned(
                          constraints,
                          left: 0.457,
                          top: 0.358,
                          width: 0.543,
                          height: 0.642,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onLibrarianTap(profile),
                              splashColor: Colors.white24,
                            ),
                          ),
                        ),
                        // 読了数チップ
                        _positioned(
                          constraints,
                          left: 0.03,
                          top: 0.02,
                          width: 0.32,
                          height: 0.05,
                          child: Chip(
                            avatar: const Icon(Icons.auto_stories, size: 16),
                            label: Text('読了 ${profile.totalReadCount}冊'),
                            backgroundColor: const Color(0xFFEBD6C5),
                          ),
                        ),
                        // きせかえ / ログアウト
                        _positioned(
                          constraints,
                          left: 0.78,
                          top: 0.015,
                          width: 0.2,
                          height: 0.055,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _iconButton(
                                icon: Icons.palette,
                                tooltip: 'きせかえ',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CustomizeScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _iconButton(
                                icon: Icons.logout,
                                tooltip: 'ログアウト',
                                onTap: () => AuthService.instance.signOut(),
                              ),
                            ],
                          ),
                        ),
                        // 本棚へ (物語一覧)
                        _positioned(
                          constraints,
                          left: 0.659,
                          top: 0.768,
                          width: 0.341,
                          height: 0.0796,
                          child: _shelfButton(
                            icon: Icons.menu_book,
                            label: '本棚へ',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StoryListScreen(),
                              ),
                            ),
                          ),
                        ),
                        // 今日の一話 (ランダム)
                        _positioned(
                          constraints,
                          left: 0.643,
                          top: 0.851,
                          width: 0.357,
                          height: 0.0875,
                          child: _shelfButton(
                            icon: Icons.casino,
                            label: '今日の一話',
                            onTap: _readRandom,
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
      },
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFEBD6C5).withValues(alpha: 0.9),
      shape: const CircleBorder(
        side: BorderSide(color: _borderColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: _textColor, size: 18),
        ),
      ),
    );
  }
}
