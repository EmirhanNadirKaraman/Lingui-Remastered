import 'package:auto_route/auto_route.dart';
import 'package:auto_route/empty_router_widgets.dart';
import 'package:lingui/res/route_transitions/transitions.dart';
import 'package:lingui/route/route_guards.dart';
import 'package:lingui/views/change_language/change_language_view.dart';
import 'package:lingui/views/dictionary/dictionary_view.dart';
import 'package:lingui/views/home/home_view.dart';
import 'package:lingui/views/initial_language/initial_language_view.dart';
import 'package:lingui/views/login/login_view.dart';
import 'package:lingui/views/profile/profile_view.dart';
import 'package:lingui/views/progress/progress_view.dart';
import 'package:lingui/views/srs/srs_view.dart';
import 'package:lingui/views/transcript/transcript_view.dart';
import 'package:lingui/views/video/video_view.dart';
import 'package:lingui/views/videos/videos_view.dart';
import 'package:lingui/views/word_details/word_details_view.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'View,Route',
  routes: [
    AutoRoute(
      path: "/b",
      page: HomeView,
      guards: [AuthGuard],
      children: [
        AutoRoute(path: "srs", page: SrsView),
        AutoRoute(
          path: "dictionary",
          name: "BaseDictionaryRoute",
          page: EmptyRouterPage,
          children: [
            AutoRoute(path: "", page: DictionaryView),
            AutoRoute(path: ":word", page: WordDetailsView),
          ],
        ),
        AutoRoute(
          path: "videos",
          name: "BaseVideosRoute",
          page: EmptyRouterPage,
          initial: true,
          children: [
            AutoRoute(path: "", page: VideosView),
          ],
        ),
        AutoRoute(path: "progress", page: ProgressView),
        AutoRoute(path: "profile", page: ProfileView),
      ],
    ),
    AutoRoute(
        path: "/change-language",
        page: ChangeLanguageView,
        guards: [AuthGuard]),
    AutoRoute(
        path: "/login", page: LoginView, initial: true, guards: [LoginGuard]),
    AutoRoute(
        path: "/initial-language",
        page: InitialLanguageView,
        guards: [InitialLanguageGuard]),
    CustomRoute(
        path: "/watch/:vid",
        page: VideoView,
        customRouteBuilder: RouteTransitions.fadeTranistion,
        guards: [AuthGuard]),
    AutoRoute(
        path: "/transcript/:vid", page: TranscriptView, guards: [AuthGuard])
  ],
)
class $AppRouter {}
