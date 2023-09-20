import 'package:flutter/material.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/util/sp_util.dart';

class WordDetailsModel extends ChangeNotifier {
  final int word;
  final ScrollController scrollController = ScrollController();
  final DictionaryRepository dictionaryRepository;
  bool _loading = true;
  bool _paginating = false;
  bool _canFetchMore = true;

  bool get loading => _loading;
  bool get paginating => _paginating;

  WordDetailsModel(this.word, this.dictionaryRepository) {
    _init();
    scrollController.addListener(() async {
      if (!paginating &&
          _canFetchMore &&
          scrollController.offset / scrollController.position.maxScrollExtent >
              .75) {
        await paginate();
      }
    });
  }

  void setPaginating(bool val) {
    _paginating = val;
    notifyListeners();
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void setCanFetchMore(bool val) {
    _canFetchMore = val;
    notifyListeners();
  }

  Future<void> paginate() async {
    setPaginating(true);
    final res = await dictionaryRepository
        .searchSentence(word, SPUtil.instance.currentLanguage, paginate: true);
    setCanFetchMore(res);
    setPaginating(false);
  }

  void _init() async {
    notifyListeners();
    final res = await dictionaryRepository.searchSentence(
        word, SPUtil.instance.currentLanguage);
    setCanFetchMore(res);
    setLoading(false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
