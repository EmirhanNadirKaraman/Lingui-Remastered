import 'dart:convert';
import 'package:lingui/model/leaderboard_item.dart';
import 'package:lingui/model/user_languages.dart';
import 'package:lingui/util/app_config.dart';

class ProfileService {
  static Future<void> updateUserTime(String languageCode) async {
    try {
      final params = {"language": languageCode};

      final callable = AppConfig.functions.httpsCallable("updateUserTime");
      await callable.call(params);
    } catch (e) {}
  }

  static Future<List<LeaderBoardItem>> getLeaderboard(
      String languageCode) async {
    try {
      final params = {"language": languageCode};

      final callable = AppConfig.functions.httpsCallable("getLeaderboard");
      final res = await callable.call(params);
      final data = json.decode(res.data);
      if (!data['success']) {
        return [];
      }
      return (data['data'] as List)
          .map((e) => LeaderBoardItem.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<int> getUserKnownWordCount(String languageCode) async {
    try {
      final params = {"language": languageCode};

      final callable = AppConfig.functions.httpsCallable("getUserWordCount");
      final res = await callable.call(params);
      final data = json.decode(res.data);
      if (!data['success']) {
        return 0;
      }

      return data['data']['count'];
    } catch (e) {
      return 0;
    }
  }

  static Future<UserLanguages?> getUserLanguages() async {
    try {
      final callable = AppConfig.functions.httpsCallable("getUserLanguages");
      final res = await callable.call();
      final data = json.decode(res.data);
      if (!data['success']) {
        return null;
      }
      return UserLanguages.fromJson(data['data']);
    } catch (e) {
      return null;
    }
  }
}
