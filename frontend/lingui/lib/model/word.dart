class Word {
  final String pos;
  final String data;
  final int id;

  const Word({required this.data, required this.id, required this.pos});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(data: json['word'], id: json['word_id'], pos: json['pos']);
  }
}
