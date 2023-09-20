import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingui/views/dictionary/dictionary_model.dart';

class DictionaryController {
  final DictionaryModel _model;

  const DictionaryController(this._model);

  Future<void> onWordTap(BuildContext context, int id, String word) async {
    await AutoRouter.of(context).pushNamed("${word.toString()}?id=$id");
  }
}
