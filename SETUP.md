# セットアップ手順

前提: Flutter SDK / Android Studio (エミュレータ) 導入済み。
コマンドはすべて PowerShell に1行ずつ貼り付けて実行 (```` ``` ````の行はコピーしない)。

## 0. 必要ツールの導入 (初回のみ)

git と Node.js (npm) が必要です。PowerShellで:

```powershell
winget install --id Git.Git -e
winget install --id OpenJS.NodeJS.LTS -e
```

**インストール後、ターミナルを一度閉じて開き直す** (PATH反映のため)。
`git --version` と `npm --version` が表示されればOK。

## 1. プラットフォームファイルの生成

**必ずプロジェクトフォルダに移動してから**実行します
(このリポジトリには lib・assets などアプリ本体のみが含まれています。
既存の lib や pubspec は上書きされません)。

```powershell
cd "C:\Users\j1851\OneDrive\デスクトップ\アプリ開発\kotonoha"
flutter create . --platforms android,ios,windows --org com.kotonoha
flutter pub get
```

プロンプトの表示が `...\kotonoha>` になっていることを確認してから flutter create を実行すること。

## 2. Firebase プロジェクト作成

1. https://console.firebase.google.com で新規プロジェクト作成 (例: kotonoha)
2. 「Authentication」→「ログイン方法」→ **メール / パスワード を有効化**
3. 「Firestore Database」→ データベース作成 (ロケーション: asia-northeast1 推奨)
4. Firestore の「ルール」に以下を貼り付けて公開:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## 3. FlutterFire 設定 (firebase_options.dart の生成)

kotonoha フォルダ内で:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

- プロジェクトに先ほどの Firebase プロジェクトを選択
- プラットフォームは android (必要なら ios, windows も) を選択
- `lib/firebase_options.dart` が自動で上書き生成されます

`flutterfire` が認識されない場合はターミナルを開き直すか、PATH に
`%LOCALAPPDATA%\Pub\Cache\bin` を追加:

```powershell
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

## 4. Android の minSdk 設定

firebase_auth は minSdk 23 以上が必要です。
`android/app/build.gradle.kts` (または build.gradle) を開き:

```kotlin
defaultConfig {
    minSdk = 23   // flutter.minSdkVersion から変更
}
```

## 5. 実行

```powershell
flutter run
```

Android Studio のエミュレータを起動しておくか、`flutter devices` で対象を確認。
新規登録 → タイトル画面 → 「本をえらぶ」→ 山月記サンプルで動作確認できます。

## 6. GitHub へ push

このフォルダはまだ git 管理されていません (開発環境から GitHub に接続できなかったため)。

```powershell
cd kotonoha
git init -b main
git remote add origin https://github.com/yutonewyork2005-cmyk/kotonoha.git
git fetch origin
git merge origin/main --allow-unrelated-histories   # リポジトリに既存ファイルがある場合
git add -A
git commit -m "feat: ことのは文庫 MVP 実装"
git push -u origin main
```

## トラブルシューティング

- **pub の依存解決に失敗する**: `flutter pub upgrade --major-versions firebase_core firebase_auth cloud_firestore`
- **UnsupportedError: firebase_options.dart が未生成です**: 手順3を実行
- **ビルドが異常に遅い / ファイルロックエラー**: このフォルダは OneDrive 配下です。`build/` の同期でトラブルが出る場合は、リポジトリを OneDrive 外 (例: C:\dev\kotonoha) に移すのがおすすめです
- **google-services.json が無いというエラー**: flutterfire configure が android/app/google-services.json を生成したか確認
