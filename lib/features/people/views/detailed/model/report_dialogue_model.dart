import 'package:flutter/material.dart';

class ReportDialogueModel extends ChangeNotifier {
  final int id;
  final String name;
  bool isChecked = false;

  ReportDialogueModel({required this.id, required this.name});

  void updateChecked() {
    isChecked = !isChecked;
    debugPrint('isFavorite: $isChecked');

    /// [ notifyListeners ] is used to notify the [ listeners ] of the [ changes ]
    notifyListeners();
  }
}
