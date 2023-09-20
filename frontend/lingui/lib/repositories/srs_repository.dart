import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lingui/model/question.dart';
import 'package:lingui/services/srs_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class SrsRepository extends ChangeNotifier {
  final cache = <String, SrsRepoItem<List<Question>>>{};
  int _index = 0;

  int get index => _index;

  void incrementIndex() {
    _index++;
    notifyListeners();
  }

  void setIndex(int val) {
    _index = val;
    notifyListeners();
  }

  List<Question> getQuestions() {
    return cache[SPUtil.instance.currentLanguage]?.data ?? [];
  }

  Future<bool> fetch(String language,
      {bool refresh = false, bool force = false}) async {
    final item = cache[language];
    final deviceCode = Platform.localeName.split("_").first;
    if (!(refresh && force) &&
        !refresh &&
        item != null &&
        item.date.difference(DateTime.now()).inMinutes < 1) {
      return false;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await SrsService.getQuestions(language, deviceCode);
        cache[language] = SrsRepoItem(res);
        notifyListeners();
        return res.isNotEmpty && res.length % AppConfig.pagination == 0;
      }
    }
    final res = await SrsService.getQuestions(language, deviceCode);
    final data = item.data + res;
    cache[language] = SrsRepoItem(data);
    notifyListeners();
    return res.isNotEmpty && res.length % AppConfig.pagination == 0;
  }

  void clear() {
    cache.clear();
  }
}

class SrsRepoItem<T> {
  final T data;
  final DateTime date = DateTime.now();

  SrsRepoItem(this.data);
}
