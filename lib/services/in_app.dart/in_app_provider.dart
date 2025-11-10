import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/api/api_helper.dart';
import 'package:bsty/utils/functions.dart';

import '../../api/endpoints.dart';
import '../../features/auth/services/auth_provider.dart';

class InAppProvider extends ChangeNotifier {
  final dio = Api().api;
  int _boost = Hive.box('user').get('profile_boost_balance') ?? 0;

  int get boost => _boost;
  set boost(int value) {
    _boost = value + 1;
    notifyListeners();
  }

  purchaseAndroid(FormData data) async {
    try {
      final userTokens = await AuthProvider().retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};

      log("Updating user plan : $data");

      final response = await dio.post(
        Platform.isIOS ? Endpoints.purchaseIos : Endpoints.purchaseAndroid,
        options: Options(headers: headers),
        data: data,
      );

      log("&&&&&&&&&&&&&&&&&&&&&& ${response.statusCode.toString()}");
      log("&&&&&&&&&&&&&&&&&&&&&& ${response.data.toString()}");
      log('------ Purchase Data to be sent to Server ------');
      data.fields.forEach((field) {
        log('${field.key}: ${field.value}');
      });
      log('-----------------------------------------------');
      log("Quantity :: ${data.fields[2]}");
      log(response.data.toString());
      if (response.data['status'] == true) {
        showSnackBar(response.data['message']);
        final profileBoost = Hive.box('user').get('profile_boost_balance') ?? 0;
        Hive.box('user').put('profile_boost_balance', profileBoost + 1);
        boost = boost;
      } else {
        showSnackBar('Something went wrong!');
      }
    } on DioException catch (e) {
      log("Error updating purchase to server : $e");

      log("Error updating purchase to server : ${e.response}");
    }
  }
}
