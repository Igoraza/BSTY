import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';

class MEPQuestionAnswersBox extends StatelessWidget {
  const MEPQuestionAnswersBox({
    Key? key,
    required this.question,
    this.answer,
  }) : super(key: key);

  final String question;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Container(
      width: appWidth,
      margin: EdgeInsets.symmetric(horizontal: appWidth * 0.01),
      padding: EdgeInsets.all(appWidth * 0.05),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.disabled, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Column(children: [
        Text(question,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: appHeight * 0.02),
        Text(answer ?? '', style: Theme.of(context).textTheme.bodyLarge!),
      ]),
    );
  }
}
