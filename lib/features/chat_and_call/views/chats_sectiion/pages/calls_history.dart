import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../common_widgets/snapshot_error.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/call.dart';
import '../../../services/call_provider.dart';
import '../widgets/call_tile.dart';

class CallsHistory extends StatefulWidget {
  const CallsHistory({Key? key}) : super(key: key);

  @override
  State<CallsHistory> createState() => _CallsHistoryState();
}

class _CallsHistoryState extends State<CallsHistory> {
  late Future<List<Call>> callsFuture;

  @override
  void initState() {
    super.initState();
    callsFuture = context.read<CallsProvider>().fetchCallHistory(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final searchKey = ValueNotifier('');

    final searchField = Padding(
        padding: EdgeInsets.all(size.height * 0.02),
        child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                suffixIcon: SvgPicture.asset(
                  'assets/svg/chat/icon_search.svg',
                  // width: appWidth * 0.003,
                  fit: BoxFit.scaleDown,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.height * 0.02,
                  vertical: size.height * 0.01,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none)),
            onChanged: (value) => searchKey.value = value));

    return FutureBuilder(
        future: callsFuture,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return mainLoadingAnimationDark;
          } else if (snapshot.hasError) {
            String errorMsg = '';

            /// chieck if [ connection error ]
            if (snapshot.error.toString().contains('SocketException')) {
              errorMsg =
                  'Error retrieving calls.\nPlease check your internet connection';
            } else {
              errorMsg = 'Error retrieving calls. Try again later';
            }

            return SnapshotErrorWidget(errorMsg);
          } else if (snapshot.data == null || snapshot.data.isEmpty) {
            return Center(
                child: Text('No calls yet',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center));
          }

          final calls = snapshot.data as List<Call>;
          debugPrint('=====================> Calls: ${calls[0].toJson()}');
          return Column(children: [
            searchField,
            Expanded(
                child: RefreshIndicator(
              onRefresh: () async => setState(() => callsFuture =
                  context.read<CallsProvider>().fetchCallHistory(context)),
              child: ValueListenableBuilder(
                  valueListenable: searchKey,
                  builder: (_, value, __) {
                    final int currentUserid = Hive.box('user').get('id');
                    List<Call> filteredCalls = calls;
                    if (value != '') {
                      filteredCalls = calls
                          .where((call) => call.user.id == currentUserid
                              ? call.targetUser.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase())
                              : call.user.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    }

                    return ListView.separated(
                        padding: EdgeInsets.all(size.height * 0.02),
                        itemCount: filteredCalls.length,
                        itemBuilder: (_, i) => CallTile(call: filteredCalls[i]),
                        separatorBuilder: (context, index) => Divider(
                            height: 10,
                            indent: size.width * 0.2,
                            color: AppColors.lightGrey));
                  }),
            ))
          ]);
        });
  }
}
