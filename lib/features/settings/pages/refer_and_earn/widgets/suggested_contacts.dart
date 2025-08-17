import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/theme/colors.dart';
import '../provider/contact_list_provider.dart';
import 'avatar_name_contact.dart';

class SuggestedContacts extends StatelessWidget {
  const SuggestedContacts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    final provider = Provider.of<ContactListProvider>(context);

    return Column(
      children: [
        Text('Suggested Contacts',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: AppColors.black),
            textAlign: TextAlign.center),
        SizedBox(height: appHeight * 0.01),

        /// [ TODO : Add Suggested Contacts List ]

        // Expanded(
        //     child: ListView.builder(
        //         scrollDirection: Axis.horizontal,
        //         itemCount: provider.contactList.length,
        //         itemBuilder: (context, index) {
        //           return Container(
        //               margin: EdgeInsets.symmetric(horizontal: appWidth * 0.15),
        //               padding: EdgeInsets.only(top: appHeight * 0.01),
        //               child: AvatarNameContact(
        //                   name: provider.contactList[1].name));
        //         }))

        AvatarNameContact(
          name: provider.getContactList[1].name,
          image: provider.getContactList[1].image,
        ),
      ],
    );
  }
}
