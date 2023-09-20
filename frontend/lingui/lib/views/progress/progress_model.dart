import 'package:flutter/material.dart';
import 'package:lingui/model/progress.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/util/sp_util.dart';

class ProgressModel extends ChangeNotifier {
  final ProgressRepository progressRepository;
  final ScrollController scrollController = ScrollController();
  bool _refreshing = false;
  bool _loading = false;
  bool _canFetchMore = true;

  bool get loading => _loading;
  bool get refreshing => _refreshing;

  ProgressModel(this.progressRepository) {
    _fetch();
    scrollController.addListener(() async {
      if (!loading &&
          _canFetchMore &&
          scrollController.offset / scrollController.position.maxScrollExtent >
              .8) {
        await _fetch();
      }
    });
  }

  Future<void> _fetch() async {
    setLoading(true);
    final res = await progressRepository.fetch(SPUtil.instance.currentLanguage);
    setCanFetchMore(res);
    setLoading(false);
  }

  Future<void> refresh() async {
    setRefreshing(true);
    final res = await progressRepository.fetch(
      SPUtil.instance.currentLanguage,
      refresh: true,
    );
    setCanFetchMore(res);
    setRefreshing(false);
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void setRefreshing(bool val) {
    _refreshing = val;
    notifyListeners();
  }

  void setCanFetchMore(bool val) {
    _canFetchMore = val;
    notifyListeners();
  }
}
