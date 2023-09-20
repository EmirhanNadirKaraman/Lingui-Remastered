class Question {
  final String answer;
  final String question;
  final String translated;
  final int wordId;

  const Question(
      {required this.answer,
      required this.question,
      required this.translated,
      required this.wordId});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
        answer: json["word"],
        question: json["removed"],
        translated: json["translation"],
        wordId: json['word_id']);
  }
}
