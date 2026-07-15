import 'package:flutter/material.dart';

import '../models/rewards.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// きせかえ(達成報酬)画面。背景と司書衣装の一覧・適用を行う。
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('きせかえ'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '背景'),
              Tab(text: '衣装'),
            ],
          ),
        ),
        body: StreamBuilder<UserProfile?>(
          stream: UserService.instance.profileStream(uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            if (profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final next = RewardCatalog.nextUnlock(profile.totalReadCount);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_stories,
                            color: Color(0xFF6D4C2F),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              next == null
                                  ? '累計 ${profile.totalReadCount}冊 読了 / '
                                      '全ての報酬を解禁済みです!'
                                  : '累計 ${profile.totalReadCount}冊 読了 / '
                                      '次の解禁「${next.name}」まで'
                                      'あと${next.requiredCount - profile.totalReadCount}冊',
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RewardGrid(
                        items: RewardCatalog.backgrounds,
                        profile: profile,
                        equippedId: profile.equippedBgId,
                        onEquip: (id) =>
                            UserService.instance.equipBackground(uid, id),
                      ),
                      _RewardGrid(
                        items: RewardCatalog.costumes,
                        profile: profile,
                        equippedId: profile.equippedCostumeId,
                        onEquip: (id) =>
                            UserService.instance.equipCostume(uid, id),
                      ),
                    ],
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

class _RewardGrid extends StatelessWidget {
  const _RewardGrid({
    required this.items,
    required this.profile,
    required this.equippedId,
    required this.onEquip,
  });

  final List<RewardItem> items;
  final UserProfile profile;
  final String equippedId;
  final ValueChanged<String> onEquip;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final unlocked = profile.hasUnlocked(item.id) ||
            item.requiredCount <= profile.totalReadCount;
        final equipped = item.id == equippedId;
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: unlocked && !equipped ? () => onEquip(item.id) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: equipped ? 3 : 1,
                color: equipped
                    ? const Color(0xFF6D4C2F)
                    : Colors.brown.shade200,
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: unlocked
                                ? item.colors
                                : [
                                    Colors.grey.shade300,
                                    Colors.grey.shade400,
                                  ],
                          ),
                        ),
                        child: item.type == RewardType.costume
                            ? Center(
                                child: Icon(
                                  Icons.person,
                                  size: 48,
                                  color: unlocked
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              )
                            : null,
                      ),
                      if (!unlocked)
                        const Center(
                          child: Icon(Icons.lock, color: Colors.white),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  equipped
                      ? '使用中'
                      : unlocked
                          ? 'タップで適用'
                          : '累計${item.requiredCount}冊で解禁',
                  style: TextStyle(
                    fontSize: 12,
                    color: equipped
                        ? const Color(0xFF6D4C2F)
                        : Colors.grey.shade600,
                    fontWeight:
                        equipped ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
