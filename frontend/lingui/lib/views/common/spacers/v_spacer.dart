import 'package:flutter/material.dart';

class VSpacer extends StatelessWidget {
  final double ratio;
  const VSpacer({super.key, this.ratio = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10 * ratio,
    );
  }
}
