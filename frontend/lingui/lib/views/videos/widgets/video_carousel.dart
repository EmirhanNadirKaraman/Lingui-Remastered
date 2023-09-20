import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/model/video.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/route/router.gr.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';

class VideoCarousel extends StatelessWidget {
  final Video video;
  final Size? size;
  const VideoCarousel({super.key, required this.video, this.size});

  @override
  Widget build(BuildContext context) {
    final language = Localized.of(context);
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(VideoRoute(vid: "watch/${video.id}"));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: size?.width ??
                    MediaQuery.of(context).size.height * .2 * 16 / 9,
                height: size?.height ?? MediaQuery.of(context).size.height * .2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: NetworkImage(video.thumbnail), fit: BoxFit.cover),
                ),
              ),
              Container(
                width: size?.width ??
                    MediaQuery.of(context).size.height * .2 * 16 / 9,
                height: size?.height ?? MediaQuery.of(context).size.height * .2,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Colors.black87, Colors.transparent])),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      video.title,
                      maxLines: null,
                      style: LinguiTextStyles.kbarlowSemiCondensed19BoldWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: size?.width ??
                    MediaQuery.of(context).size.height * .2 * 16 / 9,
                height: size?.height ?? MediaQuery.of(context).size.height * .2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6, bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[850]),
                          child: Text(
                            "${video.duration.inMinutes}m",
                            style: LinguiTextStyles
                                .kbarlowSemiCondensed15BoldWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const VSpacer(
            ratio: .5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                video.baseWord,
                style: LinguiTextStyles.kbarlowSemiCondensed17BoldWhite
                    .copyWith(color: AppColors.lightGrey),
              ),
              GestureDetector(
                onTap: () {
                  AutoRouter.of(context).pushNamed("/transcript/${video.id}");
                },
                child: Text(
                  language.showTranscript,
                  style: LinguiTextStyles.kbarlowSemiCondensed17MediumWhite
                      .copyWith(color: AppColors.lightGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
