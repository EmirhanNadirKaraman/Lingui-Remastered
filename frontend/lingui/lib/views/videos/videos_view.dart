import 'package:flutter/material.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/videos/videos_model.dart';
import 'package:lingui/views/videos/widgets/video_carousel.dart';
import 'package:provider/provider.dart';

class VideosView extends StatelessWidget {
  const VideosView({super.key});

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    final videoRepo = Provider.of<VideoRepository>(context, listen: false);
    return BaseView(
      createModel: (context) => VideosModel(videoRepo),
      builder: (context, model, size, padding,language) {
        final videoRepo = Provider.of<VideoRepository>(context);
        final videos = videoRepo.getVideos();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            leadingWidth: 0,
            centerTitle: false,
            title: Text(
              language.videos,
              style: LinguiTextStyles.kbarlowSemiCondensed25BoldWhite,
            ),
            actions: [
              if (model.loading)
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
                  onPressed: () => model.fetch(refresh: true),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                )
            ],
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videos.length + (model.fetchingMore ? 1 : 0),
              controller: model.scrollController,
              itemBuilder: (context, index) {
                if (index == videos.length) {
                  return SizedBox(
                    height: size.height * 1,
                    width: size.width,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: VideoCarousel(
                      size: Size(size.width, size.width * 9 / 16),
                      video: videos[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
