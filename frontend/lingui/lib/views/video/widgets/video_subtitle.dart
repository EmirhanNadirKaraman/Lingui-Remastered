import 'package:flutter/material.dart';
import 'package:lingui/model/subtitle.dart';
import 'package:lingui/model/word_to_token.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/extensions/string_extensions.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';

class VideoSubtitle extends StatelessWidget {
  final List<Subtitle> subtitle;
  final bool visible;
  final Offset offset;
  final Function() onCloseTap;
  final Function(WordToToken data) onWordTap;
  final Function() onPreviousTap;
  final Function() onNextTap;
  final Size size;
  final int currentLocation;

  const VideoSubtitle(
      {Key? key,
      required this.currentLocation,
      required this.onNextTap,
      required this.onPreviousTap,
      required this.subtitle,
      required this.visible,
      required this.offset,
      required this.onCloseTap,
      required this.size,
      required this.onWordTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = Localized.of(context);
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
      child: AnimatedSlide(
        offset: offset,
        duration: const Duration(milliseconds: 250),
        child: Container(
            width: size.width * .35,
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language.subtitle,
                          style:
                              LinguiTextStyles.kbarlowSemiCondensed27BoldWhite,
                        ),
                        GestureDetector(
                          onTap: () {
                            onCloseTap();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 28,
                            color: AppColors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    thickness: .5,
                  ),
                  const VSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: tokens.toClickableSubtitle(onWordTap, context,
                        fontSize: 25),
                  ),
                  const Spacer(),
                  const Divider(
                    color: Colors.white,
                    thickness: .5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: onPreviousTap,
                          child: Text(
                            language.previousVideo,
                            style: LinguiTextStyles
                                .kbarlowSemiCondensed21BoldWhite,
                          ),
                        ),
                        GestureDetector(
                          onTap: onNextTap,
                          child: Text(
                            language.nextVideo,
                            style: LinguiTextStyles
                                .kbarlowSemiCondensed21BoldWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 8,
                  )
                ],
              ),
            )),
      ),
    );
  }
}
