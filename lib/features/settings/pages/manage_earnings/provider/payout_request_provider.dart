import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bsty/api/api_helper.dart';
import 'package:bsty/api/endpoints.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';

import '../model/redeem_transaction_model.dart';

class PayoutRequestProvider extends ChangeNotifier {
  final dio = Api().api;

  bool _isLoading = false;
  bool get getLoading => _isLoading;
  set setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // List<PayoutRequestModel> get getPayoutRequests => payoutRequests;
  Future<bool> payoutRequest({
    required String name,
    required String accNumber,
    required String bnkName,
    required String brnName,
    required String phnNumber,
    required int paymentMethod,
    required String amount,
  }) async {
    try {
      setLoading = true;
      FormData data = FormData.fromMap({
        'amount': amount,
        'payment_method': paymentMethod,
        'mobile_number': phnNumber,
        'account_number': accNumber,
        'bank_name': bnkName,
        'branch_name': brnName,
        'name': name,
      });
      log(data.fields.toString());
      final response = await dio.post(
        Endpoints.payRequest,
        data: data,
      );
      log(response.statusCode.toString());
      if (response.statusCode == 200 && response.data['status']) {
        // final List<Payout> mep = List<Payout>.from(
        //     response.data['payouts'].map((model) => Payout.fromJson(model)));
        // response.data['transactions'].

        log(response.data.toString());
        setLoading = false;
        return true;
      } else {
        setLoading = false;
        throw Exception(response.data['message']);
      }
    } catch (e) {
      debugPrint("getTransHistory error $e");
    }
    setLoading = false;
    return false;
  }

  Future<List<Payout>?> getPayoutRequests() async {
    try {
      // final userTokens = await AuthProvider().retrieveUserTokens();
      // log(userTokens.toString());
      // final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response = await dio.get(
        Endpoints.getPayoutRequests,
        // options: Options(headers: headers),
      );
      // log(response.toString());
      if (response.statusCode == 200 && response.data['status']) {
        final List<Payout> mep = List<Payout>.from(
            response.data['payouts'].map((model) => Payout.fromJson(model)));
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
