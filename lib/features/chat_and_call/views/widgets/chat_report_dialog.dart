import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:bsty/features/chat_and_call/services/chat_provider.dart';
import 'package:provider/provider.dart';

import '../../../../utils/functions.dart';
import '../../../../utils/global_keys.dart';
import '../../../../utils/theme/colors.dart';
import '../chat_messages/widgets/chat_screen_alert_dialog.dart';

class ChatReportDialog extends StatefulWidget {
  const ChatReportDialog({
    Key? key,
    required this.options,
    this.onSubmint,
    this.borderRadius,
    this.userId,
  }) : super(key: key);

  final List<String> options;
  final VoidCallback? onSubmint;
  final BorderRadiusGeometry? borderRadius;
  final int? userId;

  @override
  State<ChatReportDialog> createState() => _ChatReportDialogState();
}

class _ChatReportDialogState extends State<ChatReportDialog> {
  final List<String> _selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    // final reportIsChecked = Provider.of<ReportDialogueModel>(context);
    final profileProvider = context.read<InitialProfileProvider>();
    final chatProvider = context.read<ChatProvider>();
    void showConfirmDialog({
      String? title,
      String? content,
      VoidCallback? onConfirm,
    }) =>
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => ChatScreenAlertDialog(
                  title: title,
                  content: content,
                  onConfirm: onConfirm,
                ));

    return SimpleDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(28)),
        contentPadding: EdgeInsets.all(appWidth * 0.08),
        // insetPadding: EdgeInsets.all(appWidth * 0.02),
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
          const SizedBox(height: 20),
          DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.buttonBlue,
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              child: TextButton(
                  onPressed: () {
                    String content = '';
                    for (var element in _selectedOptions) {
                      content = '$content $element';
                    }
                    log(content);
                    if (content.isEmpty) {
                      showSnackBar('Select anything to continue !');
                      return;
                    }
                    Navigator.pop(context);
                    showConfirmDialog(
                        content:
                            "You won't be able to contact this person anymore. Do you want to block ?",
                        onConfirm: () async {
                          // log(content);
                          await profileProvider.reportAndBlock(
                              widget.userId!, content, 0);
                          chatProvider.blockUser('chatId', 'msg');
                        });
                  },
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: appWidth * 0.05,
                        vertical: appWidth * 0.02,
                      )),
                  child: const Text('Continue'))),
          const SizedBox(height: 10),
          DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.orangeRedH,
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: appWidth * 0.05,
                          vertical: appWidth * 0.02)),
                  child: const Text('Cancel')))
        ]);
  }
}
