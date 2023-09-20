// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/enums/sign_in_type.dart';
import 'package:lingui/services/auth_service.dart';
import 'package:lingui/services/language_service.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';
import 'package:lingui/views/login/login_model.dart';

class LoginController {
  final LoginModel model;

  const LoginController(this.model);

  Future<void> login(SignInType type, BuildContext context) async {
    model.setLoading(true);
    final credentials = await AuthService.signIn(type);
    if (credentials == null) {
      model.setLoading(false);
      return;
    }
    await SPUtil.instance.setLoggedIn(true);

    final currentLanguage = await LanguageService.getCurrentLanguage();

    if (currentLanguage.isEmpty) {
      AutoRouter.of(context).replaceNamed("/initial-language");
    } else {
      await SPUtil.instance.setCurrentLanguage(currentLanguage);
      AutoRouter.of(context).replaceNamed("/b");
    }
  }
}
