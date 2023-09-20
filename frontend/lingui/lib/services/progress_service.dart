import 'dart:convert';

import 'package:lingui/model/progress.dart';
import 'package:lingui/util/app_config.dart';

class ProgressService {
  static Future<List<Progress>> listUserWords(
      String languageCode, int page) async {
    try {
      final params = {
        "language": languageCode,
        "rows_per_page": AppConfig.progressPagination,
        "page": page,
      };
      final callable = AppConfig.functions.httpsCallable("listUserWords");
      final res = await callable.call(params);
      final data = json.decode(res.data);
      if (!data['success']) {
        return [];
      }
      return (data['data'] as List).map((e) => Progress.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
