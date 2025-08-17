import 'package:flutter/material.dart';

import '../model/report_dialogue_model.dart';

class ReportDialogueProvider extends ChangeNotifier {
  static final List<ReportDialogueModel> reportReasonsList = [
    ReportDialogueModel(
      name: 'Sexual Content',
      id: 1,
    ),
    ReportDialogueModel(
      name: 'Abusive Content',
      id: 2,
    ),
    ReportDialogueModel(
      name: 'Violent Content',
      id: 3,
    ),
    ReportDialogueModel(
      name: 'Inappropriate Content',
      id: 4,
    ),
    ReportDialogueModel(
      name: 'Spam or Misleading',
      id: 5,
    ),
  ];

  List<ReportDialogueModel> get reportReasons => [...reportReasonsList];
}
