import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/auth/services/auth_provider.dart';
import '../utils/global_keys.dart';

class Api {
  final Dio api = Dio();
  final authProvider = navigatorKey.currentContext!.read<AuthProvider>();

  Api() {
    api.interceptors
      ..clear
      ..add(InterceptorsWrapper(onRequest: (options, handler) async {
        var userTokens = await authProvider.retrieveUserTokens();
        // log("user token $userTokens");
        String accessToken = userTokens['access']!;
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      }, onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401) {
          if (await authProvider.refreshToken()) {
            final opts = error.requestOptions;

            if (opts.method == 'POST') {
              opts.data = FormData.fromMap(opts.extra['data']);
            }

            return handler.resolve(await _retry(opts));
          } else {
            debugPrint('+++++++++++++refresh token is invalid, logging out');
            // authProvider.logout();
          }
        } else if (error.response?.statusMessage?.contains('SocketException') ==
            true) {
          debugPrint('+++++++++++++no internet connection');
        }
        return handler.next(error);
      }));
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    Options options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    debugPrint('+++++++++++++retrying request');
    return api.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }
}
