import 'dart:convert';

import 'package:lingui/model/sentence.dart';
import 'package:lingui/model/word.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class DictionaryService {
  static Future<List<Word>> searchWord(String query, {int page = 1}) async {
    try {
      final callable = AppConfig.functions.httpsCallable("search");
      final params = {
        "query": query,
        "rows_per_page": AppConfig.dictionaryPagination,
        "language": SPUtil.instance.currentLanguage,
        "page": page
      };
      final res = await callable.call(params);
      final data = jsonDecode(res.data);
      if (!data['success']) {
        return [];
      }
      return (data['data'] as List).map((json) {
        return Word.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Sentence>> searchSentence(int wordId,
      {int page = 1}) async {
    try {
      final callable = AppConfig.functions.httpsCallable("getMagicSentences");
      final params = {
        "word_id": wordId,
        "rows_per_page": AppConfig.dictionaryPagination,
        "language": SPUtil.instance.currentLanguage,
        "page": page,
        "full_sentence": true
      };

      final res = await callable.call(params);
      final data = jsonDecode(res.data);
      if (!data['success']) {
        return [];
      }
      final ret = (data['data']['sentences'] as List).map((e) {
        final json = <String, dynamic>{};
        json.addAll({"total_count": data['data']['total_count']});
        json.addAll(e);
        return Sentence.fromJson(json);
      }).toList();
      return ret;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addWordToUser(int wordId) async {
    try {
      final callable = AppConfig.functions.httpsCallable("addWordToUser");
      final params = {
        "word_id": wordId,
      };
      final res = await callable.call(params);
      final data = jsonDecode(res.data);
      if (!data['success']) {
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> learnWord(int wordId) async {
    try {
      final callable = AppConfig.functions.httpsCallable("learnWord");
      final params = {
        "word_id": wordId,
      };
      final res = await callable.call(params);
      final data = jsonDecode(res.data);
      if (!data['success']) {
        if (data['error'] == "Word already mastered") {
          return true;
        }
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
