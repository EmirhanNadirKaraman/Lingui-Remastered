import 'package:flutter/material.dart';
import 'package:lingui/model/word.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';

class DictionarySearchItem extends StatelessWidget {
  final Word word;
  final Function() onTap;
  const DictionarySearchItem(
      {super.key, required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.background,
      title: Text(word.data,
          style: LinguiTextStyles.kbarlowSemiCondensed21BoldWhite),
      subtitle: Text(word.pos,
          style: LinguiTextStyles.kbarlowSemiCondensed17LightWhite),
    );
  }
}
