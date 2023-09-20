import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoModel extends ChangeNotifier {
  final VideoRepository videoRepository;
  final String link;
  late YoutubePlayerController youtubeController;
  Offset _subtitleOffset = const Offset(0, 0);
  bool _subtitleVisible = true;
  bool _videoExpanded = false;
  bool _expandedSubtitleVisible = true;
  bool _controlsVisible = false;
  int _index = 0;

  VideoModel(this.link, this.videoRepository) {
    final vid = link.split("/").last;
    videoRepository.setIndexFromId(vid, notify: false);
    final video = videoRepository.getVideos()[videoRepository.index];
    youtubeController = YoutubePlayerController(
        initialVideoId: vid,
        flags: YoutubePlayerFlags(
            enableCaption: false, startAt: max(0, video.start - 2)));
    youtubeController.addListener(() {
      _controlsVisible = youtubeController.value.isControlsVisible;
      notifyListeners();
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Offset get subtitleOffset => _subtitleOffset;
  bool get subtitleVisible => _subtitleVisible;
  bool get videoExpanded => _videoExpanded;
  bool get expandedSubtitleVisible => _expandedSubtitleVisible;
  bool get controlsVisible => _controlsVisible;

  Future<void> closeSubtitles() async {
    _subtitleOffset = const Offset(0, 1);
    _videoExpanded = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 250));
    _subtitleVisible = false;
    notifyListeners();
  }

  Future<void> openSubtitles() async {
    _subtitleOffset = const Offset(0, 0);
    _subtitleVisible = true;
    _videoExpanded = false;
    notifyListeners();
  }

  void setExpandedSubtitleVisilbe(bool val) {
    _expandedSubtitleVisible = val;
    notifyListeners();
  }

  void nextVideo() {
    if (videoRepository.index == videoRepository.getVideos().length - 1) return;
    final video = videoRepository.getVideos()[videoRepository.index];
    videoRepository.setIndex(videoRepository.index + 1);
    youtubeController.load(video.id, startAt: max(0, video.start - 5));
    notifyListeners();
  }

  void previousVideo() {
    if (videoRepository.index == 0) return;
    final video = videoRepository.getVideos()[videoRepository.index];
    videoRepository.setIndex(videoRepository.index - 1);
    youtubeController.load(video.id, startAt: max(0, video.start - 5));
    notifyListeners();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    youtubeController.dispose();
    super.dispose();
  }
}
