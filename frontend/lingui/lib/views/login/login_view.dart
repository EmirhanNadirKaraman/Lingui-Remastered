import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/enums/sign_in_type.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/common/loading_indicator.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';
import 'package:lingui/views/login/login_controller.dart';
import 'package:lingui/views/login/login_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lingui/views/login/widgets/login_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      createModel: (context) => LoginModel(),
      builder: (context, model, size, padding, language) {
        final controller = LoginController(model);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    SizedBox(
                      height: padding.top + 8,
                    ),
                    const VSpacer(),
                    Text(
                      "Lingui",
                      style: LinguiTextStyles.icon,
                    ),
                    const Spacer(
                      flex: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: LoginButton(
                        backgroundColor: AppColors.blue,
                        text: language.signInWithGoogle,
                        icon: FontAwesomeIcons.google,
                        width: double.infinity,
                        onTap: () {
                          controller.login(SignInType.google, context);
                        },
                      ),
                    ),
                    /*if (Platform.isIOS)
                      Column(
                        children: [
                          const VSpacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: LoginButton(
                              backgroundColor: AppColors.black,
                              text: "Apple ile giriş yap",
                              icon: FontAwesomeIcons.apple,
                              width: double.infinity,
                              onTap: () {
                                controller.login(SignInType.apple, context);
                              },
                            ),
                          ),
                        ],
                      ),*/
                    const VSpacer(
                      ratio: 2,
                    ),
                    SizedBox(
                      height: padding.bottom + 8,
                    )
                  ],
                ),
              ),
              if (model.loading)
                Container(
                  color: AppColors.black.withOpacity(.7),
                  child: const Center(
                    child: LoadingIndicator(),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
