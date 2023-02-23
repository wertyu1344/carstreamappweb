import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart' show ZegoScenario;

class ZegoConfig {
  static final ZegoConfig instance = ZegoConfig._internal();
  ZegoConfig._internal();

  ZegoScenario scenario = ZegoScenario.Default;

  bool enablePlatformView = kIsWeb ? true : false;
}
