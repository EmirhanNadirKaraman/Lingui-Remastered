import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingui/views/common/spacers/h_spacer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatelessWidget {
  final YoutubePlayerController controller;
  final double width;
  final Function() onExpandTap;
  final Function() onContractTap;
  final Function() ccTap;
  final bool expanded;
  final bool ccOn;
  const VideoPlayer(
      {Key? key,
      required this.controller,
      required this.width,
      required this.onExpandTap,
      required this.expanded,
      required this.onContractTap,
      required this.ccTap,
      required this.ccOn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width,
      duration: const Duration(milliseconds: 150),
      color: Colors.white,
      child: YoutubePlayer(
        progressIndicatorColor: Colors.red,
        progressColors: ProgressBarColors(
            backgroundColor: Colors.grey,
            handleColor: Colors.red,
            playedColor: Colors.red,
            bufferedColor: Colors.grey[200]),
        topActions: [
          GestureDetector(
            onTap: () {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              AutoRouter.of(context).pop();
            },
            child: Icon(
              Icons.adaptive.arrow_back_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              await AutoRouter.of(context).pushNamed(
                  "/transcript/${controller.value.metaData.videoId}");
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            },
            child: const Icon(
              Icons.text_fields,
              color: Colors.white,
              size: 28,
            ),
          ),
          const HSpacer(),
          GestureDetector(
            onTap: ccTap,
            child: Icon(
              ccOn ? Icons.closed_caption_rounded : Icons.closed_caption_off,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
        bottomActions: [
          CurrentPosition(),
          const HSpacer(),
          ProgressBar(isExpanded: true),
          const HSpacer(),
          GestureDetector(
            onTap: !expanded ? onExpandTap : onContractTap,
            child: Icon(
              !expanded
                  ? Icons.fullscreen_rounded
                  : Icons.fullscreen_exit_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
        aspectRatio: 4 / 3,
        controller: controller,
        onReady: () {},
      ),
    );
  }
}
