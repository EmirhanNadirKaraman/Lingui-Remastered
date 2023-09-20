import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/change_language/change_language_controller.dart';
import 'package:lingui/views/change_language/change_language_model.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/initial_language/widgets/page_one/il_page_one.dart';
import 'package:lingui/views/initial_language/widgets/page_two/il_page_two.dart';

class ChangeLanguageView extends StatelessWidget {
  const ChangeLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      createModel: (context) => ChangeLanguageModel(),
      builder: (context, model, size, padding, language) {
        final controller = ChangeLanguageController(model);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          backgroundColor: AppColors.background,
          body: model.loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Stack(
                  children: [
                    SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: model.pageController,
                              children: [
                                ILPageOne(
                                  words: model.words.keys.toList(),
                                  onLanguageSelect: model.setSelectedLanguage,
                                  selectedLanguage: model.selectedLangauge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: ILPageTwo(
                                    scrollController:
                                        model.wordsScrollController,
                                    words:
                                        model.words[model.selectedLangauge] ??
                                            [],
                                    selectedWords: model.selectedWords,
                                    onChipTap: model.onChipTap,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: padding.bottom + 8,
                      right: 12,
                      left: 12,
                      child: SizedBox(
                        width: size.width,
                        child: Row(
                          children: [
                            if (model.page != 0)
                              GestureDetector(
                                onTap: model.previousPage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: AppColors.blue,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    language.back,
                                    style: LinguiTextStyles
                                        .kbarlowSemiCondensed15BoldWhite,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            if (model.page == 0)
                              GestureDetector(
                                onTap: model.nextPage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: AppColors.blue,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    language.next,
                                    style: LinguiTextStyles
                                        .kbarlowSemiCondensed15BoldWhite,
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  controller.onFinishTap(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: AppColors.blue,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    language.done,
                                    style: LinguiTextStyles
                                        .kbarlowSemiCondensed15BoldWhite,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        );
      },
    );
  }
}
