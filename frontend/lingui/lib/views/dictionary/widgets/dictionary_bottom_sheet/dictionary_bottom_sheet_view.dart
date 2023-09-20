import 'package:flutter/material.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/common/spacers/h_spacer.dart';
import 'package:lingui/views/dictionary/widgets/dictionary_bottom_sheet/dictionary_bottom_sheet_model.dart';
import 'package:lingui/views/dictionary/widgets/dictionary_info.dart';
import 'package:provider/provider.dart';

import '../../../common/spacers/v_spacer.dart';

class DictionaryBottomSheetView extends StatelessWidget {
  final String word;
  final int wordId;
  final bool popVisible;
  const DictionaryBottomSheetView(
      {super.key,
      required this.word,
      required this.wordId,
      this.popVisible = false});

  @override
  Widget build(BuildContext context) {
    final progressRepo = Provider.of<ProgressRepository>(context);
    return BaseView(
      createModel: (context) => DictionaryBottomSheetModel(
          word,
          Provider.of<DictionaryRepository>(context, listen: false),
          Provider.of<ProgressRepository>(context, listen: false),
          wordId),
      builder: (context, model, size, padding, language) {
        final dictionaryRepoListenable =
            Provider.of<DictionaryRepository>(context);
        final sentences = dictionaryRepoListenable.getSentenceResults(wordId);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: model.loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              "$word (${sentences.length})",
                              style: LinguiTextStyles
                                  .kbarlowSemiCondensed23BoldWhite,
                            ),
                          ),
                        ),
                        Visibility(
                            visible: popVisible,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 28,
                              ),
                            ))
                      ],
                    ),
                    const VSpacer(),
                    const Divider(
                      color: Colors.white,
                      height: .5,
                    ),
                    const VSpacer(),
                    Expanded(
                      child: ListView.separated(
                        itemCount: sentences.length,
                        separatorBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              color: Colors.white,
                              height: .5,
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    index == sentences.length - 1 && !popVisible
                                        ? padding.bottom + 8
                                        : 0),
                            child: DictionaryInfo(
                              english: sentences[index].text,
                              unkownCount: sentences[index].unkownCount,
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      height: .5,
                    ),
                    const VSpacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (progressRepo.wordIsInList(wordId) ||
                                    progressRepo.knowsWord(wordId)) return;
                                model.onLearnWordTap();
                              },
                              child: Text(
                                language.alreadyKnown,
                                style: LinguiTextStyles
                                    .kbarlowSemiCondensed19BoldWhite
                                    .copyWith(color: Colors.grey[700]),
                              ),
                            ),
                            const HSpacer(),
                            if (progressRepo.knowsWord(wordId))
                              const Icon(
                                Icons.check,
                                color: Colors.blue,
                              )
                            else if (model.learningWord)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            else if (model.learnedWord)
                              const Icon(
                                Icons.check,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            if (progressRepo.wordIsInList(wordId))
                              const Icon(
                                Icons.check,
                                color: Colors.blue,
                              )
                            else if (model.addingToList)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            else if (model.addedToList)
                              const Icon(
                                Icons.check,
                                color: Colors.blue,
                              ),
                            const HSpacer(),
                            GestureDetector(
                              onTap: () {
                                if (progressRepo.wordIsInList(wordId) ||
                                    progressRepo.knowsWord(wordId)) return;
                                model.onAddListTap();
                              },
                              child: Text(
                                language.addToList,
                                style: LinguiTextStyles
                                    .kbarlowSemiCondensed19BoldWhite
                                    .copyWith(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
        );
      },
    );
  }
}
