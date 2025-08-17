import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bsty/api/api_helper.dart';
import 'package:bsty/api/endpoints.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';

import '../model/redeem_transaction_model.dart';

class RedeemTransactionProvider extends ChangeNotifier {
  final dio = Api().api;
  final redeemTransactions = [
    PayoutRequestModel(
        transactionId: '1',
        transactionDate: 'Tue 10, 20:22 PM',
        transactionAmount: '200',
        transactionType: 'Redeem Coins',
        transactionStatus: false),
    PayoutRequestModel(
        transactionId: '2',
        transactionDate: 'Tue 10, 20:22 PM',
        transactionAmount: '500',
        transactionType: 'Redeem Coins',
        transactionStatus: true),
  ];

  List<PayoutRequestModel> get getRedeemTransactions => redeemTransactions;

  double _convertedAmount = 0.0;

  double get convertedAmount => _convertedAmount;
  set convertedAmount(double value) {
    _convertedAmount = value;
    notifyListeners();
  }

  Future<List<Payout>?> getTransHistory() async {
    try {
      final userTokens = await AuthProvider().retrieveUserTokens();
      // log(userTokens.toString());
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response = await dio.get(Endpoints.transHistory,
          options: Options(headers: headers));
      // log(response.toString());
      if (response.statusCode == 200 && response.data['status']) {
        final List<Payout> mep = List<Payout>.from(response.data['transactions']
            .map((model) => Payout.fromJson(model)));
        // response.data['transactions'].

        log(mep.first.toString());
        return mep;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      debugPrint("getTransHistory error $e");
    }
    return null;
  }
}
