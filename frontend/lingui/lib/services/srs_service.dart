import 'dart:convert';

import 'package:lingui/model/question.dart';
import 'package:lingui/util/app_config.dart';

class SrsService {
  static Future<List<Question>> getQuestions(
      String targetLanguageCode, String nativeLanguageCode) async {
    try {
      final params = {
        "native_language": nativeLanguageCode,
        "target_language": targetLanguageCode,
        "is_exact": true,
      };
      print(params);
      final callable = AppConfig.functions.httpsCallable("getClozeQuestions");
      final res = await callable.call(params);
      final data = json.decode(res.data);
      if (!data['success']) {
        return [];
      }
      return (data['data'] as List).map((e) => Question.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> checkAnswer(int wordId, bool correct) async {
    try {
      final params = {
        "word_id": wordId,
        "correct": correct,
      };
      print(params);

      final callable = AppConfig.functions.httpsCallable("checkAnswer");
      final res = await callable.call(params);
      final data = json.decode(res.data);
      print(data);
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
