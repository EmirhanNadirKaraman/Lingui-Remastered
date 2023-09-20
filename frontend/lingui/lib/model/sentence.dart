class Sentence {
  final int id;
  final String text;
  final int unkownCount;
  final int totalCount;

  const Sentence(
      {required this.id,
      required this.text,
      this.unkownCount = 0,
      this.totalCount = 0});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
        id: json['sentence_id'],
        text: json['content'],
        unkownCount: json['unknown_count'],
        totalCount: json['total_count']);
  }
}
