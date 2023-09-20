import 'package:lingui/model/word_to_token.dart';

class Subtitle {
  String content;
  List<WordToToken> tokens;
  int start;
  int end;

  Subtitle(
      {required this.start,
      required this.end,
      required this.content,
      required this.tokens});

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    final tokens = <WordToToken>[];
    List<String> toParse = [];
    for (final word in json['tokens']) {
      toParse.add(word);
    }

    List<int> ids = [];
    for (final id in json['token_ids']) {
      ids.add(id);
    }
    int index = 0;
    final content = json['content'] as String;

    while (index < content.length) {
      final start = index;
      if (toParse.isEmpty) {
        final sub = content.substring(index);
        final last = tokens.removeLast();
        tokens.add(WordToToken(last.word + sub, last.token, last.wordId));
        break;
      }
      while (true && index < content.length) {
        final sub = content.substring(start, index);
        if (sub.contains(toParse.first)) {
          tokens.add(WordToToken(sub, toParse.first, ids.first));
          ids.removeAt(0);
          toParse.removeAt(0);
          break;
        }
        index++;
      }
    }
    final subtitle = Subtitle(
      start: json['start'],
      end: json['end'],
      content: content,
      tokens: tokens,
    );
    return subtitle;
  }
}
