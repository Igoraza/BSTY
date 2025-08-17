// import 'package:country_calling_code_picker/functions.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/input_decorations.dart';
import '../../../utils/theme/colors.dart';

typedef StringCallback = void Function(String val);

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField(
      {Key? key,
      required this.phoneNumController,
      required this.phoneCodeController})
      : super(key: key);

  final TextEditingController phoneNumController;
  final TextEditingController phoneCodeController;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: AppColors.lighterGrey,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(children: [
          GestureDetector(
              onTap: () async {
                // final country = await showCountryPickerSheet(
                //   context,
                //   title: null,
                //   cancelWidget: const SizedBox.shrink(),
                // );
                // if (country != null) {
                //   setState(() {
                //     widget.phoneCodeController.text = country.callingCode;
                //   });
                // }
              },
              child: Container(
                  // height: 64,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  decoration: const BoxDecoration(
                      color: AppColors.lighterGrey,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.phoneCodeController.text,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_sharp, size: 30),
                        const Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: VerticalDivider(width: 5, thickness: 0.5))
                      ]))),
          Expanded(
              child: TextField(
                  controller: widget.phoneNumController,
                  keyboardType: TextInputType.number,
                  decoration: kInputDecoration.copyWith(
                      hintText: 'Phone Number',
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))))))
        ]));
  }
}
