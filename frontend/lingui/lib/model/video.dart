class Video {
  String id;
  String title;
  Duration duration;
  String thumbnail;
  String category;
  String baseWord;
  int start;

  Video(
      {required this.category,
      required this.id,
      required this.duration,
      required this.thumbnail,
      required this.title,
      required this.start,
      required this.baseWord});

  // tostring method
  @override
  String toString() {
    return "Video: $id, $title, $duration, $thumbnail, $category, $start, $baseWord";
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        start: json['sentence']['start_time'].toDouble().toInt(),
        baseWord: json['word']['word'],
        id: json['video']['video_id'],
        duration:
            Duration(seconds: json['video']['duration'].toDouble().toInt()),
        thumbnail: json['video']['thumbnail_url'],
        title: json['video']['title'],
        category: json['video']['category']);
  }
}
