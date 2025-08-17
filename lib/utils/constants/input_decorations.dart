import 'package:flutter/material.dart';

import '../theme/colors.dart';

const kInputDecoration = InputDecoration(
  fillColor: AppColors.lighterGrey,
  filled: true,
  border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(50))),
  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  hintStyle: TextStyle(
      color: AppColors.grey, fontSize: 16, fontWeight: FontWeight.normal),
  errorStyle: TextStyle(color: AppColors.alertRed),
);
