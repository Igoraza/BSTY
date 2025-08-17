import 'package:flutter/material.dart';

import '../model/payment_option_model.dart';

class PaymentOptionProvider extends ChangeNotifier {
  int payOptionId = 1;
  List<PaymentOptionModel> paymentOptions = [
    PaymentOptionModel(
      id: 1,
      title: 'Airtel Money',
      onPressed: () {
        debugPrint('Airtel Money');
      },
    ),
    PaymentOptionModel(
      id: 2,
      title: 'Mpamba',
      onPressed: () {
        debugPrint('Mpamba');
      },
    ),
    PaymentOptionModel(
      id: 3,
      title: 'Bank Account',
      onPressed: () {
        debugPrint('Bank Account');
      },
    ),
  ];

  List<PaymentOptionModel> get getPaymentOptions => paymentOptions;

  PaymentOptionModel? _selectedOption;
  PaymentOptionModel? get selectedOption => _selectedOption;
  set selectedOption(PaymentOptionModel? value) {
    _selectedOption = value;
    notifyListeners();
  }
}
