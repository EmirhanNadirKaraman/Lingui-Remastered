import 'package:flutter/material.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/services/dictionary_service.dart';
import 'package:lingui/util/sp_util.dart';

class DictionaryBottomSheetModel extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final DictionaryRepository dictionaryRepository;
  final ProgressRepository progressRepository;
  final String word;
  final int wordId;

  bool _addingToList = false;
  bool _learningWord = false;
  bool _loading = true;
  bool _canFetchMore = true;
  bool _addedToList = false;
  bool _learnedWord = false;

  bool get loading => _loading;
  bool get addingToList => _addingToList;
  bool get learningWord => _learningWord;
  bool get learnedWord => _learnedWord;
  bool get addedToList => _addedToList;

  DictionaryBottomSheetModel(this.word, this.dictionaryRepository,
      this.progressRepository, this.wordId) {
    _fetch();
    scrollController.addListener(() {
      if (_canFetchMore &&
          !loading &&
          scrollController.offset / scrollController.position.maxScrollExtent >
              .8) {
        _fetch();
      }
    });
  }

  Future<void> onAddListTap() async {
    if (addedToList || learnedWord || addingToList || learningWord) return;
    setAddingToList(true);
    final res = await DictionaryService.addWordToUser(wordId);
    setAddedToList(res);
    setAddingToList(false);
    await progressRepository.fetch(SPUtil.instance.currentLanguage,
        refresh: true, force: true);
  }

  Future<void> onLearnWordTap() async {
    if (learnedWord || addedToList || addingToList || learningWord) return;
    setLearningWord(true);
    final res = await DictionaryService.learnWord(wordId);
    setLearnedWord(res);
    setLearningWord(false);
    await progressRepository.fetch(SPUtil.instance.currentLanguage,
        refresh: true, force: true);
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void setLearnedWord(bool val) {
    _learnedWord = val;
    notifyListeners();
  }

  void setAddedToList(bool val) {
    _addedToList = val;
    notifyListeners();
  }

  void setLearningWord(bool val) {
    _learningWord = val;
    notifyListeners();
  }

  void setAddingToList(bool val) {
    _addingToList = val;
    notifyListeners();
  }

  void setCanFetchMore(bool val) {
    _canFetchMore = val;
    notifyListeners();
  }

  void _fetch() async {
    setLoading(true);
    final res = await dictionaryRepository.searchSentence(
        wordId, SPUtil.instance.currentLanguage);
    setCanFetchMore(res);
    setLoading(false);
  }
}
