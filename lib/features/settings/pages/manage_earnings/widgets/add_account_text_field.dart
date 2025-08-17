import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';

class AddAccountTextField extends StatelessWidget {
  const AddAccountTextField({
    Key? key,
    required this.horizontal,
    required this.controller,
    required this.labelText,
    required this.keyboardType, this.validator,
  }) : super(key: key);

  final double horizontal;
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: AppColors.blue),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: AppColors.black),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.disabled, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.disabled, width: 1)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.disabled,
              width: 1,
            ),
          ),
        ),validator: validator,
      ),
    );
  }
}
