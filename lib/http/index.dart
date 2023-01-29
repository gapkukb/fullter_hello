// 入口

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello/apis/index.dart';
import 'package:hello/common/Global.dart';
import 'package:hello/http/exception.dart';
import 'package:hello/http/proxy.dart';
import 'package:hello/http/retry.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    AppException appException = AppException.create(err);
    // 本地日志
    debugPrint('DioError:${appException.toString()}');
    err.error = appException;
    return super.onError(err, handler);
  }
}

class Http {
  // 超时阈值
  static const int CONNECT_TIMEOUT = 3000;
  static const int RECEIVE_TIMEOUT = 3000;

  static final _instance = Http._internal();

  factory Http() => _instance;
  late Dio dio;
  CancelToken _cancelToken = new CancelToken();

  Http._internal() {
    if (dio == null) {
      // 请求参数最终会按Baseoption->Options->requestOptions优先级合并.
      BaseOptions options = new BaseOptions(
          connectTimeout: CONNECT_TIMEOUT,
          receiveTimeout: RECEIVE_TIMEOUT,
          headers: {});

      dio = new Dio(options);

      // 添加错误拦截请求
      dio.interceptors.add(ErrorInterceptor());

      //TODO 添加错误上报
      //TODO 添加自动重试
      if (true) {
        dio.interceptors.add(
          RetryOnConnectionChangeInterceptor(
            retrier: Retrier(
              dio: dio,
              connectivity: Connectivity(),
            ),
          ),
        );
      }
      //TODO 添加缓存
      //TODO 添加loading
      //TODO 添加加密
      //TODO 添加轮询

      // 调试模式下需要抓包，使用代理并禁止https证书校验
      if (PROXY_ENABLE) {
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
            (client) {
          client.findProxy = (uri) {
            return "Proxy $PROXY_IP:$PROXY_PORT";
          };
          // 代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以禁用
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        };
      }
    }
  }

  void init({
    required String baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    List<Interceptor>? interceptors,
  }) {
    dio.options = dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

    if (interceptors != null && interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
  }

  // 取消请求

  void cancel(CancelToken token) {
    token ?? _cancelToken.cancel("cancelled");
  }

  // 请求头添加token
  Map<String, dynamic> getAuthorizationHeader() {
    var headers;
    // String accessToken = Global.acc;

    return headers;
  }

  // 添加cookie和cache

  static get(String path, [RequestOptions? options]) {
    return Future(() => null);
  }
}
