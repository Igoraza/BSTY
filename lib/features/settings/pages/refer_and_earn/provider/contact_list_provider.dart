import 'package:flutter/material.dart';

import '../model/contact_list_model.dart';

class ContactListProvider extends ChangeNotifier {
  final _contactLists = [
    ContactListModel(
      name: 'John Doe',
      id: 1,
    ),
    ContactListModel(
      name: 'Jane Doe',
      id: 2,
    ),
    ContactListModel(
      name: 'John',
      id: 3,
    ),
    ContactListModel(
      name: 'Doe',
      id: 4,
    ),
  ];

  List<ContactListModel> get getContactList => _contactLists;
}
