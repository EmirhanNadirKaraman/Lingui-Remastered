import 'package:flutter/material.dart';
import 'package:lingui/repositories/srs_repository.dart';
import 'package:lingui/services/srs_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class SrsModel extends ChangeNotifier {
  final SrsRepository srsRepository;
  final TextEditingController answerController = TextEditingController();
  bool _answering = false;
  bool _canFetchMore = true;
  bool _loading = false;

  bool get loading => _loading;
  bool get answering => _answering;
  bool get canFetchMore => _canFetchMore;

  SrsModel(this.srsRepository) {
    fetchQuestions();
  }

  Future<void> checkAnswer(int wordId, bool correct) async {
    setAnswering(true);
    final res = await SrsService.checkAnswer(wordId, correct);
    if (res) {
      srsRepository.incrementIndex();
      if (_canFetchMore && srsRepository.index % AppConfig.pagination == 8) {
        fetchQuestions();
      }
      answerController.clear();
    }
    setAnswering(false);
  }

  Future<void> fetchQuestions() async {
    setLoading(true);
    final res = await srsRepository.fetch(SPUtil.instance.currentLanguage);
    setCanFetchMore(res);
    setLoading(false);
  }

  void refresh() async {
    setLoading(true);
    final res = await srsRepository.fetch(SPUtil.instance.currentLanguage,
        refresh: true, force: true);

    srsRepository.setIndex(0);
    setCanFetchMore(res);
    setLoading(false);
  }

  void notify() => notifyListeners();

  void setAnswering(bool val) {
    _answering = val;
    notify();
  }

  void setLoading(bool val) {
    _loading = val;
    notify();
  }

  void setCanFetchMore(bool val) {
    _canFetchMore = val;
    notify();
  }
}
