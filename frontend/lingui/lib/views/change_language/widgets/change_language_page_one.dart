import 'package:flutter/material.dart';
import 'package:lingui/res/extensions/string_extensions.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';
import 'package:lingui/views/common/tiles/language_picker_tile.dart';

class CLPageOne extends StatelessWidget {
  final Function(String language) onLanguageSelect;
  final String? selectedLanguage;
  final List<String> words;
  const CLPageOne(
      {super.key,
      required this.words,
      required this.onLanguageSelect,
      required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final language = Localized.of(context);
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top + 8,
        ),
        const VSpacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              language.chooseNewLanguage,
              style: LinguiTextStyles.kbarlowSemiCondensed21BoldWhite,
            ),
          ),
        ),
        const VSpacer(),
        for (final word in words)
          LanguagePickerTile(
              selected: selectedLanguage == word,
              text: word.getLanguage(Localized.of(context)),
              onTap: () => onLanguageSelect(word)),
      ],
    );
  }
}
