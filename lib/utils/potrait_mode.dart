import 'package:flutter/services.dart';

potraitmode() {
  /// [ ensures portrait at all times. you can override this if necessary ]
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}
