import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lingui/repositories/dictionary_repository.dart';
import 'package:lingui/repositories/profile_repository.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/repositories/srs_repository.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/route/route_guards.dart';
import 'package:lingui/route/router.gr.dart';
import 'package:lingui/util/app_config.dart';
import 'package:provider/provider.dart';

void main() async {
  await AppConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter(
      loginGuard: LoginGuard(),
      authGuard: AuthGuard(),
      initialLanguageGuard: InitialLanguageGuard());

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DictionaryRepository()),
        ChangeNotifierProvider(create: (context) => ProgressRepository()),
        ChangeNotifierProvider(create: (context) => VideoRepository()),
        ChangeNotifierProvider(create: (context) => SrsRepository()),
        ChangeNotifierProvider(create: (context) => ProfileRepository()),
        ChangeNotifierProvider(create: (context) => RefreshRepo())
      ],
      child: MaterialApp.router(
        theme: ThemeData.dark().copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
          // replace default CupertinoPageTransitionsBuilder with this
          TargetPlatform.iOS: NoShadowCupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        })),
        locale: Locale(Platform.localeName.substring(0, 2)),
        supportedLocales: Localized.delegate.supportedLocales,
        localizationsDelegates: const [
          Localized.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routeInformationParser: _appRouter.defaultRouteParser(),
        routeInformationProvider: _appRouter.routeInfoProvider(),
        routerDelegate: _appRouter.delegate(),
      ),
    );
  }
}
