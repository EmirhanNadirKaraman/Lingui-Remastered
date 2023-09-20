import 'dart:convert';

import 'package:lingui/model/word.dart';
import 'package:lingui/util/app_config.dart';

class LanguageService {
  static Future<bool> addLanguageToUser(String languageCode) async {
    try {
      final callable = AppConfig.functions.httpsCallable("addLanguageToUser");
      final res = await callable.call({"language": languageCode});
      final data = json.decode(res.data);
      if (!data['success']) {
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<String> getCurrentLanguage() async {
    try {
      final callable = AppConfig.functions.httpsCallable("getCurrentLanguage");
      final res = await callable.call({});
      final data = jsonDecode(res.data);
      return data['language_code'] ?? "";
    } catch (e) {
      print(e);
      return "";
    }
  }

  static Future<Map<String, List<Word>>> getMostFrequentWords(
      {int size = 100}) async {
    try {
      final callable =
          AppConfig.functions.httpsCallable("getMostFrequentWords");
      final res = await callable.call({"word_count": size});
      final data = json.decode(res.data);
      final words = <String, List<Word>>{};
      for (final language in data.keys) {
        words[language] = (data[language] as List).map((json) {
          return Word.fromJson(json);
        }).toList();
      }
      return words;
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<bool> addWordsToUser(List<Word> words) async {
    try {
      final callable =
          AppConfig.functions.httpsCallable("addMultipleWordToUser");
      final res = await callable
          .call({"word_ids": words.map((word) => word.id).toList()});
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
}
