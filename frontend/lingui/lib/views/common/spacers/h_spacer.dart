import 'package:flutter/material.dart';

class HSpacer extends StatelessWidget {
  final double ratio;
  const HSpacer({super.key, this.ratio = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10 * ratio,
    );
  }
}
