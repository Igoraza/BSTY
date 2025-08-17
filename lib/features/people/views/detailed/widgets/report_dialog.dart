import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:bsty/features/people/views/detailed/person_details_page.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/functions.dart';
import '../../../../../utils/global_keys.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../services/people_provider.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    Key? key,
    required this.options,
    this.onSubmint,
    this.borderRadius,
    required this.isint,
    this.userId,
  }) : super(key: key);

  final List<String> options;
  final VoidCallback? onSubmint;
  final BorderRadiusGeometry? borderRadius;
  final bool isint;
  final int? userId;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final List<String> _selectedOptions = [];
  int selectedInt = 0;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    // final reportIsChecked = Provider.of<ReportDialogueModel>(context);
    final peopleProvider = context.read<PeopleProvider>();

    return SimpleDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(28)),
        contentPadding: EdgeInsets.all(appWidth * 0.06),
        // insetPadding: EdgeInsets.all(appWidth * 0.06),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/common/warning.png',
                width: 24, height: 24),
            const SizedBox(width: 12),
            Text('Report & Block',
                style: Theme.of(context).textTheme.bodyLarge),
          ]),
          const Divider(height: 20, color: AppColors.lightGrey),
          ...widget.options.map(
            (e) => Row(
              children: [
                Checkbox(
                  value: _selectedOptions.contains(e),
                  onChanged: (value) {
                    setState(() {
                      if (widget.isint) {
                        _selectedOptions.clear();
                        log(e.toString());
                        if (e == 'Report only') {
                          peopleProvider.selectedId = 1;
                        } else if (e == 'Block only') {
                          peopleProvider.selectedId = 2;
                        } else if (e == 'Report & Block') {
                          peopleProvider.selectedId = 3;
                        }
                        log('sele $selectedInt');
                      }
                      if (value!) {
                        _selectedOptions.add(e);
                      } else {
                        _selectedOptions.remove(e);
                      }
                    });
                  },
                ),
                Text(e)
              ],
            ),
          ),
          const Divider(height: 20, color: AppColors.lightGrey),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                          horizontal: appWidth * 0.05,
                          vertical: appWidth * 0.02,
                        )),
                    child: const Text('Cancel'))),
            const SizedBox(width: 10),
            DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.orangeRedH,
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                child: TextButton(
                    onPressed: widget.onSubmint ??
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
                          //     userId: widget.userId,
                          //     isint: true,
                          //     onSubmint: () {
                          //       log('$content ${peopleProvider.selectedId}');
                          //       if (peopleProvider.selectedId == null) {
                          //         showSnackBar('Select anything to continue !');
                          //         return;
                          //       }
                          //        log('content {peopleProvider.selectedId}');
                          //       profileProvider.reportAndBlock(widget.userId!,
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
                            horizontal: appWidth * 0.05,
                            vertical: appWidth * 0.02)),
                    child: const Text('Submit')))
          ]),
          const Divider(height: 20, color: AppColors.lightGrey),
        ]);
  }
}
