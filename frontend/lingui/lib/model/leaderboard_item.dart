import 'package:lingui/model/user.dart';

class LeaderBoardItem {
  final int score;
  final User user;

  const LeaderBoardItem({required this.score, required this.user});

  factory LeaderBoardItem.fromJson(Map<String, dynamic> json) {
    return LeaderBoardItem(
        score: json['score'], user: User.fromJson(json['user']));
  }
}
