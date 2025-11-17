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
  int _superLikes = Hive.box('user').get('super_like_balance') ?? 0;
  int _audioCall = Hive.box('user').get('audio_call_balance') ?? 0;
  int _videoCall = Hive.box('user').get('video_call_balance') ?? 0;

  int get boost => _boost;
  int get superLikes => _superLikes;
  int get audioCall => _audioCall;
  int get videoCall => _videoCall;

  void _updateHiveValue(String key, int value) {
    Hive.box('user').put(key, value);
  }

  // Method to refresh values from Hive (useful when returning to screen)
  void refreshFromHive() {
    _boost = Hive.box('user').get('profile_boost_balance') ?? 0;
    _superLikes = Hive.box('user').get('super_like_balance') ?? 0;
    _audioCall = Hive.box('user').get('audio_call_balance') ?? 0;
    _videoCall = Hive.box('user').get('video_call_balance') ?? 0;
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

      log(
        "Updating user plan url : ${Platform.isIOS ? Endpoints.purchaseIos : Endpoints.purchaseAndroid}",
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

        // Extract product_id and quantity from FormData
        final productId = data.fields
            .firstWhere((field) => field.key == 'product_id')
            .value;

        /// Example: productId could be like 'boost_3', 'superlike_3', 'audio_60'
        int quantity =
            int.tryParse(
              data.fields.firstWhere((f) => f.key == 'quantity').value,
            ) ??
            1;

        log("Product ID: $productId, Quantity: $quantity");
        log("Product ID toLowerCase: ${productId.toLowerCase()}");

        // Convert to lowercase for case-insensitive matching
        final productIdLower = productId.toLowerCase();

        // Update the appropriate balance based on product_id
        if (productIdLower.contains('boost')) {
          _boost += quantity;
          _updateHiveValue('profile_boost_balance', _boost);
          log("✅ Updated boost balance to: $_boost");
        } else if (productIdLower.contains('like')) {
          // Handles: 'like_3', 'superlike_5', 'super_like_10', etc.
          _superLikes += quantity;
          _updateHiveValue('super_like_balance', _superLikes);
          log("✅ Updated superlike balance to: $_superLikes");
        } else if (productIdLower.contains('audio') ||
            productIdLower.contains('voice')) {
          // Extract minutes from product_id (e.g., 'audio_call_60' -> 60 minutes)
          final RegExp minutesRegex = RegExp(r'(\d+)');
          final match = minutesRegex.firstMatch(productIdLower);
          int minutes = match != null ? int.parse(match.group(1)!) : quantity;

          _audioCall += minutes;
          _updateHiveValue('audio_call_balance', _audioCall);
          log("✅ Updated audio balance by $minutes minutes to: $_audioCall");
        } else if (productIdLower.contains('video')) {
          // Extract minutes from product_id (e.g., 'video_call_60' -> 60 minutes)
          final RegExp minutesRegex = RegExp(r'(\d+)');
          final match = minutesRegex.firstMatch(productIdLower);
          int minutes = match != null ? int.parse(match.group(1)!) : quantity;

          _videoCall += minutes;
          _updateHiveValue('video_call_balance', _videoCall);
          log("✅ Updated video balance by $minutes minutes to: $_videoCall");
        } else {
          log(
            "⚠️ WARNING: Product ID '$productId' did not match any category!",
          );
        }

        // CRITICAL: Notify listeners to update UI
        notifyListeners();
      } else {
        showSnackBar('Something went wrong!');
      }
    } on DioException catch (e) {
      log("Error updating purchase to server : $e");
      log("Error updating purchase to server : ${e.response}");
      showSnackBar('Error processing purchase');
    }
  }
}
