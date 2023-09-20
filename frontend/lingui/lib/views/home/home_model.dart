import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lingui/services/profile_service.dart';
import 'package:lingui/util/sp_util.dart';

class HomeModel extends ChangeNotifier {
  Timer? periodic;

  HomeModel() {
    periodic = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await ProfileService.updateUserTime(SPUtil.instance.currentLanguage);
    });
  }

  @override
  void dispose() {
    periodic?.cancel();
    super.dispose();
  }
}
