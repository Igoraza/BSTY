class PaymentOptionModel {
  final int id;
  final String title;
  final Function() onPressed;
  bool isSelected;

  PaymentOptionModel({
    required this.id,
    required this.title,
    required this.onPressed,
    this.isSelected = false,
  });
}
