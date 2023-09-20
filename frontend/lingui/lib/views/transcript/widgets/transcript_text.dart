import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:provider/provider.dart';

import '../../../res/text_styles.dart';

class TranscriptText extends StatelessWidget {
  final List<WordToToken> transcript;
  final TextAlign textAlign;
  final Color textColor;
  final double fontSize;
  final Function(WordToToken) onWordtap;
  const TranscriptText({
    super.key,
    required this.onWordtap,
    required this.transcript,
    this.textAlign = TextAlign.start,
    this.textColor = AppColors.lightGrey,
    this.fontSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    final progressRepo = Provider.of<ProgressRepository>(context);
    return RichText(
      text: TextSpan(children: [
        for (final wtt in transcript)
          TextSpan(
            recognizer: TapGestureRecognizer()..onTap = () => onWordtap(wtt),
            text: wtt.word,
            style: LinguiTextStyles.kbarlowSemiCondensed27MediumWhite.copyWith(
              color: progressRepo.knowsWord(wtt.wordId)
                  ? Colors.lightGreenAccent
                  : !progressRepo.knowsWord(wtt.wordId) &&
                          progressRepo.wordIsInList(wtt.wordId)
                      ? Colors.red[900]
                      : textColor,
              fontSize: fontSize,
              wordSpacing: .5,
              height: 1.3,
            ),
          ),
      ]),
    );
  }
}
