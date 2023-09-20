import 'package:flutter/material.dart';
import 'package:lingui/model/subtitle.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/res/extensions/string_extensions.dart';

class VideoExpandedSubtitle extends StatelessWidget {
  final List<Subtitle> subtitle;
  final bool visible;
  final Function(WordToToken word) onWordTap;
  final int currentLocation;
  const VideoExpandedSubtitle(
      {super.key,
      required this.currentLocation,
      required this.subtitle,
      required this.visible,
      required this.onWordTap});

  @override
  Widget build(BuildContext context) {
    final tokensUpper = subtitle
        .where((e) => e.start <= currentLocation && e.end >= currentLocation)
        .toList()
        .map(
          (e) => e.tokens,
        )
        .toList();
    final tokens = <WordToToken>[];
    for (final l in tokensUpper) {
      tokens.addAll(l);
    }
    return Visibility(
      visible: visible,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .8, minHeight: 0),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(.6),
            borderRadius: BorderRadius.circular(8)),
        child: subtitle.isEmpty
            ? const SizedBox()
            : tokens.toClickableSubtitle(onWordTap, context,
                textAlign: TextAlign.center,
                textColor: Colors.white.withOpacity(.9),
                fontSize: 25),
      ),
    );
  }
}
