import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService() : _remoteConfig = FirebaseRemoteConfig.instance;

  int get imageMaxWidth => _remoteConfig.getInt('image_max_width');
  int get imageMaxHeight => _remoteConfig.getInt('image_max_height');

  Future initialize() async {
    try {
      await _remoteConfig.setDefaults(const {
        'image_max_width': 1080,
        'image_max_height': 1350,
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(seconds: 1),
      ));

      await _remoteConfig.fetchAndActivate();
    } catch (exception) {
      debugPrint(
          'Unable to fetch remote config. Cached or default values will be used.');
    }
  }
}
