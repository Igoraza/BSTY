import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';
import 'mep_question_answer_box.dart';

class HelpDisclaimer extends StatelessWidget {
  const HelpDisclaimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Container(
        padding: EdgeInsets.only(
            top: appHeight * 0.02,
            right: appWidth * 0.05,
            left: appWidth * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Help & Disclaimer',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal)),
          SizedBox(height: appHeight * 0.02),
          const MEPQuestionAnswersBox(
            question:
                'How does BSTY protect my privacy and keep my information secure?',
            answer:
                'We know security and privacy are important to you – and they are important to us, too. We make it a priority to provide strong security and give you confidence that your information is safe and accessible when you need it.',
          ),
          SizedBox(height: appHeight * 0.02),
          const MEPQuestionAnswersBox(
            question:
                'How can I remove information about myself from BSTY\'s search results?',
          ),
          SizedBox(height: appHeight * 0.05),
        ]));
  }
}
