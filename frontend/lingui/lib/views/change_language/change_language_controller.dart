// ignore_for_file: use_build_context_synchronously
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/services/language_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/views/change_language/change_language_model.dart';

class ChangeLanguageController {
  final ChangeLanguageModel model;

  const ChangeLanguageController(this.model);

  Future<void> onFinishTap(BuildContext context) async {
    if (model.selectedLangauge == null) return;
    model.setLoading(true);
    final addedLanguage =
        await LanguageService.addLanguageToUser(model.selectedLangauge!);
    if (!addedLanguage) {
      model.setLoading(false);
      return;
    }
    final addedWords =
        await LanguageService.addWordsToUser(model.selectedWords);
    if (!addedWords) {
      model.setLoading(false);
      return;
    }
    await AppConfig.refresh(context, model.selectedLangauge!);
    AutoRouter.of(context).pop();
  }
}
