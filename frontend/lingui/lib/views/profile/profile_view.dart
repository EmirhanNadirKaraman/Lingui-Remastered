import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/repositories/profile_repository.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/extensions/string_extensions.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/common/spacers/h_spacer.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';
import 'package:lingui/views/profile/profile_model.dart';
import 'package:lingui/views/profile/widgets/leaderboard.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    final profileRepo = Provider.of<ProfileRepository>(context, listen: false);
    return BaseView(
      createModel: (context) => ProfileModel(profileRepo),
      builder: (context, model, size, padding, language) {
        final profileRepo = Provider.of<ProfileRepository>(context);
        final userLangauges = profileRepo.userLanguages;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Text(
              language.profile,
              style: LinguiTextStyles.kbarlowSemiCondensed25BoldWhite,
            ),
            actions: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (userLangauges == null) return;
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (context) {
                          return Container(
                              color: AppColors.background,
                              width: size.width,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final language
                                      in userLangauges.learnedLanguageCodes)
                                    Column(
                                      children: [
                                        const VSpacer(),
                                        GestureDetector(
                                          onTap: () async {
                                            await model.refresh(
                                                context, language);
                                            AutoRouter.of(context).pop();
                                          },
                                          child: Text(
                                            language.getLanguage(
                                                Localized.of(context)),
                                            style: LinguiTextStyles
                                                .kbarlowSemiCondensed17MediumWhite
                                                .copyWith(
                                                    color: language ==
                                                            SPUtil.instance
                                                                .currentLanguage
                                                        ? Colors.blue
                                                        : Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const VSpacer(
                                    ratio: 1,
                                  ),
                                  const Divider(),
                                  const VSpacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      await AutoRouter.of(context)
                                          .pushNamed("/change-language");
                                      AutoRouter.of(context).pop();
                                    },
                                    child: Text(
                                      language.learnNewLanguage,
                                      style: LinguiTextStyles
                                          .kbarlowSemiCondensed19MediumWhite,
                                    ),
                                  ),
                                  SizedBox(
                                    height: padding.bottom + 30,
                                  )
                                ],
                              ));
                        });
                  },
                  child: Row(
                    children: [
                      Text(
                        language.languageLearning,
                        style:
                            LinguiTextStyles.kbarlowSemiCondensed17MediumWhite,
                      ),
                      const HSpacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 24),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          SPUtil.instance.currentLanguage
                              .getLanguage(Localized.of(context)),
                          style: LinguiTextStyles
                              .kbarlowSemiCondensed15MediumWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const HSpacer()
            ],
            centerTitle: false,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: model.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: size.width * .15,
                                    foregroundImage:
                                        AppConfig.auth.currentUser?.photoURL ==
                                                null
                                            ? null
                                            : NetworkImage(AppConfig
                                                .auth.currentUser!.photoURL!),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        AppConfig.auth.currentUser
                                                ?.displayName ??
                                            "",
                                        style: LinguiTextStyles
                                            .kbarlowSemiCondensed21MediumWhite,
                                      ),
                                      const VSpacer(),
                                      Text(
                                        language.exploredWord(
                                            count: profileRepo
                                                .getUserKnownWordCount()),
                                        style: LinguiTextStyles
                                            .kbarlowSemiCondensed17MediumWhite
                                            .copyWith(
                                                color: AppColors.lightGrey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const VSpacer(
                              ratio: 1,
                            ),
                            Text(
                              language.leaderboard,
                              style: LinguiTextStyles
                                  .kbarlowSemiCondensed25MediumWhite,
                            ),
                            const VSpacer(),
                            Expanded(
                              child: Leaderboard(
                                  data: profileRepo.getLeaderboard()),
                            )
                          ],
                        ),
                      ),
              ),
              if (model.changingLanguage)
                Container(
                  color: Colors.black.withOpacity(.7),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
