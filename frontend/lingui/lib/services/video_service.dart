import 'dart:convert';

import 'package:lingui/model/subtitle.dart';
import 'package:lingui/model/video.dart';
import 'package:lingui/util/app_config.dart';

class VideoService {
  static Future<List<Subtitle>> getSubtitle(String videoId) async {
    try {
      final params = {"video_id": videoId};
      final callable = AppConfig.functions.httpsCallable("getVideoTranscript");
      final res = await callable.call(params);
      final data = json.decode(res.data);
      if (!data['success']) {
        return [];
      }
      return (data['data'] as List).map((e) => Subtitle.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<Video>> getVideos(String language, int page) async {
    try {
      final params = {
        "max_unknown_count": 1,
        "language": language,
        "page": page,
        "rows_per_page": AppConfig.pagination,
        "full_sentence": true
      };
      final callable = AppConfig.functions.httpsCallable("getUnknownSentences");
      final res = await callable.call(params);
      final data = json.decode(res.data);

      if (!data['success']) {
        return [];
      }
      final videos = <Video>[];
      for (final v in data['data']) {
        final video = Video.fromJson(v['properties']);
        videos.add(video);
      }
      return videos;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
