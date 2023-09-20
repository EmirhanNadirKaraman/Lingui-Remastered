import 'package:flutter/material.dart';
import 'package:lingui/model/progress.dart';
import 'package:lingui/services/progress_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class ProgressRepository extends ChangeNotifier {
  final cache = <String, ProgressRepoItem<List<Progress>>>{};

  List<Progress> getSentenceResults() {
    return cache[SPUtil.instance.currentLanguage]?.data ?? [];
  }

  bool knowsWord(int wordId) {
    final i = cache[SPUtil.instance.currentLanguage]
        ?.data
        .indexWhere((element) => element.id == wordId && element.percent == 1);
    if (i != null && i != -1) {
      return true;
    }
    return false;
  }

  bool wordIsInList(int wordId) {
    final i = cache[SPUtil.instance.currentLanguage]
        ?.data
        .indexWhere((element) => element.id == wordId);
    if (i != null && i != -1) {
      return true;
    }
    return false;
  }

  void clear() {
    cache.clear();
  }

  Future<bool> fetch(String language,
      {bool refresh = false, bool force = false}) async {
    final item = cache[language];
    if (!(refresh && force) &&
        !refresh &&
        item != null &&
        item.date.difference(DateTime.now()).inMinutes < 1) {
      return false;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await ProgressService.listUserWords(language, 1);
        cache[language] = ProgressRepoItem(res);
        notifyListeners();
        return res.isNotEmpty &&
            res.length % AppConfig.dictionaryPagination == 0;
      }
    }
    final page = (item.data.length ~/ AppConfig.dictionaryPagination) + 1;
    final res = await ProgressService.listUserWords(language, page);
    final data = item.data + res;
    cache[language] = ProgressRepoItem(data);
    notifyListeners();
    return res.isNotEmpty && res.length % AppConfig.dictionaryPagination == 0;
  }
}

class ProgressRepoItem<T> {
  final T data;
  final DateTime date = DateTime.now();

  ProgressRepoItem(this.data);
}
