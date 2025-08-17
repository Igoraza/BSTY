import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../utils/theme/colors.dart';
import '../../people/services/people_provider.dart';

class DistanceSlider extends StatefulWidget {
  const DistanceSlider({Key? key, required this.radius, required this.refresh})
      : super(key: key);

  final ValueNotifier<String> radius;
  final Function refresh;

  @override
  State<DistanceSlider> createState() => _DistanceSliderState();
}

class _DistanceSliderState extends State<DistanceSlider> {
  late double distance;
  late double prevDistance;

  @override
  void initState() {
    super.initState();
    distance = double.parse(widget.radius.value);
    prevDistance = double.parse(widget.radius.value);
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    debugPrint('DistanceSlider: $distance | ${widget.radius.value}');
    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    return SizedBox(
      height: appHeight * 0.2,
      child: SfSliderTheme(
          data: SfSliderThemeData(
              activeTrackHeight: 12,
              activeTrackColor: AppColors.white,
              inactiveTrackHeight: 12,
              inactiveTrackColor: AppColors.black,
              thumbColor: AppColors.white,
              thumbRadius: 6,
              // tooltipBackgroundColor: Colors.transparent,
              tooltipTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              )),
          child: SfSlider.vertical(
              min: 30,
              max: 100,
              stepSize: 10,
              enableTooltip: true,
              interval: 20,
              showTicks: true,
              showLabels: true,
              // shouldAlwaysShowTooltip: true,
              tooltipPosition: SliderTooltipPosition.right,
              value: double.parse(widget.radius.value),
              onChangeStart: (_) {
                prevDistance = distance;
              },
              onChanged: (dynamic value) {
                if (userPlan == 4 && !planExpired) {
                  widget.radius.value = value.toString();
                  setState(() => distance = value);
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => UpgradePlanDialog(
                            title: 'Premium',
                          ));
                  // print(value);
                }
              },
              onChangeEnd: (_) {
                if (userPlan == 4 && !planExpired) {
                  if (prevDistance != distance) {
                    context.read<PeopleProvider>().radius =
                        distance.toInt().toString();
                    widget.refresh();
                  }
                }
              })),
    );
  }
}
