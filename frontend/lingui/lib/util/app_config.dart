// ignore_for_file: use_build_context_synchronously

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lingui/firebase_options.dart';
import 'package:lingui/repositories/profile_repository.dart';
import 'package:lingui/repositories/progress_repository.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/repositories/srs_repository.dart';
import 'package:lingui/repositories/video_repository.dart';
import 'package:lingui/util/sp_util.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

class AppConfig {
  static late FirebaseFunctions functions;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static int pagination = 10;
  static int dictionaryPagination = 20;
  static int progressPagination = 100000;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    functions = FirebaseFunctions.instanceFor(region: "europe-west3", app: app);
    setPathUrlStrategy();
    await SPUtil.init();
  }

  static Future<void> refresh(BuildContext context, String language) async {
    try {
      await Provider.of<ProfileRepository>(context, listen: false)
          .fetchKnownWordCount(language, refresh: true, force: true);
      await Provider.of<ProfileRepository>(context, listen: false)
          .fetchLeaderboard(language, refresh: true, force: true);
      await Provider.of<ProfileRepository>(context, listen: false)
          .fetchUserLanguages();
      await Provider.of<ProgressRepository>(context, listen: false)
          .fetch(language, refresh: true, force: true);
      await Provider.of<SrsRepository>(context, listen: false)
          .fetch(language, refresh: true, force: true);
      Provider.of<SrsRepository>(context, listen: false).setIndex(0);
      await Provider.of<VideoRepository>(context, listen: false)
          .fetch(language, refresh: true, force: true);
      Provider.of<VideoRepository>(context, listen: false).setIndex(0);
      Provider.of<RefreshRepo>(context, listen: false).notify();
      await SPUtil.instance.setCurrentLanguage(language);
    } catch (e) {
      print("the error is caused by refresh");
      print(e);
    }
  }
}
