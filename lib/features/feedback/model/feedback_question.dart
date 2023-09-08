
class FeedbackQuestion {
  final String column;
  final String question;
  final String type;
  String? answer;

  FeedbackQuestion({
    required this.column,
    required this.question,
    required this.type,
    this.answer,
  });

  factory FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    return FeedbackQuestion(
      column: json['column'],
      question: json['question'],
      type: json['type'],
      answer: json['answer'],
    );
  }
}
