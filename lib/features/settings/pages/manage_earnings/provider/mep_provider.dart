import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bsty/api/api_helper.dart';
import 'package:bsty/api/endpoints.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';

import '../model/mep_model.dart';

class MEPProvider extends ChangeNotifier {
  final dio = Api().api;
  // final mepModel = MEPModel(
  //     totalEarnedCoins: '25,759',
  //     expiringThisMonth: '12,435',
  //     withdrawn: '15,559',
  //     withdrawable: '14,559');

  // MEPModel get getMepModel => mepModel;

  Future<MepModel?> getMep() async {
    try {
      // log("response.data");
      final userTokens = await AuthProvider().retrieveUserTokens();
      // log(userTokens.toString());
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response =
          await dio.get(Endpoints.getMep, options: Options(headers: headers));
      // log(response.toString());
      if (response.statusCode == 200 && response.data['status']) {
        final MepModel mep = MepModel.fromJson(response.data);
        // log(mep.toString());
        return mep;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      debugPrint("getMep error $e");
    }
    return null;
  }
}
