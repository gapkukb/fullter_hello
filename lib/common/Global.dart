import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

// 全局变量,贯穿app生命周期
class Global {
  static late SharedPreferences _prefs;

  // 主题列表
  static List<MaterialColor> get themes => _themes;

  static bool get isRelease => bool.fromEnvironment("dart.vm.prodct");

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 读取app本地配置
    _prefs = await SharedPreferences.getInstance();

    var _profile = _prefs.getString("profile");
    if (_profile != null) {
      try {
        // profile = profile
      } catch (e) {}
    }
  }
}
