// 物語をプレーンテキストで書いて JSON に変換するツール。
//
// 使い方:
//   dart run tool/story_from_txt.dart assets/stories_src/sangetsuki.txt
//
// 入力テキストの書式は tool/story_template.txt を参照。
// 出力は assets/stories/<id>.json に書き込まれ、index.json にも自動追記される。
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('使い方: dart run tool/story_from_txt.dart <入力.txt>');
    exit(1);
  }

  final input = File(args[0]);
  if (!input.existsSync()) {
    stderr.writeln('ファイルが見つかりません: ${args[0]}');
    exit(1);
  }

  final text = input.readAsStringSync();
  final story = _parseStory(text);

  final id = story['id'] as String;
  final storiesDir = Directory('assets/stories');
  final outFile = File('${storiesDir.path}/$id.json');
  const encoder = JsonEncoder.withIndent('  ');
  outFile.writeAsStringSync(encoder.convert(story));
  stdout.writeln('書き出しました: ${outFile.path}');

  final indexFile = File('${storiesDir.path}/index.json');
  final index = jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
  final list = (index['stories'] as List<dynamic>).cast<String>();
  final fileName = '$id.json';
  if (!list.contains(fileName)) {
    list.add(fileName);
    indexFile.writeAsStringSync(encoder.convert(index));
    stdout.writeln('index.json に追加しました: $fileName');
  } else {
    stdout.writeln('index.json には既に登録済みです: $fileName');
  }
}

Map<String, dynamic> _parseStory(String text) {
  final lines = text.replaceAll('\r\n', '\n').split('\n');

  // セクション区切りの行番号を探す
  int pagesStart = -1, triviaStart = -1, quizStart = -1;
  for (var i = 0; i < lines.length; i++) {
    final t = lines[i].trim();
    if (t == '#PAGES') pagesStart = i;
    if (t == '#TRIVIA') triviaStart = i;
    if (t == '#QUIZ') quizStart = i;
  }
  if (pagesStart == -1) {
    throw const FormatException('#PAGES セクションが見つかりません');
  }

  final headerLines = lines.sublist(0, pagesStart);
  final header = <String, String>{};
  for (final line in headerLines) {
    final t = line.trim();
    if (t.isEmpty || !t.contains(':')) continue;
    final idx = t.indexOf(':');
    final key = t.substring(0, idx).trim();
    final value = t.substring(idx + 1).trim();
    header[key] = value;
  }

  final pagesEnd = [triviaStart, quizStart, lines.length]
      .where((v) => v != -1)
      .reduce((a, b) => a < b ? a : b);
  final pagesText = lines.sublist(pagesStart + 1, pagesEnd).join('\n');
  final pages = pagesText
      .split(RegExp(r'^#PAGE#$', multiLine: true))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  List<String>? trivia;
  if (triviaStart != -1) {
    final end = [quizStart, lines.length].where((v) => v != -1).reduce((a, b) => a < b ? a : b);
    trivia = lines
        .sublist(triviaStart + 1, end)
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>>? quiz;
  if (quizStart != -1) {
    quiz = _parseQuiz(lines.sublist(quizStart + 1, lines.length));
  }

  final story = <String, dynamic>{
    'id': header['id'],
    'title': header['title'],
    'original_title': header['original_title'] ?? '',
    'author': header['author'] ?? '',
    'tag': header['tag'] ?? '古文',
    'is_series': boolOrNull(header['is_series']) ?? false,
    'series_name': strOrNull(header['series_name']),
    'series_num': intOrNull(header['series_num']),
    'series_next': strOrNull(header['series_next']),
    'pages': pages,
  };

  if (trivia != null || quiz != null) {
    story['column'] = {
      'trivia': trivia ?? const <String>[],
      'quiz': quiz ?? const <Map<String, dynamic>>[],
    };
  }

  if (story['id'] == null || story['title'] == null) {
    throw const FormatException('id と title は必須です');
  }

  return story;
}

bool? boolOrNull(String? v) {
  if (v == null || v.isEmpty) return null;
  return v == 'true';
}

int? intOrNull(String? v) {
  if (v == null || v.isEmpty) return null;
  return int.tryParse(v);
}

String? strOrNull(String? v) => (v == null || v.isEmpty) ? null : v;

List<Map<String, dynamic>> _parseQuiz(List<String> lines) {
  final quiz = <Map<String, dynamic>>[];
  String? question;
  final choices = <String>[];
  int? answerIndex;
  String? explanation;

  void flush() {
    if (question != null && choices.isNotEmpty && answerIndex != null) {
      quiz.add({
        'question': question,
        'choices': List<String>.from(choices),
        'answer_index': answerIndex,
        if (explanation != null) 'explanation': explanation,
      });
    }
    question = null;
    choices.clear();
    answerIndex = null;
    explanation = null;
  }

  for (final raw in lines) {
    final t = raw.trim();
    if (t.isEmpty) continue;
    if (t.startsWith('Q:')) {
      flush();
      question = t.substring(2).trim();
    } else if (RegExp(r'^[1-4]:').hasMatch(t)) {
      choices.add(t.substring(2).trim());
    } else if (t.startsWith('ANSWER:')) {
      final n = int.parse(t.substring('ANSWER:'.length).trim());
      answerIndex = n - 1; // 1始まり -> 0始まり
    } else if (t.startsWith('EXPLANATION:')) {
      explanation = t.substring('EXPLANATION:'.length).trim();
    }
  }
  flush();
  return quiz;
}
