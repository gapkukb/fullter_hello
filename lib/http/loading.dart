import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';

// dio 默认使用json传递数据
class LoadingInterptor extends Interceptor {
  late final loading = () => true;
  late final loaded = () => true;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    //TODO
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    //TODO

    super.onError(err, handler);
  }
}
