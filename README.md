# ことのは文庫 (kotonoha)

古文・漢文に苦手意識を持つ高校生向けに、約5分で読める現代風リメイク作品を提供する読書アプリ。
企画書に基づく Flutter + Firebase 実装。

## 機能 (企画書との対応)

| 企画書の機能 | 実装 |
| --- | --- |
| ユーザ登録 / ログイン | Firebase Authentication (メール+パスワード)。`login_screen.dart` / `register_screen.dart` |
| 読書機能 | 物語一覧から選択 or ランダム選択。左スワイプでページめくり。`story_list_screen.dart` / `reading_screen.dart` |
| 読了後の画面 | タイトルへ / 一覧へ / もう1話(連作対応) / ランダム / コラム。`finished_screen.dart` |
| 読了後のコラム | 豆知識+選択式クイズ。スキップ可。`column_screen.dart` |
| 司書からのメッセージ | タイトル画面で司書をタップ。来館日数などの動的メッセージあり。`librarian_service.dart` |
| 達成報酬(カスタマイズ) | 累計読了冊数で背景・衣装を解禁、きせかえ画面で適用。`customize_screen.dart` / `models/rewards.dart` |
| 物語のタグ付け | 「古文」「漢文」タグ+読了フィルタ |
| データ管理 | Firestore `users/{uid}` に読了状況・装備・解禁品を保存。`user_service.dart` |

## セットアップ

**SETUP.md を参照**(flutter create → Firebase 設定 → 実行 → GitHub push の順)。

## ディレクトリ構成

```
lib/
  main.dart              エントリポイント (Firebase 初期化)
  app.dart               テーマ・ルート
  firebase_options.dart  flutterfire configure で生成 (現状プレースホルダ)
  models/                Story / UserProfile / RewardCatalog
  services/              Auth / Firestore / 物語読込 / 司書メッセージ
  screens/               各画面
  widgets/               司書アバターなど
assets/
  stories/               物語 JSON (index.json + 各話)
  messages/              司書メッセージ JSON
```

## 物語の追加方法 (プレーンテキストから変換・推奨)

JSON を手で書くと `\n` エスケープなどが面倒なので、プレーンテキストで書いて
自動変換するツールを使う。

1. `tool/story_template.txt` をコピーして `assets/stories_src/<id>.txt` を作成し、本文を書く
   (書式は `tool/story_template.txt` 内のコメント兼サンプルを参照。ページは `#PAGE#` の行で区切るだけでよく、
   改行や空行(段落区切り)はそのまま反映される)
2. 変換コマンドを実行:
   ```powershell
   cd kotonoha
   dart run tool/story_from_txt.dart assets/stories_src/<id>.txt
   ```
3. `assets/stories/<id>.json` が生成され、`index.json` にも自動追記される

## 物語の追加方法 (JSON を直接書く場合)

1. `assets/stories/` に JSON ファイルを追加 (例: `taketori_01.json`)
2. `assets/stories/index.json` の `stories` 配列にファイル名を追記

物語 JSON の形式:

```json
{
  "id": "一意なID",
  "title": "リメイク版タイトル",
  "original_title": "原作タイトル",
  "author": "原作者",
  "tag": "古文",              // "古文" または "漢文"
  "is_series": false,          // 連作なら true
  "series_name": null,         // 連作タイトル
  "series_num": null,          // 話数
  "series_next": null,         // 次話の id (最終話は null)
  "pages": ["1ページ目の本文", "2ページ目の本文"],
  "column": {
    "trivia": ["豆知識1", "豆知識2"],
    "quiz": [
      {
        "question": "問題文",
        "choices": ["選択肢1", "選択肢2", "選択肢3", "選択肢4"],
        "answer_index": 0,
        "explanation": "解説 (任意)"
      }
    ]
  }
}
```

`column` は省略可。ページは1ページ=約300〜400字が読みやすい。
サンプルとして企画書掲載の「山月記 元エリート、虎になる」を収録済み (`sangetsuki.json`)。

## 報酬(背景・衣装)の追加方法

`lib/models/rewards.dart` の `RewardCatalog` にエントリを追加するだけ。
`requiredCount` が解禁に必要な累計読了冊数。現状は配色プレースホルダなので、
本番イラスト・背景画像ができたら `RewardItem` に画像パスを追加して差し替える。

## Firestore スキーマ

`users/{uid}`:

| フィールド | 型 | 説明 |
| --- | --- | --- |
| email | string | メールアドレス |
| age | number | 年齢 (任意) |
| total_read_count | number | 累計読了冊数 |
| equipped_bg_id | string | 設定中の背景 ID |
| equipped_costume_id | string | 設定中の衣装 ID |
| unlocked_assets | array | 解禁済み報酬 ID |
| read_story_ids | array | 読了した物語 ID |
| created_at | timestamp | 登録日時 (来館日数の計算に使用) |

## TODO (企画書のうち未実装)

- BGM・効果音 (audioplayers 等の導入)
- 縦書き表示・挿絵・ページめくり演出
- 司書イラスト・背景の本番アセット差し替え
- Firebase Cloud Messaging (通知)
- iOS / Windows での Firebase 設定・動作確認
