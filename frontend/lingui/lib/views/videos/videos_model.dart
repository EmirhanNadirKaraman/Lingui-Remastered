import 'package:flutter/material.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:lingui/util/sp_util.dart';

class VideosModel extends ChangeNotifier {
  final VideoRepository videoRepository;
  final scrollController = ScrollController();
  int _currentPage = 0;
  bool _loading = false;
  bool _canFetchMore = true;
  bool _fetchingMore = false;

  bool get loading => _loading;
  bool get fetchingMore => _fetchingMore;

  VideosModel(this.videoRepository) {
    fetch();

    /*
    scrollController.addListener(() async {
      if (_canFetchMore &&
          !_fetchingMore &&
          !loading &&
          scrollController.offset / scrollController.position.maxScrollExtent >
              .8) {
        print("pag");
        await fetch();
        print("pag end");
      }
    });
    */
  }

  int get currentPage => _currentPage;

  void setCurrentPage(int val) {
    _currentPage = val;
    notifyListeners();
  }

  void setCanFetchMore(bool val) {
    _canFetchMore = val;
    notifyListeners();
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void setFetchngMore(bool val) {
    _fetchingMore = val;
    notifyListeners();
  }

  Future<void> fetch({bool refresh = true}) async {
    setLoading(true);
    setFetchngMore(true);
    final res = await videoRepository.fetch(
      SPUtil.instance.currentLanguage,
      refresh: refresh,
    );
    print("can fetch more $res");
    setCanFetchMore(res);
    setFetchngMore(false);
    setLoading(false);
  }
}
