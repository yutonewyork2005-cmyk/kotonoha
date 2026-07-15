import 'package:flutter/material.dart';

/// 報酬の種類。
enum RewardType { background, costume }

/// 達成報酬(背景・司書の衣装)の定義。
/// 現状は画像の代わりに配色で表現している。画像に差し替える場合は
/// assets に画像を追加し、この定義に画像パスを持たせて各画面を修正する。
class RewardItem {
  const RewardItem({
    required this.id,
    required this.name,
    required this.type,
    required this.requiredCount,
    required this.colors,
  });

  final String id;
  final String name;
  final RewardType type;

  /// 解禁に必要な累計読了冊数。
  final int requiredCount;

  /// background: グラデーション2色 / costume: [衣装色, アクセント色]
  final List<Color> colors;
}

class RewardCatalog {
  static const List<RewardItem> backgrounds = [
    RewardItem(
      id: 'bg_default',
      name: 'はじまりの書斎',
      type: RewardType.background,
      requiredCount: 0,
      colors: [Color(0xFFFBF6EC), Color(0xFFE8DCC0)],
    ),
    RewardItem(
      id: 'bg_washi',
      name: '和紙の間',
      type: RewardType.background,
      requiredCount: 3,
      colors: [Color(0xFFF6EEDC), Color(0xFFCDB98A)],
    ),
    RewardItem(
      id: 'bg_yozakura',
      name: '夜桜の庭',
      type: RewardType.background,
      requiredCount: 5,
      colors: [Color(0xFF4A2F52), Color(0xFFC98BA0)],
    ),
    RewardItem(
      id: 'bg_tsukiyo',
      name: '月夜の図書館',
      type: RewardType.background,
      requiredCount: 10,
      colors: [Color(0xFF14232E), Color(0xFF3E6B84)],
    ),
  ];

  static const List<RewardItem> costumes = [
    RewardItem(
      id: 'costume_default',
      name: '司書の制服',
      type: RewardType.costume,
      requiredCount: 0,
      colors: [Color(0xFF6D4C2F), Color(0xFFF3E4C8)],
    ),
    RewardItem(
      id: 'costume_hakama',
      name: '矢絣の袴',
      type: RewardType.costume,
      requiredCount: 3,
      colors: [Color(0xFF8C2F39), Color(0xFF3B4A6B)],
    ),
    RewardItem(
      id: 'costume_kimono',
      name: '藤色の着物',
      type: RewardType.costume,
      requiredCount: 7,
      colors: [Color(0xFF7C6BA8), Color(0xFFEDE3F5)],
    ),
    RewardItem(
      id: 'costume_miyabi',
      name: '雅の十二単',
      type: RewardType.costume,
      requiredCount: 15,
      colors: [Color(0xFFB03A48), Color(0xFFE9B44C)],
    ),
  ];

  static List<RewardItem> get all => [...backgrounds, ...costumes];

  static RewardItem backgroundById(String id) => backgrounds.firstWhere(
        (r) => r.id == id,
        orElse: () => backgrounds.first,
      );

  static RewardItem costumeById(String id) => costumes.firstWhere(
        (r) => r.id == id,
        orElse: () => costumes.first,
      );

  /// 累計 [count] 冊時点で解禁されている報酬ID一覧。
  static List<String> unlockedIdsFor(int count) =>
      all.where((r) => r.requiredCount <= count).map((r) => r.id).toList();

  /// 次に解禁される報酬。全て解禁済みなら null。
  static RewardItem? nextUnlock(int count) {
    final locked = all.where((r) => r.requiredCount > count).toList()
      ..sort((a, b) => a.requiredCount.compareTo(b.requiredCount));
    return locked.isEmpty ? null : locked.first;
  }
}
