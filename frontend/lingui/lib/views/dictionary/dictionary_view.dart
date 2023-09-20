import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/dictionary/dictionary_controller.dart';
import 'package:lingui/views/dictionary/dictionary_model.dart';
import 'package:lingui/views/dictionary/widgets/dictionary_search_item.dart';
import 'package:provider/provider.dart';

class DictionaryView extends StatelessWidget {
  const DictionaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dictionaryRepo =
        Provider.of<DictionaryRepository>(context, listen: false);
    return BaseView(
      createModel: (context) => DictionaryModel(dictionaryRepo),
      builder: (context, model, size, padding, language) {
        final controller = DictionaryController(model);
        final dictionaryRepoListenable =
            Provider.of<DictionaryRepository>(context);
        final words = dictionaryRepoListenable
            .getWordResults(model.searchController.text.trim());
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Text(
              language.dictionary,
              style: LinguiTextStyles.kbarlowSemiCondensed25BoldWhite,
            ),
            centerTitle: false,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: CupertinoSearchTextField(
                  placeholder: language.searchWord,
                  controller: model.searchController,
                  onChanged: model.onTextChanged,
                  style: LinguiTextStyles.kbarlowSemiCondensed19MediumBlack
                      .copyWith(color: AppColors.white.withOpacity(.8)),
                  itemColor: AppColors.white,
                ),
              ),
              if (model.searching)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: words.length,
                    separatorBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: AppColors.background,
                      );
                    },
                    itemBuilder: (context, index) {
                      return DictionarySearchItem(
                          onTap: () => controller.onWordTap(
                              context, words[index].id, words[index].data),
                          word: words[index]);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
