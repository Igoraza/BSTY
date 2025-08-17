import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/common_widgets/details_textfield_report.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:bsty/features/people/services/people_provider.dart';
import 'package:bsty/utils/functions.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

class DetailedReportDialog extends StatefulWidget {
  const DetailedReportDialog({
    Key? key,
    required this.options,
    this.onSubmit,
    this.borderRadius,
    required this.isint,
    this.userId,
    required this.title,
    required this.reportController,
  }) : super(key: key);
  final String title;
  final List<String> options;
  final VoidCallback? onSubmit;
  final BorderRadiusGeometry? borderRadius;
  final bool isint;
  final int? userId;
  final TextEditingController reportController;

  @override
  State<DetailedReportDialog> createState() => _DetailedReportDialogState();
}

class _DetailedReportDialogState extends State<DetailedReportDialog> {
  final List<String> _selectedOptions = [];
  int selectedInt = 0;

  List<String> reportKind = [
    "Bio",
    "Profile Photo",
    "Messages",
    "Personal",
  ];

  List<String> reasonKind = [
    "Fake Profile",
    "Scam",
    "Nudity",
    "Selling Something",
    'Sexual Content',
    'Abusive Content',
    'Violent Content',
    'Inappropriate Content',
    'Spam or Misleading',
  ];

  List<String> incidents = [
    "Nudity",
    "Sextortion",
    "Sexually Explicit",
    "Illegal",
  ];

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    // final reportIsChecked = Provider.of<ReportDialogueModel>(context);
    final initiProvider = context.read<InitialProfileProvider>();
    List<String> listOptions =
        widget.options.isNotEmpty ? widget.options : reportKind;
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(28),
      ),
      // contentPadding: EdgeInsets.all(appWidth * 0.06),
      insetPadding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 30,
          ),
          Text(widget.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontSize: 18)),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Material(
              elevation: 10.0,
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              // shadowColor: Colors.blue,
              child: TextField(
                controller: widget.reportController,
                readOnly: true,
                enabled: false,
                style: const TextStyle(color: AppColors.black),
                decoration: const InputDecoration(
                  hintText: "Select One",
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  //   borderSide: BorderSide(
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  //   borderSide: BorderSide(color: Colors.white, width: 0),
                  // ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 280,
            child: Card(
              elevation: 8,
              color: AppColors.white,
              // margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10,
                  left: 16,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        listOptions.length,
                        (index) => InkWell(
                              onTap: () {
                                widget.reportController.clear();
                                widget.reportController.text =
                                    listOptions[index];
                                log("ontap ${widget.reportController.text}");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  listOptions[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                  // textScaleFactor: 3,
                                  // textAlign: TextAlign.start,
                                ),
                              ),
                            ))),
              ),
            ),
          ),
          // const Divider(height: 20, color: AppColors.lightGrey),
          // ...widget.options.map(
          //   (e) => Row(
          //     children: [
          //       Checkbox(
          //         value: _selectedOptions.contains(e),
          //         onChanged: (value) {
          //           setState(() {
          //             if (widget.isint) {
          //               _selectedOptions.clear();
          //               log(e.toString());
          //               if (e == 'Report only') {
          //                 peopleProvider.selectedId = 1;
          //               } else if (e == 'Block only') {
          //                 peopleProvider.selectedId = 2;
          //               } else if (e == 'Report & Block') {
          //                 peopleProvider.selectedId = 3;
          //               }
          //               log('sele $selectedInt');
          //             }
          //             if (value!) {
          //               _selectedOptions.add(e);
          //             } else {
          //               _selectedOptions.remove(e);
          //             }
          //           });
          //         },
          //       ),
          //       Text(e)
          //     ],
          //   ),
          // ),
          const Divider(height: 20, color: AppColors.lightGrey),
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.orangeRedH,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: TextButton(
              onPressed: widget.onSubmit ?? () {},
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 150,
                  vertical: appWidth * 0.068,
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.lightGrey),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
