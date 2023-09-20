import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/util/sp_util.dart';

class DictionaryModel extends ChangeNotifier {
  final DictionaryRepository dictionaryRepository;
  final TextEditingController searchController = TextEditingController();
  CancelableOperation? cancelableOperation;
  bool _searching = false;

  bool get searching => _searching;

  DictionaryModel(this.dictionaryRepository) {
    searchController.addListener(() {
      notifyListeners();
    });
  }

  Future<void> onTextChanged(String val) async {
    cancelableOperation?.cancel();
    setSearching(true);
    cancelableOperation = CancelableOperation.fromFuture(
        Future.delayed(const Duration(milliseconds: 250)));
    await cancelableOperation!.value.then((value) async {
      await dictionaryRepository.searchWord(
          val, SPUtil.instance.currentLanguage);
    });
    setSearching(false);
    notifyListeners();
  }

  void setSearching(bool val) {
    _searching = val;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
