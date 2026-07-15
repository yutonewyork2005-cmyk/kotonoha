import 'package:firebase_auth/firebase_auth.dart';

import 'user_service.dart';

/// Firebase Authentication (メール+パスワード) のラッパー。
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register({
    required String email,
    required String password,
    int? age,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await UserService.instance
          .createProfile(uid: user.uid, email: email, age: age);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// FirebaseAuthException を日本語メッセージに変換する。
  static String describeError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'メールアドレスの形式が正しくありません';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'メールアドレスまたはパスワードが違います';
        case 'email-already-in-use':
          return 'このメールアドレスは既に登録されています';
        case 'weak-password':
          return 'パスワードは6文字以上にしてください';
        case 'too-many-requests':
          return '試行回数が多すぎます。しばらく待ってからお試しください';
        case 'network-request-failed':
          return '通信エラーが発生しました。接続を確認してください';
      }
      return '認証エラーが発生しました (${e.code})';
    }
    return 'エラーが発生しました';
  }
}
