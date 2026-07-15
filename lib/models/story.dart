/// 物語データモデル。assets/stories/*.json から読み込む。
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.author,
    required this.tag,
    required this.pages,
    this.isSeries = false,
    this.seriesName,
    this.seriesNum,
    this.seriesNextId,
    this.column,
  });

  final String id;
  final String title;
  final String originalTitle;
  final String author;

  /// 「古文」か「漢文」
  final String tag;
  final bool isSeries;
  final String? seriesName;
  final int? seriesNum;
  final String? seriesNextId;

  /// 本文。1要素 = 1ページ。
  final List<String> pages;
  final StoryColumn? column;

  String get source {
    if (author.isEmpty && originalTitle.isEmpty) return '';
    if (author.isEmpty) return '『$originalTitle』より';
    return '$author『$originalTitle』より';
  }

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        title: json['title'] as String,
        originalTitle: (json['original_title'] ?? '') as String,
        author: (json['author'] ?? '') as String,
        tag: (json['tag'] ?? '古文') as String,
        isSeries: (json['is_series'] ?? false) as bool,
        seriesName: json['series_name'] as String?,
        seriesNum: (json['series_num'] as num?)?.toInt(),
        seriesNextId: json['series_next'] as String?,
        pages: ((json['pages'] ?? []) as List<dynamic>).cast<String>(),
        column: json['column'] == null
            ? null
            : StoryColumn.fromJson(json['column'] as Map<String, dynamic>),
      );
}

/// 読了後のコラム(豆知識・クイズ)。
class StoryColumn {
  const StoryColumn({required this.trivia, required this.quiz});

  final List<String> trivia;
  final List<QuizItem> quiz;

  bool get isEmpty => trivia.isEmpty && quiz.isEmpty;

  factory StoryColumn.fromJson(Map<String, dynamic> json) => StoryColumn(
        trivia: ((json['trivia'] ?? []) as List<dynamic>).cast<String>(),
        quiz: ((json['quiz'] ?? []) as List<dynamic>)
            .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class QuizItem {
  const QuizItem({
    required this.question,
    required this.choices,
    required this.answerIndex,
    this.explanation,
  });

  final String question;
  final List<String> choices;
  final int answerIndex;
  final String? explanation;

  factory QuizItem.fromJson(Map<String, dynamic> json) => QuizItem(
        question: json['question'] as String,
        choices: ((json['choices'] ?? []) as List<dynamic>).cast<String>(),
        answerIndex: ((json['answer_index'] ?? 0) as num).toInt(),
        explanation: json['explanation'] as String?,
      );
}
