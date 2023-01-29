import 'dart:io';

import 'package:dio/dio.dart';

// dio 默认使用json传递数据
class DataAdapterInterptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final extra = options.extra;
    final reqType = extra['reqType'];

    if (reqType == 'formData') {
      options.data = FormData.fromMap(options.data);
    } else if (reqType == 'form') {
      options.contentType = Headers.formUrlEncodedContentType;
    } else {
      options.contentType = Headers.jsonContentType;
    }

    handler.next(options);
  }
}
