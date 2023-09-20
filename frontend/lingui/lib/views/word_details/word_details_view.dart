import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/dictionary/widgets/dictionary_info.dart';
import 'package:lingui/views/word_details/word_details_model.dart';
import 'package:provider/provider.dart';

class WordDetailsView extends StatelessWidget {
  final int id;
  final String word;
  const WordDetailsView(
      {super.key,
      @PathParam("word") required this.word,
      @QueryParam('id') this.id = 0});

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    final dictionaryRepo =
        Provider.of<DictionaryRepository>(context, listen: false);
    return BaseView(
      createModel: (context) => WordDetailsModel(id, dictionaryRepo),
      builder: (context, model, size, padding, language) {
        final sentences =
            Provider.of<DictionaryRepository>(context).getSentenceResults(id);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: AppColors.background,
            title: model.loading
                ? null
                : Text(
                    "$word (${sentences.isEmpty ? 0 : sentences.first.totalCount})",
                    style: LinguiTextStyles.kbarlowSemiCondensed23BoldWhite,
                  ),
            centerTitle: true,
          ),
          body: model.loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: model.scrollController,
                          itemCount:
                              sentences.length + (model.paginating ? 1 : 0),
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
                            if (index == sentences.length) {
                              return SizedBox(
                                height: size.height * .1,
                                width: size.width,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                )),
                              );
                            }
                            return Padding(
                              padding:
                                  EdgeInsets.only(bottom: padding.bottom + 8),
                              child: DictionaryInfo(
                                  english: sentences[index].text,
                                  unkownCount: sentences[index].unkownCount),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
