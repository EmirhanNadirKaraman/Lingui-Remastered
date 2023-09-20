import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation(AppColors.white),
      strokeWidth: 1,
    );
  }
}
