import 'package:flutter/material.dart';
import 'package:lingui/model/leaderboard_item.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/spacers/h_spacer.dart';

class Leaderboard extends StatelessWidget {
  final List<LeaderBoardItem> data;
  const Leaderboard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${index + 1}.",
                  style: LinguiTextStyles.kbarlowSemiCondensed15MediumWhite,
                ),
              ),
              const HSpacer(
                ratio: 1.5,
              ),
              CircleAvatar(
                foregroundImage: NetworkImage(data[index].user.profilePhoto),
              ),
              const HSpacer(),
              Expanded(
                flex: 9,
                child: Text(
                  data[index].user.username,
                  style: LinguiTextStyles.kbarlowSemiCondensed15MediumWhite,
                ),
              ),
              const HSpacer(),
              Text(
                data[index].score.toString(),
                style: LinguiTextStyles.kbarlowSemiCondensed15BoldWhite,
              ),
            ],
          ),
        );
      },
    );
  }
}
