import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/spacers/h_spacer.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';

class DictionaryInfo extends StatelessWidget {
  final String english;
  final int unkownCount;
  const DictionaryInfo(
      {super.key, required this.english, required this.unkownCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              english,
              maxLines: null,
              style: LinguiTextStyles.kbarlowSemiCondensed21MediumWhite,
            ),
          ),
          const HSpacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red),
              ),
              child: Text(
                unkownCount.toString(),
                style: LinguiTextStyles.kbarlowSemiCondensed15MediumWhite,
              ),
            ),
          )
        ],
      ),
    );
  }
}
