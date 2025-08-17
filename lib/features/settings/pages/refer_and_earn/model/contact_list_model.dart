class ContactListModel {
  final String name;
  final int id;
  String image;

  ContactListModel({
    required this.id,
    required this.name,
    this.image = 'assets/svg/refer_earn/avatar.svg',
  });
}
