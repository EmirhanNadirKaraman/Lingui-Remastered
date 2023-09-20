import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/extensions/string_extensions.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/transcript/transcript_controller.dart';
import 'package:lingui/views/transcript/transcript_model.dart';
import 'package:lingui/views/transcript/widgets/transcript_text.dart';
import 'package:provider/provider.dart';

class TranscriptView extends StatelessWidget {
  final String vid;
  const TranscriptView({super.key, @PathParam("vid") required this.vid});

  @override
  Widget build(BuildContext context) {
    final videoRepository =
        Provider.of<VideoRepository>(context, listen: false);

    return BaseView(
      createModel: (context) => TranscriptModel(videoRepository, vid),
      builder: (context, model, size, padding, language) {
        final controller = TranscriptController();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Text(
              model.video?.title ?? "",
              style: LinguiTextStyles.kbarlowSemiCondensed23MediumWhite,
            ),
            leading: GestureDetector(
              onTap: () {
                AutoRouter.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
          body: model.loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : model.video == null || model.transcript == null
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          TranscriptText(
                            onWordtap: (w) {
                              controller.onWordTap(context, w);
                            },
                            transcript: model.tokens,
                            fontSize: 21,
                          ),
                          SizedBox(
                            height: padding.bottom + 10,
                          )
                        ],
                      )),
                    ),
        );
      },
    );
  }
}
