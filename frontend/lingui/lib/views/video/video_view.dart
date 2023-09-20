import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/video/video_controller.dart';
import 'package:lingui/views/video/video_model.dart';
import 'package:lingui/views/video/widgets/video_expanded_subtitle.dart';
import 'package:lingui/views/video/widgets/video_player.dart';
import 'package:lingui/views/video/widgets/video_subtitle.dart';
import 'package:provider/provider.dart';

class VideoView extends StatelessWidget {
  final String vid;
  const VideoView({super.key, @PathParam("vid") required this.vid});

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    final videoRepo = Provider.of<VideoRepository>(context, listen: false);
    return BaseView(
      createModel: (context) => VideoModel(vid, videoRepo),
      builder: (context, model, size, padding, language) {
        final controller = VideoController(model);
        return LayoutBuilder(builder: (context, constraints) {
          final p = MediaQuery.of(context).padding;
          final s = MediaQuery.of(context).size;
          final videoRepo = Provider.of<VideoRepository>(context);
          final subtitle =
              videoRepo.getSubtitle(videoRepo.getVideos()[videoRepo.index].id);
          return Scaffold(
            backgroundColor: AppColors.black,
            body: SizedBox(
              height: s.height,
              width: s.width,
              child: Padding(
                padding: EdgeInsets.only(left: p.left, right: p.right),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: VideoPlayer(
                        ccOn: model.expandedSubtitleVisible,
                        expanded: model.videoExpanded,
                        ccTap: () => model.setExpandedSubtitleVisilbe(
                            !model.expandedSubtitleVisible),
                        onContractTap: model.openSubtitles,
                        onExpandTap: model.closeSubtitles,
                        width: !model.videoExpanded
                            ? s.width - s.width * .35 - p.left - p.right
                            : s.width - p.left - p.right,
                        controller: model.youtubeController,
                      ),
                    ),
                    if (model.controlsVisible)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: !model.videoExpanded
                              ? s.width - s.width * .35 - p.left - p.right
                              : s.width - p.left - p.right,
                          height: s.height,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: model.previousVideo,
                                child: Icon(
                                  Icons.skip_previous,
                                  color: Colors.white,
                                  size: model.videoExpanded ? 32 : 28,
                                ),
                              ),
                              GestureDetector(
                                onTap: model.nextVideo,
                                child: Icon(
                                  Icons.skip_next,
                                  color: Colors.white,
                                  size: model.videoExpanded ? 32 : 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: VideoSubtitle(
                        currentLocation: model
                            .youtubeController.value.position.inMilliseconds,
                        onNextTap: model.nextVideo,
                        onPreviousTap: model.previousVideo,
                        size: s,
                        onWordTap: (word) =>
                            controller.onWordTap(context, word),
                        onCloseTap: model.closeSubtitles,
                        subtitle: subtitle,
                        offset: model.subtitleOffset,
                        visible: model.subtitleVisible,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: model.controlsVisible
                                ? p.bottom + 16.0
                                : p.bottom),
                        child: VideoExpandedSubtitle(
                          currentLocation: model
                              .youtubeController.value.position.inMilliseconds,
                          onWordTap: (word) =>
                              controller.onWordTap(context, word),
                          visible: model.expandedSubtitleVisible &&
                              model.videoExpanded,
                          subtitle: subtitle,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
