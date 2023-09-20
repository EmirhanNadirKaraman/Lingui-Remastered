import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/services/language_service.dart';
import 'package:lingui/util/sp_util.dart';
import 'package:lingui/views/initial_language/initial_language_model.dart';

class InitialLanguageController {
  final InitialLanguageModel model;

  const InitialLanguageController(this.model);

  Future<void> onFinishTap(BuildContext context) async {
    print("onFinishTap 1");
    if (model.selectedLangauge == null) return;
    model.setLoading(true);
    final addedLanguage =
        await LanguageService.addLanguageToUser(model.selectedLangauge!);
    print("onFinishTap 2");
    if (!addedLanguage) {
      model.setLoading(false);
      return;
    }
    print("onFinishTap 3");
    final addedWords =
        await LanguageService.addWordsToUser(model.selectedWords);
    if (!addedWords) {
      model.setLoading(false);
      return;
    }
    await SPUtil.instance.setCurrentLanguage(model.selectedLangauge!);
    AutoRouter.of(context).replaceNamed("/b");
  }
}
