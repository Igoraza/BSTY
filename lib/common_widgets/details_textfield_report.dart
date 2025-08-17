import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:bsty/features/people/services/people_provider.dart';
import 'package:bsty/utils/functions.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

class DetailedTextFieldReportDialog extends StatefulWidget {
  const DetailedTextFieldReportDialog({
    Key? key,
    // required this.options,
    this.onSubmit,
    this.borderRadius,
    // required this.isint,
    this.userId,
    required this.title,
  }) : super(key: key);
  final String title;
  // final List<String> options;
  final VoidCallback? onSubmit;
  final BorderRadiusGeometry? borderRadius;
  // final bool isint;
  final int? userId;

  @override
  State<DetailedTextFieldReportDialog> createState() =>
      _DetailedTextFieldReportDialogState();
}

class _DetailedTextFieldReportDialogState
    extends State<DetailedTextFieldReportDialog> {
  final List<String> _selectedOptions = [];
  int selectedInt = 0;
  final TextEditingController reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    // final reportIsChecked = Provider.of<ReportDialogueModel>(context);
    final proProvider = context.read<InitialProfileProvider>();

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
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontSize: 18),
            textAlign: TextAlign.start,
          ),
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
                controller: reportController,
                // readOnly: true,
                // enabled: false,
                onChanged: (val) {
                  proProvider.detailsReport = val;
                },
                maxLines: 8,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 12,
                ),
                decoration: const InputDecoration(
                  hintText: "Provide details about what you are reportinge",
                  hintStyle: TextStyle(
                    color: AppColors.disabled,
                    fontSize: 12,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white, width: 0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
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
                'Submit',
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
