import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/custom_chip.dart';
import '../../../../common_widgets/primary_button.dart';
import '../../../../utils/theme/colors.dart';
import '../../services/initial_profile_provider.dart';
import 'select_interests.dart';

class SelectOrientation extends StatefulWidget {
  const SelectOrientation({Key? key}) : super(key: key);

  static const routeName = '/select-orientation';

  @override
  State<SelectOrientation> createState() => _SelectOrientationState();
}

class _SelectOrientationState extends State<SelectOrientation> {
  late Future<List> future;

  @override
  void initState() {
    super.initState();
    future = context.read<InitialProfileProvider>().getOrientationsList();
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    /// [ Widgets ]
    final orientationCihps = FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Expanded(
                child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            final orientations = snapshot.data ?? [];
            return Consumer<InitialProfileProvider>(
                builder: (_, ref, __) => Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: orientations
                        .map((e) => GestureDetector(
                            onTap: () => ref.orientation = e['id'].toString(),
                            child: CustomChip(
                              text: e['title'],
                              isSelected: ref.orientation == e['id'].toString(),
                            )))
                        .toList()));
          }
        });

    final displayOrientationCheckbox = Consumer<InitialProfileProvider>(
        builder: (_, ref, child) =>
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Checkbox(
                value: ref.displayOrientation,
                onChanged: (value) => ref.toggleDisplayOrientation(),
                activeColor: AppColors.black,
              ),
              child!
            ]),
        child: const Text('Display my gender'));

    final continueBtn = PrimaryBtn(
        text: 'Continue',
        gradient: AppColors.buttonBlue,
        onPressed: () =>
            Navigator.of(context).pushNamed(SelectInterest.routeName));

    return BackgroundImage(
        child: Scaffold(
            appBar: AppBar(title: const Text('Orientation')),
            body: Padding(
                padding: EdgeInsets.all(appHeight * 0.02)
                    .copyWith(bottom: appHeight * 0.05),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('You are looking for?',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: appHeight * 0.025),
                      orientationCihps,
                      const Spacer(),
                      SizedBox(height: appHeight * 0.025),
                      displayOrientationCheckbox,
                      continueBtn
                    ]))));
  }
}
