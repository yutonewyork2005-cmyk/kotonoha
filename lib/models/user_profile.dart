import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore users/{uid} ドキュメントに対応するモデル。
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.age,
    this.totalReadCount = 0,
    this.equippedBgId = 'bg_default',
    this.equippedCostumeId = 'costume_default',
    this.unlockedAssets = const [],
    this.readStoryIds = const [],
    this.createdAt,
  });

  final String uid;
  final String email;
  final int? age;
  final int totalReadCount;
  final String equippedBgId;
  final String equippedCostumeId;
  final List<String> unlockedAssets;
  final List<String> readStoryIds;
  final DateTime? createdAt;

  bool hasRead(String storyId) => readStoryIds.contains(storyId);
  bool hasUnlocked(String assetId) => unlockedAssets.contains(assetId);

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return UserProfile(
      uid: doc.id,
      email: (d['email'] ?? '') as String,
      age: (d['age'] as num?)?.toInt(),
      totalReadCount: ((d['total_read_count'] as num?) ?? 0).toInt(),
      equippedBgId: (d['equipped_bg_id'] ?? 'bg_default') as String,
      equippedCostumeId: (d['equipped_costume_id'] ?? 'costume_default') as String,
      unlockedAssets:
          ((d['unlocked_assets'] ?? []) as List<dynamic>).cast<String>(),
      readStoryIds:
          ((d['read_story_ids'] ?? []) as List<dynamic>).cast<String>(),
      createdAt: (d['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
