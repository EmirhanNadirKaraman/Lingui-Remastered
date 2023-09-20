class Progress {
  int id;
  String word;
  DateTime dueDuration;
  double percent;

  Progress(
      {required this.id,
      required this.word,
      required this.dueDuration,
      required this.percent});

  factory Progress.fromJson(Map<String, dynamic> json) {
    final perc = json['percent'] is int
        ? (json['percent'] as int).toDouble()
        : json['percent'];
    return Progress(
      id: json["word_id"],
      word: json["word"],
      dueDuration: DateTime.parse(json['due_date'] + "Z").toLocal(),
      percent: perc,
    );
  }
}
