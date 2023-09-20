import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:provider/provider.dart';

extension ClickableStringExtension on List<WordToToken> {
  RichText toClickableSubtitle(
      Function(WordToToken) onTap, BuildContext context,
      {TextAlign textAlign = TextAlign.start,
      Color textColor = AppColors.lightGrey,
      double? fontSize,
      bool addSpace = false}) {
    final progressRepo = Provider.of<ProgressRepository>(context);
    List<InlineSpan> children = [];
    for (final wtt in this) {
      children.add(
        TextSpan(
          recognizer: TapGestureRecognizer()..onTap = () => onTap(wtt),
          text: wtt.word,
          style: LinguiTextStyles.kbarlowSemiCondensed27MediumWhite.copyWith(
              color: progressRepo.knowsWord(wtt.wordId)
                  ? Colors.lightGreenAccent
                  : !progressRepo.knowsWord(wtt.wordId) &&
                          progressRepo.wordIsInList(wtt.wordId)
                      ? Colors.red[900]
                      : textColor,
              fontSize: fontSize),
        ),
      );
      if (addSpace) {
        children.add(const TextSpan(text: " "));
      }
    }
    InlineSpan span = TextSpan(children: children);
    RichText res = RichText(
      text: span,
      textAlign: textAlign,
    );
    return res;
  }
}

extension LanguageExtension on String {
  String getLanguage(Localized language) {
    switch (this) {
      case "de":
        return language.de;
      case "en":
        return language.en;
      case "es":
        return language.es;
      case "fr":
        return language.fr;
      case "it":
        return language.it;
      case "ja":
        return language.ja;
      case "ko":
        return language.ko;
      case "pl":
        return language.pl;
      case "pt":
        return language.pt;
      case "ru":
        return language.ru;
      case "sv":
        return language.sv;
      default:
        return "";
    }
  }
}

extension SrsExtension on String {
  RichText toSrsText({String answer = "example", String current = ""}) {
    var words = split("_");
    words.insert(1, "_");
    List<InlineSpan> children = [];
    for (final word in words) {
      String text = "";
      TextSpan child;
      if (word == "_") {
        List<TextSpan> innerChild = [];
        for (int i = 0; i < answer.length; i++) {
          if (i < current.length) {
            if (current.characters.elementAt(i) ==
                    answer.characters.elementAt(i) ||
                ("'" == answer.characters.elementAt(i) &&
                    current.characters.elementAt(i) == "’")) {
              innerChild.add(TextSpan(
                  text: current.characters.elementAt(i),
                  style: LinguiTextStyles.kbarlowSemiCondensed21MediumWhite
                      .copyWith(color: Colors.greenAccent)));
            } else {
              innerChild.add(TextSpan(
                  text: current.characters.elementAt(i),
                  style: LinguiTextStyles.kbarlowSemiCondensed21MediumWhite
                      .copyWith(color: Colors.red)));
            }
          } else {
            innerChild.add(const TextSpan(
              text: "_",
            ));
          }
        }
        child = TextSpan(
            children: innerChild,
            style: LinguiTextStyles.kbarlowSemiCondensed21MediumWhite.copyWith(
                color: word == "_" ? Colors.grey : Colors.white,
                fontWeight: word == "_" ? FontWeight.bold : null));
      } else {
        text = word;
        child = TextSpan(
            text: text,
            style: LinguiTextStyles.kbarlowSemiCondensed21MediumWhite.copyWith(
                color: word == "_" ? Colors.grey : Colors.white,
                fontWeight: word == "_" ? FontWeight.bold : null));
      }
      children.add(child);
    }
    InlineSpan span = TextSpan(children: children);
    RichText res = RichText(
      text: span,
      textAlign: TextAlign.center,
    );

    return res;
  }
}
