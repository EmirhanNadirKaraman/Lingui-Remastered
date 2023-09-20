import 'package:flutter/material.dart';
import 'package:lingui/model/subtitle.dart';
import 'package:lingui/model/video.dart';
import 'package:lingui/services/video_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class VideoRepository extends ChangeNotifier {
  final cache = <String, VideoRepoItem<List<Video>>>{};
  final subtitleCache = <String, VideoRepoItem<List<Subtitle>>>{};

  List<Video> getVideos() {
    return cache[SPUtil.instance.currentLanguage]?.data ?? [];
  }

  List<Subtitle> getSubtitle(String videoId) {
    return subtitleCache[videoId]?.data ?? [];
  }

  Video? getCurrentVideo() {
    return cache[SPUtil.instance.currentLanguage]?.data[index];
  }

  List<Subtitle>? getCurrentTranscript(String videoId) {
    // final v = getCurrentVideo();
    // if (v == null) return null;
    return subtitleCache[videoId]?.data;
  }

  int _index = 0;

  int get index => _index;

  void setIndex(int val) {
    _index = val;
    notifyListeners();
  }

  void setIndexFromId(String id, {bool notify = true}) {
    final i = getVideos().indexWhere((element) => element.id == id);
    if (i == -1) return;

    _index = i;
    if (notify) notifyListeners();
  }

  void clear() {
    cache.clear();
  }

  // TODO: refresh and force are converted from false to true. change them back.
  Future<bool> fetch(String language,
      {bool refresh = true, bool force = true}) async {
    final item = cache[language];
    if (!(refresh && force) &&
        !refresh &&
        item != null &&
        item.date.difference(DateTime.now()).inMinutes < 1) {
      return false;
    } else {
      if (item == null ||
          (refresh && force) ||
          (refresh && item.date.difference(DateTime.now()).inMinutes > 1)) {
        final res = await VideoService.getVideos(language, 1);
        cache[language] = VideoRepoItem(res);
        for (final v in res) {
          fetchSubtitle(v.id);
        }
        notifyListeners();
        return res.isNotEmpty && res.length % AppConfig.pagination == 0;
      }
    }
    final page = item.data.length ~/ AppConfig.pagination + 1;
    final res = await VideoService.getVideos(language, page);
    final data = item.data + res;
    cache[language] = VideoRepoItem(data);
    for (final v in data) {
      fetchSubtitle(v.id);
    }
    notifyListeners();
    return (res.isNotEmpty) && (res.length % AppConfig.pagination == 0);
  }

  Future<void> fetchSubtitle(String videoId) async {
    final res = await VideoService.getSubtitle(videoId);
    subtitleCache[videoId] = VideoRepoItem(res);
    notifyListeners();
  }
}

class VideoRepoItem<T> {
  final T data;
  final DateTime date = DateTime.now();

  VideoRepoItem(this.data);
}
