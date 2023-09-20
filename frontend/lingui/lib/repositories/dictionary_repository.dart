import 'package:flutter/material.dart';
import 'package:lingui/model/sentence.dart';
import 'package:lingui/model/word.dart';
import 'package:lingui/services/dictionary_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class DictionaryRepository extends ChangeNotifier {
  final wordCache = <String, DictionaryRepoItem<List<Word>>>{};
  final sentenceCache = <String, DictionaryRepoItem<List<Sentence>>>{};

  List<Word> getWordResults(String query) {
    return wordCache["$query-${SPUtil.instance.currentLanguage}"]?.data ?? [];
  }

  List<Sentence> getSentenceResults(int query) {
    return sentenceCache["$query-${SPUtil.instance.currentLanguage}"]?.data ??
        [];
  }

  void clear() {
    wordCache.clear();
    sentenceCache.clear();
  }

  Future<bool> searchWord(String query, String language,
      {bool refresh = false, bool force = false}) async {
    final item = wordCache["$query-$language"];
    if (!refresh &&
        item != null &&
        item.date.difference(DateTime.now()).inMinutes < 1) {
      return false;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await DictionaryService.searchWord(query, page: 1);
        wordCache["$query-$language"] = DictionaryRepoItem(res);
        notifyListeners();
        return res.isNotEmpty &&
            res.length % AppConfig.dictionaryPagination == 0;
      }
    }
    final page = (item.data.length ~/ AppConfig.dictionaryPagination) + 1;
    final res = await DictionaryService.searchWord(query, page: page);
    final data = item.data + res;
    wordCache["$query-$language"] = DictionaryRepoItem(data);
    notifyListeners();
    return res.isNotEmpty && res.length % AppConfig.dictionaryPagination == 0;
  }

  Future<bool> searchSentence(int word, String language,
      {bool refresh = false, bool force = false, bool paginate = false}) async {
    final item = sentenceCache["${word.toString()}-$language"];
    if (item != null &&
        !refresh &&
        item.date.difference(DateTime.now()).inMinutes < 1 &&
        !paginate) {
      return false;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await DictionaryService.searchSentence(word, page: 1);
        sentenceCache["${word.toString()}-$language"] = DictionaryRepoItem(res);
        notifyListeners();
        return res.isNotEmpty &&
            res.length % AppConfig.dictionaryPagination == 0;
      }
    }
    final page = (item.data.length ~/ AppConfig.dictionaryPagination) + 1;
    final res = await DictionaryService.searchSentence(word, page: page);
    final data = item.data + res;

    sentenceCache["${word.toString()}-$language"] = DictionaryRepoItem(data);
    notifyListeners();
    return res.isNotEmpty && res.length % AppConfig.dictionaryPagination == 0;
  }
}

class DictionaryRepoItem<T> {
  final T data;
  final DateTime date = DateTime.now();

  DictionaryRepoItem(this.data);
}
