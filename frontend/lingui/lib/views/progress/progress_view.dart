import 'package:flutter/material.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/progress/progress_model.dart';
import 'package:lingui/views/progress/widgets/progress_table.dart';
import 'package:provider/provider.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    final progressRepo =
        Provider.of<ProgressRepository>(context, listen: false);
    return BaseView(
      createModel: (context) => ProgressModel(progressRepo),
      builder: (context, model, size, padding, language) {
        final progressRepo = Provider.of<ProgressRepository>(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: null,
            leadingWidth: 0,
            elevation: 0,
            backgroundColor: AppColors.background,
            centerTitle: false,
            actions: [
              if (model.refreshing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: model.refresh,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                )
            ],
            title: Text(language.progress,
                style: LinguiTextStyles.kbarlowSemiCondensed25BoldWhite),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ProgressTable(
              progresses: progressRepo.getSentenceResults(),
              controller: model.scrollController,
              loading: model.loading,
            ),
          ),
        );
      },
    );
  }
}
