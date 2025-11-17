import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/theme/colors.dart';
import '../../services/initial_profile_provider.dart';
import '../../widgets/birthday_display_item.dart';
import 'height_page.dart';

class SelectDob extends StatefulWidget {
  static const String routeName = '/select-dob';

  const SelectDob({Key? key}) : super(key: key);

  @override
  State<SelectDob> createState() => _SelectDobState();
}

class _SelectDobState extends State<SelectDob> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    /// [ Functions ]

    Future<void> pickDate(double appHeight) {
      final now = DateTime.now();
      final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

      return Platform.isIOS
          ? showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return SizedBox(
                  height: appHeight * 0.4,
                  child: CupertinoDatePicker(
                    backgroundColor: Colors.white,
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: eighteenYearsAgo,
                    maximumDate: eighteenYearsAgo,
                    minimumDate: DateTime(1900),
                    onDateTimeChanged: (DateTime newdate) {
                      setState(() => selectedDate = newdate);
                    },
                  ),
                );
              },
            )
          : showDatePicker(
              context: context,
              initialDate: eighteenYearsAgo,
              firstDate: DateTime(1900),
              lastDate: eighteenYearsAgo,
            ).then((value) {
              if (value != null) {
                setState(() => selectedDate = value);
              }
            });
    }

    void saveUserDob(BuildContext context, DateTime dob) {
      final dobString = DateFormat('yyyy-MM-dd').format(dob);
      context.read<InitialProfileProvider>().dob = dobString;
      Navigator.pushNamed(context, SelectHeight.routeName);
    }

    /// [ Widgets ]

    final continueBtn = StadiumButton(
      gradient: AppColors.buttonBlue,
      visualDensity: VisualDensity.standard,
      onPressed: () {
        if (selectedDate == null) {
          showSnackBar('Please select your date of birth');
          return;
        }
        saveUserDob(context, selectedDate!);
      },
      child: Text(
        'Continue',
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(color: AppColors.white),
      ),
    );

    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Select Date of Birth')),
        body: Padding(
          padding: EdgeInsets.all(
            appWidth * 0.05,
          ).copyWith(bottom: appHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Your Birthday?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: appHeight * 0.025),
              GestureDetector(
                onTap: () => pickDate(appHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: BirthdayDisplayItem(
                        title: selectedDate != null
                            ? selectedDate!.year.toString()
                            : 'Year',
                      ),
                    ),
                    SizedBox(width: appWidth * 0.05),
                    Expanded(
                      child: BirthdayDisplayItem(
                        title: selectedDate != null
                            ? DateFormat.MMM().format(selectedDate!)
                            : 'Month',
                      ),
                    ),
                    SizedBox(width: appWidth * 0.05),
                    Expanded(
                      child: BirthdayDisplayItem(
                        title: selectedDate != null
                            ? selectedDate!.day.toString()
                            : 'Day',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'To complete the registration, you must be at least\n18 years of age.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: appHeight * 0.025),
              continueBtn,
            ],
          ),
        ),
      ),
    );
  }
}
