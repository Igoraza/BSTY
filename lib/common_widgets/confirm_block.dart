import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:bsty/features/people/services/people_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/functions.dart';
import '../../../../../utils/theme/colors.dart';

class ConfirmDialog extends StatelessWidget {
  ConfirmDialog({
    Key? key,
    // required this.options,
    this.onSubmint,
    this.borderRadius,
    // required this.isint,
    this.userId,
  }) : super(key: key);

  // final List<String> options;
  final VoidCallback? onSubmint;
  final BorderRadiusGeometry? borderRadius;
  // final bool isint;
  final int? userId;

  final List<String> _selectedOptions = [];
  int selectedInt = 0;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    // final reportIsChecked = Provider.of<ReportDialogueModel>(context);
    final peopleProvider = context.read<PeopleProvider>();

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(28)),
      // contentPadding: EdgeInsets.all(appWidth * 0.06),
      insetPadding: EdgeInsets.all(appWidth * 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              'Are you sure ?',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: AppColors.black,
                  ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('You won\'t be able to see or contact\nthis person anymore.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 17)),
            SizedBox(
              height: 10,
            ),
            Text(' Do you want to block ?',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20,
            ),
            const Divider(height: 20, color: AppColors.lightGrey),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonBlue,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                  child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: appWidth * 0.12,
                            vertical: appWidth * 0.06,
                          )),
                      child: const Text('Cancel'))),
              const SizedBox(width: 10),
              DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: AppColors.orangeRedH,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                  child: TextButton(
                      onPressed: onSubmint ??
                          () {
                            String content = '';
                            for (var element in _selectedOptions) {
                              content = '$content $element';
                            }
                            if (content.isEmpty) {
                              showSnackBar('Select anything to continue !');
                              return;
                            }
                            log(content);
                            Navigator.pop(context);
                            // showDialog(
                            //   context: context,
                            //   builder: (context) => ReportDialog(
                            //     options: PersonDetailedPage.reportOptions,
                            //     userId: userId,
                            //     isint: true,
                            //     onSubmint: () {
                            //       log('$content ${peopleProvider.selectedId}');
                            //       if (peopleProvider.selectedId == null) {
                            //         showSnackBar('Select anything to continue !');
                            //         return;
                            //       }
                            //        log('content {peopleProvider.selectedId}');
                            //       profileProvider.reportAndBlock(userId!,
                            //           content, peopleProvider.selectedId!);
                            //       navigatorKey.currentState!.pop();
                            //     },
                            //   ),
                            // );
                          },
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: appWidth * 0.12,
                              vertical: appWidth * 0.06)),
                      child: const Text('Submit')))
            ]),
            const Divider(height: 20, color: AppColors.lightGrey),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
