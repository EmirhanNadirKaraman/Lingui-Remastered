import 'package:flutter/material.dart';
import 'package:lingui/model/subtitle.dart';
import 'package:lingui/model/video.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/repositories/video_repository.dart';

class TranscriptModel extends ChangeNotifier {
  final VideoRepository videoRepository;
  final tokens = <WordToToken>[];
  final String vid;
  Video? video;
  List<Subtitle>? transcript;
  bool _loading = false;

  bool get loading => _loading;

  TranscriptModel(this.videoRepository, this.vid) {
    init();
  }

  Future<void> init() async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 0));
    videoRepository.setIndexFromId(vid);
    video = videoRepository.getCurrentVideo();
    transcript = videoRepository.getCurrentTranscript(video!.id);
    final tokensUpper = transcript
        ?.map(
          (e) => e.tokens,
        )
        .toList();
    if (tokensUpper != null) {
      for (final l in tokensUpper) {
        tokens.addAll(l);
        tokens.add(const WordToToken(" ", " ", -1));
      }
    }
    notifyListeners();
    setLoading(false);
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
