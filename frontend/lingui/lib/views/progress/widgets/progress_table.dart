import 'package:flutter/material.dart';
import 'package:lingui/model/progress.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/res/language/localization.dart';
import 'package:lingui/res/text_styles.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressTable extends StatelessWidget {
  final List<Progress> progresses;
  final bool loading;
  final ScrollController controller;
  const ProgressTable(
      {super.key,
      required this.progresses,
      required this.loading,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    final language = Localized.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.white),
      child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              DataTable(
                dividerThickness: 1,
                columns: [
                  DataColumn(
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language.word,
                        style: LinguiTextStyles.kbarlowSemiCondensed19BoldBlack
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language.dueDate,
                        style: LinguiTextStyles.kbarlowSemiCondensed19BoldBlack
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language.level,
                        style: LinguiTextStyles.kbarlowSemiCondensed19BoldBlack
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  )
                ],
                rows: progresses
                    .map((progress) => DataRow(cells: [
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  progress.word,
                                  style: LinguiTextStyles
                                      .kbarlowSemiCondensed19MediumBlack
                                      .copyWith(color: AppColors.lightGrey),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  progress.percent == 1
                                      ? "✔"
                                      : "${progress.dueDuration.day}/${progress.dueDuration.month}/${progress.dueDuration.year}",
                                  style: LinguiTextStyles
                                      .kbarlowSemiCondensed19MediumBlack
                                      .copyWith(color: AppColors.lightGrey),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.center,
                              child: CircularPercentIndicator(
                                radius: MediaQuery.of(context).size.width * .03,
                                progressColor: progress.percent == 1
                                    ? Colors.green
                                    : AppColors.red,
                                backgroundColor: AppColors.lightGrey,
                                percent: progress.percent,
                              ),
                            ),
                          )
                        ]))
                    .toList(),
              ),
              if (loading)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .1,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
            ],
          )),
    );
  }
}
