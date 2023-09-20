import 'package:flutter/material.dart';
import 'package:lingui/repositories/profile_repository.dart';
import 'package:lingui/util/app_config.dart';
import 'package:lingui/util/sp_util.dart';

class ProfileModel extends ChangeNotifier {
  final ProfileRepository profileRepository;
  bool _loading = false;
  bool _changingLanguage = false;

  bool get changingLanguage => _changingLanguage;
  bool get loading => _loading;

  ProfileModel(this.profileRepository) {
    fetch();
  }

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void setChangingLanguage(bool val) {
    _changingLanguage = val;
    notifyListeners();
  }

  Future<void> refresh(BuildContext context, String language) async {
    setChangingLanguage(true);
    await AppConfig.refresh(context, language);
    setChangingLanguage(false);
  }

  Future<void> fetch() async {
    setLoading(true);
    await profileRepository
        .fetchKnownWordCount(SPUtil.instance.currentLanguage);
    await profileRepository.fetchLeaderboard(SPUtil.instance.currentLanguage);
    await profileRepository.fetchUserLanguages();
    setLoading(false);
  }
}
