import 'package:flutter/material.dart';
import 'dart:math' as math show Random;

import 'package:hello/common/Global.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  Global.init()
      .then((data) => runApp(MyApp()))
      .catchError((e) => {debugPrint(e.toString())});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {},
    );
  }
}

const _sm = 640;
const _md = 768;
const _lg = 1024;
const _xl = 1280;
const _xxl = 1536;

// 响应式工具
extension Responsive on BuildContext {
  T on<T>(
    T defaultVal, {
    T? sm,
    T? md,
    T? lg,
    T? xl,
    T? xxl,
  }) {
    // deviceWidth
    final dw = MediaQuery.of(this).size.width;

    if (dw < _sm) return defaultVal;
    if (dw < _md) return sm ?? defaultVal;
    if (dw < _lg) return md ?? sm ?? defaultVal;
    if (dw < _xl) return lg ?? md ?? sm ?? defaultVal;
    if (dw < _xxl) return xl ?? lg ?? md ?? sm ?? defaultVal;
    return xxl ?? xl ?? lg ?? md ?? sm ?? defaultVal;
  }
}
