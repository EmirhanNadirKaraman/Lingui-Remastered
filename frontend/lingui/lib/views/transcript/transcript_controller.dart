import 'package:flutter/material.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/res/colors.dart';

import '../dictionary/widgets/dictionary_bottom_sheet/dictionary_bottom_sheet_view.dart';

class TranscriptController {
  Future<void> onWordTap(BuildContext context, WordToToken wordToToken) async {
    if (wordToToken.word.isEmpty) return;
    await showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: DictionaryBottomSheetView(
                word: wordToToken.token,
                wordId: wordToToken.wordId,
                popVisible: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
