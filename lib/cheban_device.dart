import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class ChebanDevice {
  static const MethodChannel _channel = MethodChannel('cheban_device');

  static Future<InitData> init({
      String? suiteName}) async {
    dynamic arguments = <String, dynamic>{};
    arguments["suiteName"] = suiteName;

    final dynamic value = await _channel.invokeMethod('init', arguments);
    InitData data = InitData();
    if (value is Map) {
      data.environment = value["environment"];
      data.sandbox = value["sandbox"];
      data.testFlight = value["testFlight"];
    }
    return data;
  }

  static Future<String?> get hardwareDeviceID async {
    final String? value = await _channel.invokeMethod('getHardwareDeviceID');
    return value;
  }

  /// 获取设备唯一标识码
  static Future<String> get formatHardwareDeviceID async {
    // todo bpush token好像更不容易变化
    String? token = await hardwareDeviceID;
    if (token != null) {
      var content = const Utf8Encoder().convert("cheban_sing:$token");
      var digest = md5.convert(content);
      // 这里其实就是 digest.toString()
      token = hex.encode(digest.bytes);
    }
    // print("+++++++++++++:"+token!);
    return token ?? "";
  }

  static Future<String?> get environment async {
    final String? value = await _channel.invokeMethod('getEnvironment');
    return value;
  }

  static Future<bool?> get isSandbox async {
    final bool? value = await _channel.invokeMethod('getISSandbox');
    return value;
  }

  static Future<bool?> get isTestFlight async {
    final bool? value = await _channel.invokeMethod('isTestFlight');
    return value;
  }
}

class InitData {
  String? environment;
  bool? sandbox;
  bool? testFlight;
}
