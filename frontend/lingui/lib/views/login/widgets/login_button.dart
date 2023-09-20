import 'package:flutter/material.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/spacers/h_spacer.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final double width;
  final Color backgroundColor;
  final Function() onTap;
  const LoginButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.width,
      required this.onTap,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: backgroundColor,
        ),
        width: width,
        child: Row(
          children: [
            const HSpacer(
              ratio: 7.5,
            ),
            SizedBox(
              height: 28,
              width: 28,
              child: Icon(
                icon,
              ),
            ),
            const HSpacer(
              ratio: 2,
            ),
            Expanded(
              child: Text(
                text,
                style: LinguiTextStyles.kbarlowSemiCondensed17MediumWhite,
              ),
            ),
            const HSpacer(),
          ],
        ),
      ),
    );
  }
}
