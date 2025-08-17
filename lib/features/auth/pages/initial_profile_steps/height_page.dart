import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../utils/theme/colors.dart';
import '../../services/initial_profile_provider.dart';
import '../../widgets/birthday_display_item.dart';
import 'select_gender_page.dart';

class SelectHeight extends StatefulWidget {
  const SelectHeight({Key? key}) : super(key: key);

  static const String routeName = '/select-height';

  @override
  State<SelectHeight> createState() => _SelectHeightState();
}

class _SelectHeightState extends State<SelectHeight> {
  int height = 172;
  String heightInFeet = '5\'8"';
  bool isTyping = false;
  final _controller = TextEditingController(text: '172');

  String getheightInFeet() {
    final feet = height ~/ 30.48;
    final inches = (height % 30.48) ~/ 2.54;
    return '$feet\'$inches"';
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    final heightInputField = TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  height = int.parse(_controller.text);
                  heightInFeet = getheightInFeet();
                  setState(() => isTyping = false);
                }),
            hintText: 'Enter your height in cm',
            hintStyle: Theme.of(context).textTheme.bodyLarge));

    final continueBtn = Visibility(
        visible: !isTyping,
        child: StadiumButton(
            gradient: AppColors.buttonBlue,
            visualDensity: VisualDensity.standard,
            onPressed: () {
              context.read<InitialProfileProvider>().height = height.toString();
              Navigator.pushNamed(context, SelectGender.routeName);
            },
            child: Text('Continue',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.white))));

    return BackgroundImage(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('Height')),
            body: Padding(
                padding: EdgeInsets.all(appWidth * 0.05)
                    .copyWith(bottom: appHeight * 0.05),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Text('How tall are you?',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: appHeight * 0.025),
                      BirthdayDisplayItem(
                          onPressed: () => setState(() => isTyping = true),
                          title: isTyping ? null : '$height cm ($heightInFeet)',
                          padding: isTyping
                              ? const EdgeInsets.all(4)
                              : EdgeInsets.all(appWidth * 0.05),
                          child: isTyping ? heightInputField : null),
                      const Spacer(),
                      continueBtn
                    ]))));
  }
}
