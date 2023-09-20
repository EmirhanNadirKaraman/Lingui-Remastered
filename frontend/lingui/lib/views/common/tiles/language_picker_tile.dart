import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';

class LanguagePickerTile extends StatelessWidget {
  final bool selected;
  final String text;
  final Function() onTap;
  const LanguagePickerTile(
      {super.key,
      required this.selected,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedTileColor: AppColors.grey,
      title: Text(
        text,
        style: LinguiTextStyles.kbarlowSemiCondensed17MediumWhite
            .copyWith(color: AppColors.white),
      ),
    );
  }
}
