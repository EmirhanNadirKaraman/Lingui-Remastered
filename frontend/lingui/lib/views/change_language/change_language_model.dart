import 'package:flutter/material.dart';
import 'package:lingui/model/word.dart';
import 'package:lingui/services/language_service.dart';

class ChangeLanguageModel extends ChangeNotifier {
  final Map<String, List<Word>> words = {};
  final List<Word> selectedWords = [];
  final PageController pageController = PageController();
  final ScrollController wordsScrollController = ScrollController();
  int _page = 0;
  String? _selectedLanguage;
  bool _loading = false;

  bool get loading => _loading;
  int get page => _page;
  String? get selectedLangauge => _selectedLanguage;

  ChangeLanguageModel() {
    _init();
    pageController.addListener(() {
      setPage(pageController.page?.round() ?? 0);
    });
  }

  void _init() async {
    setLoading(true);
    final res = await LanguageService.getMostFrequentWords();
    words.addAll(res);
    setLoading(false);
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void setPage(int val) {
    _page = val;
    notifyListeners();
  }

  void setSelectedLanguage(String val) {
    _selectedLanguage = val;
    notifyListeners();
  }

  void nextPage() {
    pageController.nextPage(
        duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
  }

  void previousPage() {
    pageController.previousPage(
        duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
  }

  void onChipTap(Word word) {
    if (selectedWords.contains(word)) {
      selectedWords.remove(word);
    } else {
      selectedWords.add(word);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
