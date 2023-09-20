import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/repositories/srs_repository.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/extensions/string_extensions.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/common/spacers/v_spacer.dart';
import 'package:lingui/views/srs/srs_model.dart';
import 'package:provider/provider.dart';

class SrsView extends StatefulWidget {
  const SrsView({super.key});

  @override
  State<SrsView> createState() => _SrsViewState();
}

class _SrsViewState extends State<SrsView> {
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    showAnswer = false; // Initialize the variable in initState
  }

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    final srsRepo = Provider.of<SrsRepository>(context, listen: false);

    return BaseView(
      createModel: (context) => SrsModel(srsRepo),
      builder: (context, model, size, padding, language) {
        final srsRepo = Provider.of<SrsRepository>(context);
        final questions = srsRepo.getQuestions();
        final index = srsRepo.index;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Text(
              "Spaced Repetition",
              style: LinguiTextStyles.kbarlowSemiCondensed25BoldWhite,
            ),
            centerTitle: false,
            actions: [
              if (!model.loading)
                IconButton(
                  onPressed: model.refresh,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: model.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : questions.isEmpty
                    ? Center(
                        child: Text(
                          language.noQuestions,
                          style:
                              LinguiTextStyles.kbarlowSemiCondensed21BoldWhite,
                        ),
                      )
                    : index == questions.length
                        ? Center(
                            child: Text(
                              language.noMoreQuestions,
                              style: LinguiTextStyles
                                  .kbarlowSemiCondensed21BoldWhite,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              questions[index].question.toSrsText(
                                  current: model.answerController.text.trim(),
                                  answer: questions[index].answer),
                              const VSpacer(
                                ratio: .5,
                              ),
                              Text(
                                questions[index].translated,
                                style: LinguiTextStyles
                                    .kbarlowSemiCondensed15MediumWhite,
                                textAlign: TextAlign.center,
                              ),
                              const VSpacer(),
                              TextFormField(
                                controller: model.answerController,
                                onChanged: (v) {
                                  model.notify();
                                },
                                maxLength: questions[index].answer.length,
                                style: LinguiTextStyles
                                    .kbarlowSemiCondensed17MediumWhite
                                    .copyWith(
                                        fontFeatures: ([
                                  // const FontFeature.disable('calt'),
                                  // const FontFeature.disable('liga'),
                                ])),
                                cursorColor: Colors.white,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: language.answer,
                                  hintStyle: LinguiTextStyles
                                      .kbarlowSemiCondensed17MediumWhite
                                      .copyWith(color: Colors.grey),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                              const VSpacer(),
                              GestureDetector(
                                onTap: () {
                                  if (model.answerController.text
                                          .replaceAll("’", "'") !=
                                      questions[index].answer) return;
                                  model.checkAnswer(
                                      questions[index].wordId, true);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.blue.withOpacity(model
                                                .answerController.text
                                                .replaceAll("’", "'") !=
                                            questions[index].answer
                                        ? .3
                                        : 1),
                                  ),
                                  child: Center(
                                    child: model.answering
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            language.next,
                                            style: LinguiTextStyles
                                                .kbarlowSemiCondensed21BoldWhite,
                                          ),
                                  ),
                                ),
                              ),
                              const VSpacer(),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    showAnswer = true;
                                  });

                                  await Future.delayed(
                                    const Duration(seconds: 5),
                                  );

                                  setState(() {
                                    showAnswer = false;
                                  });
                                  // Call the checkAnswer function after the delay.
                                  model.checkAnswer(
                                      questions[index].wordId, false);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.red.withOpacity(1),
                                  ),
                                  child: Center(
                                    child: model.answering
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            language.pass,
                                            style: LinguiTextStyles
                                                .kbarlowSemiCondensed21BoldWhite,
                                          ),
                                  ),
                                ),
                              ),
                              const VSpacer(),
                              Visibility(
                                visible: showAnswer,
                                child: Text(questions[index].answer,
                                    style: LinguiTextStyles
                                        .kbarlowSemiCondensed21BoldWhite),
                              ),
                            ],
                          ),
          ),
        );
      },
    );
  }
}
