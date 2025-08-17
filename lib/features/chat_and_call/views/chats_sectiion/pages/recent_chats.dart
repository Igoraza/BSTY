
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../common_widgets/snapshot_error.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/chat.dart';
import '../../../services/chat_provider.dart';
import '../widgets/chat_tile.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final chatProvider = context.read<ChatProvider>();
    final searchKey = ValueNotifier('');
    // final matchesFuture = context.read<ChatProvider>().getMatches();
    List<Chat> matches = [];
    final userId = Hive.box('user').get('id') ?? '';

    final searchField = Padding(
        padding: EdgeInsets.all(mq.height * 0.02),
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
                  horizontal: mq.height * 0.02,
                  vertical: mq.height * 0.01,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none,
                )),
            onChanged: (value) => searchKey.value = value));

    return Consumer<ChatProvider>(
      builder: (context, ref, child) => StreamBuilder(
          stream: chatProvider.getMatches(),
          builder: (_, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return mainLoadingAnimationDark;

              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  String errorMsg = '';

                  /// chieck if [ connection error ]
                  if (snapshot.error.toString().contains('SocketException')) {
                    errorMsg =
                        'Error retrieving chats.\nPlease check your internet connection';
                  } else {
                    errorMsg = 'Error retrieving chats. Try again later';
                  }

                  return SnapshotErrorWidget(errorMsg);
                } else if (snapshot.data == null || snapshot.data.isEmpty) {
                  return Center(
                      child: Text('No Chats yet',
                          style: Theme.of(context).textTheme.bodyLarge!));
                }

                matches = snapshot.data;
                debugPrint(
                    '====================>> Mathces in recent chats: ${matches[0].toMap()}');

                return StreamBuilder<QuerySnapshot>(
                    stream: chatProvider.chatsStream(),
                    builder: (_, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return mainLoadingAnimationDark;

                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            debugPrint('Error: ${snapshot.error}');
                            return const Text('Something went wrong',
                                textAlign: TextAlign.center);
                          } else if (snapshot.data == null ||
                              snapshot.data.docs.isEmpty) {
                            return Center(
                                child: Text('No Chats yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!));
                          }

                          final List data = snapshot.data.docs;
                          final List<Chat> chats = data
                              .map((e) => Chat.fromJson(e.data()!))
                              .toList();

                          /// [ add matches from server to chats in firebase ] if not already present
                          // for (final match in matches) {
                          //   if (!chats.any((element) =>
                          //       element.targetId == match.targetId)) {
                          //     chats.add(match);
                          //   }
                          // }
                          return Column(children: [
                            searchField,
                            Expanded(
                              child: ValueListenableBuilder(
                                  valueListenable: searchKey,
                                  builder: (_, val, __) {
                                    List<Chat> filteredChats = chats;
                                    if (val.isNotEmpty) {
                                      filteredChats = chats
                                          .where((element) => element.name
                                              .toLowerCase()
                                              .contains(val))
                                          .toList();
                                    }

                                    return ListView.separated(
                                        padding: EdgeInsets.symmetric(
                                            vertical: mq.height * 0.02),
                                        itemCount: filteredChats.length,
                                        separatorBuilder: (_, __) => Divider(
                                            color: AppColors.lightGrey,
                                            indent: mq.width * 0.2),
                                        itemBuilder: (_, i) {
                                          debugPrint(
                                              '------------------ filteredChats.length ${filteredChats.length}');
                                          if (filteredChats[i].targetId !=
                                              userId) {
                                            return ChatTile(filteredChats[i]);
                                          } else if (filteredChats.length ==
                                                  1 &&
                                              filteredChats[i].targetId ==
                                                  userId) {
                                            return Center(
                                                child: Text('No Chats yet',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!));
                                          } else {
                                            return Container();
                                          }
                                        });
                                  }),
                            )
                          ]);
                      }
                    });
            }
          }),
    );
  }
}
