import 'package:flutter/material.dart';
import 'package:lingui/model/leaderboard_item.dart';
import 'package:lingui/model/user_languages.dart';
import 'package:lingui/services/profile_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class ProfileRepository extends ChangeNotifier {
  final leaderboardCache = <String, ProgressRepoItem<List<LeaderBoardItem>>>{};
  final userKnownWordCountCache = <String, ProgressRepoItem<int>>{};
  UserLanguages? userLanguages;

  int getUserKnownWordCount() {
    return userKnownWordCountCache[SPUtil.instance.currentLanguage]?.data ?? 0;
  }

  List<LeaderBoardItem> getLeaderboard() {
    return leaderboardCache[SPUtil.instance.currentLanguage]?.data ?? [];
  }

  void clear() {
    leaderboardCache.clear();
    userKnownWordCountCache.clear();
    userLanguages = null;
  }

  Future<void> fetchUserLanguages() async {
    userLanguages = await ProfileService.getUserLanguages();
    notifyListeners();
  }

  Future<void> fetchKnownWordCount(String language,
      {bool refresh = false, bool force = false}) async {
    final item = userKnownWordCountCache[language];
    if (!(refresh && force) &&
        !refresh &&
        item != null &&
        item.date.difference(DateTime.now()).inMinutes < 1) {
      return;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await ProfileService.getUserKnownWordCount(language);
        userKnownWordCountCache[language] = ProgressRepoItem(res);
        notifyListeners();
        return;
      }
    }
    final res = await ProfileService.getUserKnownWordCount(language);
    userKnownWordCountCache[language] = ProgressRepoItem(res);
    notifyListeners();
    return;
  }

  Future<bool> fetchLeaderboard(String language,
      {bool refresh = false, bool force = false}) async {
    final item = leaderboardCache[language];
    if (!(refresh && force) &&
        item != null &&
        item.date.difference(DateTime.now()).inMinutes < 1) {
      return false;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await ProfileService.getLeaderboard(language);
        leaderboardCache[language] = ProgressRepoItem(res);
        notifyListeners();
        return res.isNotEmpty &&
            res.length % AppConfig.dictionaryPagination == 0;
      }
    }
    final page = (item.data.length ~/ AppConfig.dictionaryPagination) + 1;
    final res = await ProfileService.getLeaderboard(language);
    final data = item.data + res;
    leaderboardCache[language] = ProgressRepoItem(data);
    notifyListeners();
    return res.isNotEmpty && res.length % AppConfig.dictionaryPagination == 0;
  }
}

class ProgressRepoItem<T> {
  final T data;
  final DateTime date = DateTime.now();

  ProgressRepoItem(this.data);
}
