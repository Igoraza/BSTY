import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/custom_chip.dart';
import '../../../../common_widgets/primary_button.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/theme/colors.dart';
import '../../services/initial_profile_provider.dart';
import 'select_perfect_fit.dart';

class SelectInterest extends StatefulWidget {
  const SelectInterest({Key? key}) : super(key: key);

  static const routeName = '/select-interest';

  @override
  State<SelectInterest> createState() => _SelectInterestState();
}

class _SelectInterestState extends State<SelectInterest> {
  List interests = [];

  List selectedInterests = [];
  List _searchedItems = [];

  @override
  void initState() {
    super.initState();
    context.read<InitialProfileProvider>().getInterestsList().then((value) {
      setState(() {
        interests = value;
        _searchedItems = interests;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    /// [ Widgets ]

    final searchField = CupertinoSearchTextField(
      onChanged: (value) => setState(
        () => _searchedItems = interests
            .where(
              (element) => element['title']!.toLowerCase().contains(
                value.trim().toLowerCase(),
              ),
            )
            .toList(),
      ),
      placeholder: 'Search your interests',
      style: Theme.of(context).textTheme.bodyMedium,
      padding: const EdgeInsets.all(12),
      backgroundColor: AppColors.white,
    );

    final interestItemsGrid = Expanded(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: (_searchedItems.isNotEmpty ? _searchedItems : interests)
            .map(
              (e) => GestureDetector(
                onTap: () => setState(
                  () => selectedInterests.contains(e['id'])
                      ? selectedInterests.remove(e['id'])
                      : selectedInterests.add(e['id']),
                ),
                child: CustomChip(
                  text: e['title'],
                  isSelected: selectedInterests.contains(e['id']),
                  bgColor: selectedInterests.contains(e['id'])
                      ? AppColors.borderBlue
                      : AppColors.white,
                  texColor: selectedInterests.contains(e['id'])
                      ? AppColors.white
                      : AppColors.black,
                ),
              ),
            )
            .toList(),
      ),
    );

    final continueBtn = PrimaryBtn(
      text: 'Continue',
      gradient: AppColors.buttonBlue,
      onPressed: () {
        if (selectedInterests.isEmpty) {
          showSnackBar('Please select at least one interest');
          return;
        }
        final interestsString = selectedInterests.join('#');
        context.read<InitialProfileProvider>().interests = interestsString;
        Navigator.of(context).pushNamed(PerfectFit.routeName);
      },
    );

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Interests'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(PerfectFit.routeName),
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(
            appWidth * 0.05,
          ).copyWith(bottom: appHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              SizedBox(height: appHeight * 0.025),
              interestItemsGrid,
              SizedBox(height: appHeight * 0.025),
              continueBtn,
            ],
          ),
        ),
      ),
    );
  }
}
