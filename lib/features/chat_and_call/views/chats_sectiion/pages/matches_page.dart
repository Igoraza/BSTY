import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/features/chat_and_call/models/chat.dart';
import 'package:bsty/features/chat_and_call/services/chat_provider.dart';
import 'package:bsty/features/chat_and_call/views/chat_messages/pages/chat_page.dart';
import 'package:bsty/features/people/views/detailed/person_details_page.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../common_widgets/snapshot_error.dart';
import '../../../../../utils/theme/colors.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final searchKey = ValueNotifier('');
    final chatProvider = context.read<ChatProvider>();

    return StreamBuilder(
        stream: chatProvider.getMatches(),
        builder: (context, snapshot) {
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
              } else if (snapshot.data == null) {
                return Center(
                    child: Text('No Matches yet',
                        style: Theme.of(context).textTheme.bodyLarge!));
              } else if (snapshot.data!.isEmpty) {
                return Center(
                    child: Text('No Matches yet',
                        style: Theme.of(context).textTheme.bodyLarge!));
              }

              return Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(screenH * 0.02),
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
                                horizontal: screenH * 0.02,
                                vertical: screenH * 0.01,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              )),
                          onChanged: (value) => searchKey.value = value)),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: searchKey,
                        builder: (_, val, __) {
                          List<Chat>? filteredChats = snapshot.data;
                          if (val.isNotEmpty) {
                            filteredChats = snapshot.data!
                                .where((element) =>
                                    element.name.toLowerCase().contains(val))
                                .toList();
                          }
                          return ListView.separated(
                              padding: EdgeInsets.all(screenH * 0.02),
                              itemCount: filteredChats!.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 20),
                              itemBuilder: (context, index) {
                                final matches = filteredChats![index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      PersonDetailedPage.routeName,
                                      arguments: {
                                        'id': matches.targetId,
                                        'name': matches.name,
                                        'image': matches.image,
                                      },
                                    );
                                  },
                                  child: ListTile(
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: appWidth * 0.08,
                                          foregroundImage:
                                              CachedNetworkImageProvider(
                                            matches.image,
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                          ),
                                        ),

                                        /// [Online status]
                                        // if (isOnline) ...[
                                        //   Positioned(
                                        //       top: appWidth * 0.005,
                                        //       right: appWidth * 0.015,
                                        //       child: Container(
                                        //           width: appWidth * 0.03,
                                        //           height: appWidth * 0.03,
                                        //           decoration: const BoxDecoration(
                                        //               border: Border.fromBorderSide(
                                        //                   BorderSide(color: AppColors.white)),
                                        //               color: AppColors.teal,
                                        //               shape: BoxShape.circle)))
                                        // ]
                                      ],
                                    ),
                                    title: Text(
                                      matches.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, ChatPage.routeName,
                                            arguments: matches);
                                      },
                                      child: SvgPicture.asset(
                                        'assets/svg/chat/chat_icon.svg',
                                        fit: BoxFit.contain,
                                        height: screenH * 0.034,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              // ChatTile()
                              );
                        }),
                  ),
                ],
              );
          }
        });
  }
}
