import 'package:flutter/material.dart';
import 'package:lingui/model/word.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';

class CLPageTwo extends StatelessWidget {
  final List<Word> words;
  final List<Word> selectedWords;
  final Function(Word word) onChipTap;
  final ScrollController scrollController;
  const CLPageTwo(
      {super.key,
      required this.scrollController,
      required this.words,
      required this.selectedWords,
      required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    final language = Localized.of(context);
    return SingleChildScrollView(
      controller: scrollController,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).padding.top + 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  language.chooseKnownWords,
                  style: LinguiTextStyles.kbarlowSemiCondensed25BoldWhite,
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 10,
          ),
          for (final word in words)
            GestureDetector(
              onTap: () => onChipTap(word),
              child: Chip(
                label: Text(
                  word.data,
                  style: LinguiTextStyles.kbarlowSemiCondensed15LightWhite
                      .copyWith(
                          color: selectedWords.contains(word)
                              ? AppColors.background
                              : AppColors.white),
                ),
                backgroundColor: selectedWords.contains(word)
                    ? AppColors.white
                    : AppColors.background,
                shape: StadiumBorder(
                  side: BorderSide(
                      color: selectedWords.contains(word)
                          ? AppColors.background
                          : AppColors.white),
                ),
              ),
            ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).padding.bottom + 10 + kToolbarHeight,
          ),
        ],
      ),
    );
  }
}
