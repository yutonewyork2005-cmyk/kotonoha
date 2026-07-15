import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rewards.dart';
import '../models/user_profile.dart';

/// Firestore の users コレクションを扱うサービス。
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> docFor(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> createProfile({
    required String uid,
    required String email,
    int? age,
  }) {
    return docFor(uid).set({
      'email': email,
      if (age != null) 'age': age,
      'total_read_count': 0,
      'equipped_bg_id': 'bg_default',
      'equipped_costume_id': 'costume_default',
      'unlocked_assets': RewardCatalog.unlockedIdsFor(0),
      'read_story_ids': <String>[],
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> profileStream(String uid) => docFor(uid)
      .snapshots()
      .map((d) => d.exists ? UserProfile.fromDoc(d) : null);

  /// 読了を記録する。今回の読了で新しく解禁された報酬を返す。
  /// 既に読了済みの物語なら何もせず空リストを返す。
  Future<List<RewardItem>> markStoryRead(String uid, String storyId) {
    final ref = docFor(uid);
    return _db.runTransaction<List<RewardItem>>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};
      final read =
          ((data['read_story_ids'] ?? []) as List<dynamic>).cast<String>();
      if (read.contains(storyId)) return <RewardItem>[];

      final newCount = ((data['total_read_count'] as num?) ?? 0).toInt() + 1;
      final unlocked =
          ((data['unlocked_assets'] ?? []) as List<dynamic>).cast<String>();
      final newlyUnlocked = RewardCatalog.all
          .where((r) => r.requiredCount <= newCount && !unlocked.contains(r.id))
          .toList();

      tx.set(ref, {
        'total_read_count': newCount,
        'read_story_ids': FieldValue.arrayUnion([storyId]),
        if (newlyUnlocked.isNotEmpty)
          'unlocked_assets':
              FieldValue.arrayUnion(newlyUnlocked.map((r) => r.id).toList()),
      }, SetOptions(merge: true));
      return newlyUnlocked;
    });
  }

  Future<void> equipBackground(String uid, String bgId) =>
      docFor(uid).set({'equipped_bg_id': bgId}, SetOptions(merge: true));

  Future<void> equipCostume(String uid, String costumeId) =>
      docFor(uid).set({'equipped_costume_id': costumeId}, SetOptions(merge: true));
}
