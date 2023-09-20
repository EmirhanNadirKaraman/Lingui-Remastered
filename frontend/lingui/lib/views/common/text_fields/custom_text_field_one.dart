import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final String hintText;
  final bool readOnly;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  const CustomTextField(
      {super.key,
      required this.controller,
      this.suffixIcon,
      this.onChanged,
      this.readOnly = false,
      this.obscure = false,
      this.hintText = ""});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      style: LinguiTextStyles.kbarlowSemiCondensed19MediumBlack
          .copyWith(color: AppColors.darkGrey),
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.white,
          hintText: hintText,
          hintStyle: LinguiTextStyles.kbarlowSemiCondensed19MediumBlack
              .copyWith(color: AppColors.darkGrey.withOpacity(.6)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.darkGrey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.darkGrey)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.darkGrey))),
    );
  }
}
