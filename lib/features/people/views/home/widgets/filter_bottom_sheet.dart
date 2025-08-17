// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/stadium_button.dart';
import '../../../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../../../services/locatoin_provider.dart';
import '../../../../../utils/functions.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../services/people_provider.dart';
import 'search_location_dialog.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key, required this.size}) : super(key: key);

  final Size size;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ValueNotifier<String> locationNotifier;

  final userPlan = Hive.box('user').get('plan') ?? 1;
  final planExpired = Hive.box('user').get('plan_expired') ?? true;

  int distance = 30;
  String interested = '3';
  String selectedPlan = '0';
  int ageStart = 18;
  int ageEnd = 40;

  List<Map<String, dynamic>> genders = [
    {
      'name': 'Men',
      'icon': FontAwesomeIcons.mars,
      'value': '1',
    },
    {
      'name': 'Women',
      'icon': FontAwesomeIcons.venus,
      'value': '2',
    },
    {
      'name': 'Everyone',
      'icon': FontAwesomeIcons.venusMars,
      'value': '3',
    },
  ];
  Map<String, String> plans = {
    '1': 'Basic',
    '2': 'Plus',
    '3': 'Both',
  };

  @override
  void initState() {
    final locProvider = context.read<LocationProvider>();
    locationNotifier = ValueNotifier(locProvider.getSelectedLocation());
    initialize();
    super.initState();
  }

  void initialize() {
    final peopleProvider = context.read<PeopleProvider>();
    distance = int.parse(peopleProvider.radius);
    interested = peopleProvider.interested;
    selectedPlan = peopleProvider.restrict;
    ageStart = int.parse(peopleProvider.ageStart);
    ageEnd = int.parse(peopleProvider.ageEnd);
  }

  void clearFilters() {
    final peopleProvider = context.read<PeopleProvider>();
    peopleProvider.clearData();
    initialize();
    setState(() {});
  }

  void selectLocationDialog() async {
    // PermissionStatus status = await Permission.location.request();
    // if (status.isDenied) {
    //   selectLocationDialog();
    // } else if (status.isGranted) {
    showDialog(
        context: context,
        builder: (context) => SearchLocationDialog(locationNotifier));
    // } else if (status.isPermanentlyDenied) {
    //   // openAppSettings();
    //   Navigator.pop(context);
    //   showSnackBar("Please enable location sharing in Settings");
    // }
  }

  void applyFilters() {
    final peopleProvider = context.read<PeopleProvider>();
    peopleProvider.isLoading = true;
    final locProvider = context.read<LocationProvider>();
    locProvider.saveUserSelectedLocation(locationNotifier.value);
    peopleProvider.radius = distance.toString();
    peopleProvider.interested = interested;
    peopleProvider.restrict = selectedPlan;
    peopleProvider.ageStart = ageStart.toString();
    peopleProvider.ageEnd = ageEnd.toString();
    Future.delayed(const Duration(milliseconds: 600)).then((value) {
      Navigator.of(context).pop(true);
      peopleProvider.isLoading = false;
    });
    peopleProvider.fetchPeople(context);
  }

  @override
  void dispose() {
    locationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(widget.size.width * 0.05),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(width: 48), // for alignment
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const FaIcon(FontAwesomeIcons.xmark)),
              ]),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text('Location',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: widget.size.height * 0.01),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.size.width * 0.05,
                              vertical: 10),
                          decoration: BoxDecoration(
                              color: AppColors.lighterGrey,
                              borderRadius: BorderRadius.circular(50)),
                          child: GestureDetector(
                              onTap: () {
                                if (userPlan == 4 && !planExpired) {
                                  selectLocationDialog();
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          UpgradePlanDialog());
                                  return;
                                }
                                log(locationNotifier.value);
                              },
                              child: ValueListenableBuilder(
                                  valueListenable: locationNotifier,
                                  builder: (context, value, child) {
                                    return Text(locationNotifier.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge);
                                  }))),
                      SizedBox(height: widget.size.height * 0.02),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Distance',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('$distance km',
                                style: Theme.of(context).textTheme.titleMedium),
                          ]),
                      Slider(
                          value: distance / 100,
                          min: 0.3,
                          activeColor: AppColors.borderBlue,
                          inactiveColor: AppColors.lightGrey,
                          onChanged: (val) {
                            if (userPlan > 2 && !planExpired) {
                              setState(() => distance = (val * 100).round());
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => UpgradePlanDialog());
                              return;
                            }
                          }),
                      SizedBox(height: widget.size.height * 0.02),
                      Text('Interested in',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: widget.size.height * 0.01),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: genders
                              .map((e) => StadiumButton(
                                  onPressed: () =>
                                      setState(() => interested = e['value']),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: widget.size.width * 0.04,
                                      vertical: widget.size.width * 0.01),
                                  textColor: interested == e['value']
                                      ? AppColors.white
                                      : AppColors.black,
                                  bgColor: interested == e['value']
                                      ? null
                                      : AppColors.lighterGrey,
                                  gradient: interested == e['value']
                                      ? AppColors.purpleH
                                      : null,
                                  child: Row(children: [
                                    FaIcon(e['icon'],
                                        size: widget.size.width * 0.05),
                                    SizedBox(width: widget.size.width * 0.01),
                                    Text(e['name']),
                                  ])))
                              .toList()),
                      SizedBox(height: widget.size.height * 0.02),
                      Text('Restrict matches from',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: widget.size.height * 0.01),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: plans.entries
                              .map((e) => StadiumButton(
                                  onPressed: () {
                                    debugPrint(Hive.box('user')
                                        .get('plan')
                                        .toString());
                                    if (userPlan != 1 && !planExpired) {
                                      if (e.key == '2' || e.key == '3') {
                                        if (userPlan == 4 && !planExpired) {
                                          setState(() {
                                            selectedPlan == e.key
                                                ? selectedPlan = '0'
                                                : selectedPlan = e.key;
                                          });
                                        } else {
                                          showUpgradePlanDialog();
                                          return;
                                        }
                                      } else {
                                        setState(() {
                                          selectedPlan == e.key
                                              ? selectedPlan = '0'
                                              : selectedPlan = e.key;
                                        });
                                      }
                                    } else {
                                      showUpgradePlanDialog();
                                      return;
                                    }
                                  },
                                  padding: EdgeInsets.symmetric(
                                      horizontal: widget.size.width * 0.06,
                                      vertical: widget.size.width * 0.01),
                                  textColor: selectedPlan == e.key
                                      ? AppColors.white
                                      : AppColors.black,
                                  bgColor: selectedPlan == e.key
                                      ? null
                                      : AppColors.lighterGrey,
                                  gradient: selectedPlan == e.key
                                      ? AppColors.purpleH
                                      : null,
                                  child: Text(e.value)))
                              .toList()),
                      SizedBox(height: widget.size.height * 0.02),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Age Range',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('$ageStart - $ageEnd',
                                style: Theme.of(context).textTheme.titleMedium)
                          ]),
                      SizedBox(height: widget.size.height * 0.01),
                      RangeSlider(
                          values: RangeValues(
                              ageStart.toDouble(), ageEnd.toDouble()),
                          // const RangeValues(18, 40),
                          min: 18,
                          max: 100,
                          activeColor: AppColors.purple,
                          inactiveColor: AppColors.lightGrey,
                          onChanged: (val) => setState(() {
                                ageStart = val.start.round();
                                ageEnd = val.end.round();
                              })),
                      SizedBox(height: widget.size.height * 0.02),
                      Consumer<PeopleProvider>(builder: (_, val, child) {
                        return StadiumButton(
                          onPressed: val.isLoading ? null : applyFilters,
                          // text: 'Apply Filters',
                          gradient: AppColors.buttonBlue,
                          textColor: Colors.white,
                          child: val.isLoading
                              ? const BtnLoadingAnimation()
                              : const Text('Apply Filters'),
                        );
                      }),
                      TextButton(
                          onPressed: clearFilters,
                          style: TextButton.styleFrom(
                              shape: const StadiumBorder()),
                          child: Text('Clear all',
                              style: Theme.of(context).textTheme.titleMedium))
                    ])),
              ),
            ]));
  }
}
