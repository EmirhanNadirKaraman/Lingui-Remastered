import 'package:flutter/material.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/views/video/video_model.dart';

import '../dictionary/widgets/dictionary_bottom_sheet/dictionary_bottom_sheet_view.dart';

class VideoController {
  final VideoModel _model;

  const VideoController(this._model);

  Future<void> onWordTap(BuildContext context, WordToToken wordToToken) async {
    _model.youtubeController.pause();
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * .8,
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
    //_model.youtubeController.play();
  }
}
