import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:bsty/api/api_helper.dart';
import 'package:bsty/api/endpoints.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';

import '../model/referred_peeps_model.dart';

class ReferredPeepsProvider extends ChangeNotifier {
  final dio = Api().api;

  final referredLsit = [
    ReferredPeepsModel(
      id: '1',
      avatar: null,
      numberOrMail: '1234567890',
      verified: false,
    ),
    ReferredPeepsModel(
      id: '2',
      avatar: null,
      numberOrMail: 'test@test.com',
      verified: false,
    ),
    ReferredPeepsModel(
      id: '3',
      avatar: null,
      numberOrMail: 'gouthamsagar/fb.com',
      verified: false,
    ),
    ReferredPeepsModel(
      id: '4',
      avatar: null,
      numberOrMail: 'gsagar/insta',
      verified: true,
    ),
  ];

  List<ReferredPeepsModel> get getReferredPeeps => referredLsit;

  Future<List<Referral>?> getReferrals() async {
    try {
      // final userTokens = await AuthProvider().retrieveUserTokens();
      // log(userTokens.toString());
      // final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response = await dio.get(
        Endpoints.getReferrals,
        // options: Options(headers: headers),
      );
      log(response.toString());
      if (response.statusCode == 200 && response.data['status']) {
        final List<Referral> mep = List<Referral>.from(response
            .data['referrals']
            .map((model) => Referral.fromJson(model)));
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
