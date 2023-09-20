// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:auto_route/empty_router_widgets.dart' as _i8;
import 'package:flutter/material.dart' as _i15;

import '../res/route_transitions/transitions.dart' as _i17;
import '../views/change_language/change_language_view.dart' as _i2;
import '../views/dictionary/dictionary_view.dart' as _i11;
import '../views/home/home_view.dart' as _i1;
import '../views/initial_language/initial_language_view.dart' as _i4;
import '../views/login/login_view.dart' as _i3;
import '../views/profile/profile_view.dart' as _i10;
import '../views/progress/progress_view.dart' as _i9;
import '../views/srs/srs_view.dart' as _i7;
import '../views/transcript/transcript_view.dart' as _i6;
import '../views/video/video_view.dart' as _i5;
import '../views/videos/videos_view.dart' as _i13;
import '../views/word_details/word_details_view.dart' as _i12;
import 'route_guards.dart' as _i16;

class AppRouter extends _i14.RootStackRouter {
  AppRouter({
    _i15.GlobalKey<_i15.NavigatorState>? navigatorKey,
    required this.authGuard,
    required this.loginGuard,
    required this.initialLanguageGuard,
  }) : super(navigatorKey);

  final _i16.AuthGuard authGuard;

  final _i16.LoginGuard loginGuard;

  final _i16.InitialLanguageGuard initialLanguageGuard;

  @override
  final Map<String, _i14.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.HomeView(),
      );
    },
    ChangeLanguageRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.ChangeLanguageView(),
      );
    },
    LoginRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.LoginView(),
      );
    },
    InitialLanguageRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.InitialLanguageView(),
      );
    },
    VideoRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<VideoRouteArgs>(
          orElse: () => VideoRouteArgs(vid: pathParams.getString('vid')));
      return _i14.CustomPage<dynamic>(
        routeData: routeData,
        child: _i5.VideoView(
          key: args.key,
          vid: args.vid,
        ),
        customRouteBuilder: _i17.RouteTransitions.fadeTranistion,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TranscriptRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TranscriptRouteArgs>(
          orElse: () => TranscriptRouteArgs(vid: pathParams.getString('vid')));
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i6.TranscriptView(
          key: args.key,
          vid: args.vid,
        ),
      );
    },
    SrsRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.SrsView(),
      );
    },
    BaseDictionaryRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i8.EmptyRouterPage(),
      );
    },
    BaseVideosRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i8.EmptyRouterPage(),
      );
    },
    ProgressRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.ProgressView(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i10.ProfileView(),
      );
    },
    DictionaryRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i11.DictionaryView(),
      );
    },
    WordDetailsRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<WordDetailsRouteArgs>(
          orElse: () => WordDetailsRouteArgs(
                word: pathParams.getString('word'),
                id: queryParams.getInt(
                  'id',
                  0,
                ),
              ));
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i12.WordDetailsView(
          key: args.key,
          word: args.word,
          id: args.id,
        ),
      );
    },
    VideosRoute.name: (routeData) {
      return _i14.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i13.VideosView(),
      );
    },
  };

  @override
  List<_i14.RouteConfig> get routes => [
        _i14.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/login',
          fullMatch: true,
        ),
        _i14.RouteConfig(
          HomeRoute.name,
          path: '/b',
          guards: [authGuard],
          children: [
            _i14.RouteConfig(
              '#redirect',
              path: '',
              parent: HomeRoute.name,
              redirectTo: 'videos',
              fullMatch: true,
            ),
            _i14.RouteConfig(
              SrsRoute.name,
              path: 'srs',
              parent: HomeRoute.name,
            ),
            _i14.RouteConfig(
              BaseDictionaryRoute.name,
              path: 'dictionary',
              parent: HomeRoute.name,
              children: [
                _i14.RouteConfig(
                  DictionaryRoute.name,
                  path: '',
                  parent: BaseDictionaryRoute.name,
                ),
                _i14.RouteConfig(
                  WordDetailsRoute.name,
                  path: ':word',
                  parent: BaseDictionaryRoute.name,
                ),
              ],
            ),
            _i14.RouteConfig(
              BaseVideosRoute.name,
              path: 'videos',
              parent: HomeRoute.name,
              children: [
                _i14.RouteConfig(
                  VideosRoute.name,
                  path: '',
                  parent: BaseVideosRoute.name,
                )
              ],
            ),
            _i14.RouteConfig(
              ProgressRoute.name,
              path: 'progress',
              parent: HomeRoute.name,
            ),
            _i14.RouteConfig(
              ProfileRoute.name,
              path: 'profile',
              parent: HomeRoute.name,
            ),
          ],
        ),
        _i14.RouteConfig(
          ChangeLanguageRoute.name,
          path: '/change-language',
          guards: [authGuard],
        ),
        _i14.RouteConfig(
          LoginRoute.name,
          path: '/login',
          guards: [loginGuard],
        ),
        _i14.RouteConfig(
          InitialLanguageRoute.name,
          path: '/initial-language',
          guards: [initialLanguageGuard],
        ),
        _i14.RouteConfig(
          VideoRoute.name,
          path: '/watch/:vid',
          guards: [authGuard],
        ),
        _i14.RouteConfig(
          TranscriptRoute.name,
          path: '/transcript/:vid',
          guards: [authGuard],
        ),
      ];
}

/// generated route for
/// [_i1.HomeView]
class HomeRoute extends _i14.PageRouteInfo<void> {
  const HomeRoute({List<_i14.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          path: '/b',
          initialChildren: children,
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i2.ChangeLanguageView]
class ChangeLanguageRoute extends _i14.PageRouteInfo<void> {
  const ChangeLanguageRoute()
      : super(
          ChangeLanguageRoute.name,
          path: '/change-language',
        );

  static const String name = 'ChangeLanguageRoute';
}

/// generated route for
/// [_i3.LoginView]
class LoginRoute extends _i14.PageRouteInfo<void> {
  const LoginRoute()
      : super(
          LoginRoute.name,
          path: '/login',
        );

  static const String name = 'LoginRoute';
}

/// generated route for
/// [_i4.InitialLanguageView]
class InitialLanguageRoute extends _i14.PageRouteInfo<void> {
  const InitialLanguageRoute()
      : super(
          InitialLanguageRoute.name,
          path: '/initial-language',
        );

  static const String name = 'InitialLanguageRoute';
}

/// generated route for
/// [_i5.VideoView]
class VideoRoute extends _i14.PageRouteInfo<VideoRouteArgs> {
  VideoRoute({
    _i15.Key? key,
    required String vid,
  }) : super(
          VideoRoute.name,
          path: '/watch/:vid',
          args: VideoRouteArgs(
            key: key,
            vid: vid,
          ),
          rawPathParams: {'vid': vid},
        );

  static const String name = 'VideoRoute';
}

class VideoRouteArgs {
  const VideoRouteArgs({
    this.key,
    required this.vid,
  });

  final _i15.Key? key;

  final String vid;

  @override
  String toString() {
    return 'VideoRouteArgs{key: $key, vid: $vid}';
  }
}

/// generated route for
/// [_i6.TranscriptView]
class TranscriptRoute extends _i14.PageRouteInfo<TranscriptRouteArgs> {
  TranscriptRoute({
    _i15.Key? key,
    required String vid,
  }) : super(
          TranscriptRoute.name,
          path: '/transcript/:vid',
          args: TranscriptRouteArgs(
            key: key,
            vid: vid,
          ),
          rawPathParams: {'vid': vid},
        );

  static const String name = 'TranscriptRoute';
}

class TranscriptRouteArgs {
  const TranscriptRouteArgs({
    this.key,
    required this.vid,
  });

  final _i15.Key? key;

  final String vid;

  @override
  String toString() {
    return 'TranscriptRouteArgs{key: $key, vid: $vid}';
  }
}

/// generated route for
/// [_i7.SrsView]
class SrsRoute extends _i14.PageRouteInfo<void> {
  const SrsRoute()
      : super(
          SrsRoute.name,
          path: 'srs',
        );

  static const String name = 'SrsRoute';
}

/// generated route for
/// [_i8.EmptyRouterPage]
class BaseDictionaryRoute extends _i14.PageRouteInfo<void> {
  const BaseDictionaryRoute({List<_i14.PageRouteInfo>? children})
      : super(
          BaseDictionaryRoute.name,
          path: 'dictionary',
          initialChildren: children,
        );

  static const String name = 'BaseDictionaryRoute';
}

/// generated route for
/// [_i8.EmptyRouterPage]
class BaseVideosRoute extends _i14.PageRouteInfo<void> {
  const BaseVideosRoute({List<_i14.PageRouteInfo>? children})
      : super(
          BaseVideosRoute.name,
          path: 'videos',
          initialChildren: children,
        );

  static const String name = 'BaseVideosRoute';
}

/// generated route for
/// [_i9.ProgressView]
class ProgressRoute extends _i14.PageRouteInfo<void> {
  const ProgressRoute()
      : super(
          ProgressRoute.name,
          path: 'progress',
        );

  static const String name = 'ProgressRoute';
}

/// generated route for
/// [_i10.ProfileView]
class ProfileRoute extends _i14.PageRouteInfo<void> {
  const ProfileRoute()
      : super(
          ProfileRoute.name,
          path: 'profile',
        );

  static const String name = 'ProfileRoute';
}

/// generated route for
/// [_i11.DictionaryView]
class DictionaryRoute extends _i14.PageRouteInfo<void> {
  const DictionaryRoute()
      : super(
          DictionaryRoute.name,
          path: '',
        );

  static const String name = 'DictionaryRoute';
}

/// generated route for
/// [_i12.WordDetailsView]
class WordDetailsRoute extends _i14.PageRouteInfo<WordDetailsRouteArgs> {
  WordDetailsRoute({
    _i15.Key? key,
    required String word,
    int id = 0,
  }) : super(
          WordDetailsRoute.name,
          path: ':word',
          args: WordDetailsRouteArgs(
            key: key,
            word: word,
            id: id,
          ),
          rawPathParams: {'word': word},
          rawQueryParams: {'id': id},
        );

  static const String name = 'WordDetailsRoute';
}

class WordDetailsRouteArgs {
  const WordDetailsRouteArgs({
    this.key,
    required this.word,
    this.id = 0,
  });

  final _i15.Key? key;

  final String word;

  final int id;

  @override
  String toString() {
    return 'WordDetailsRouteArgs{key: $key, word: $word, id: $id}';
  }
}

/// generated route for
/// [_i13.VideosView]
class VideosRoute extends _i14.PageRouteInfo<void> {
  const VideosRoute()
      : super(
          VideosRoute.name,
          path: '',
        );

  static const String name = 'VideosRoute';
}
