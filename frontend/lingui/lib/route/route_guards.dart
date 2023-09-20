import 'package:auto_route/auto_route.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class LoginGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (AppConfig.auth.currentUser != null && SPUtil.instance.loggedIn) {
      if (SPUtil.instance.currentLanguage.isNotEmpty) {
        router.navigateNamed("/b");
      } else {
        router.navigateNamed("/initial-language");
      }
    } else {
      resolver.next(true);
    }
  }
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (AppConfig.auth.currentUser == null || !SPUtil.instance.loggedIn) {
      router.navigateNamed("/login");
    } else {
      resolver.next(true);
    }
  }
}

class InitialLanguageGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (AppConfig.auth.currentUser == null || !SPUtil.instance.loggedIn) {
      router.navigateNamed("/login");
    } else {
      if (SPUtil.instance.currentLanguage.isNotEmpty) {
        router.navigateNamed("/b");
      } else {
        resolver.next(true);
      }
    }
  }
}
