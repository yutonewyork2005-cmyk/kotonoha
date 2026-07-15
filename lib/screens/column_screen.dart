import 'package:flutter/material.dart';

import '../models/story.dart';

/// 読了後のコラム画面。豆知識とクイズを表示する。読まずに閉じてもよい。
class ColumnScreen extends StatelessWidget {
  const ColumnScreen({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final column = story.column;
    return Scaffold(
      appBar: AppBar(title: Text('コラム: ${story.title}')),
      body: column == null
          ? const Center(child: Text('この物語のコラムはまだありません'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (column.trivia.isNotEmpty) ...[
                  const _SectionTitle(icon: Icons.lightbulb, title: '豆知識'),
                  for (final t in column.trivia)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(t, style: const TextStyle(height: 1.7)),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                if (column.quiz.isNotEmpty) ...[
                  const _SectionTitle(icon: Icons.quiz, title: 'クイズ'),
                  for (var i = 0; i < column.quiz.length; i++)
                    _QuizCard(index: i + 1, item: column.quiz[i]),
                  const SizedBox(height: 16),
                ],
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6D4C2F)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatefulWidget {
  const _QuizCard({required this.index, required this.item});

  final int index;
  final QuizItem item;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final answered = _selected != null;
    final correct = _selected == item.answerIndex;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${widget.index}. ${item.question}',
              style: const TextStyle(fontWeight: FontWeight.bold, height: 1.6),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < item.choices.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: !answered
                          ? null
                          : i == item.answerIndex
                              ? Colors.green.withOpacity(0.15)
                              : i == _selected
                                  ? Colors.red.withOpacity(0.12)
                                  : null,
                    ),
                    onPressed: answered
                        ? null
                        : () => setState(() => _selected = i),
                    child: Text('${String.fromCharCode(0x30A2 + i * 2)}. ${item.choices[i]}'),
                  ),
                ),
              ),
            if (answered) ...[
              const SizedBox(height: 4),
              Text(
                correct ? '○ 正解!' : '× 不正解…',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: correct ? Colors.green : Colors.red,
                ),
              ),
              if (!correct)
                Text('正解: ${item.choices[item.answerIndex]}'),
              if (item.explanation != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.explanation!,
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
