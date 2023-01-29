import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

// 网络断开时，监听网络，网络恢复时重连。
class RetryOnConnectionChangeInterceptor extends Interceptor {
  late final Retrier retrier;

  RetryOnConnectionChangeInterceptor({
    required this.retrier,
  });

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        return retrier.schedule(err.requestOptions);
      } catch (e) {
        return e;
      }
    }
    return err;
  }

  // 重试条件
  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.connectTimeout &&
        err.error != null &&
        err.error is SocketException;
  }
}

class Retrier {
  late final Dio dio;
  late final Connectivity connectivity;

  Retrier({required this.dio, required this.connectivity});

  Future<Response> schedule(RequestOptions options) async {
    late StreamSubscription subscription;
    final completer = Completer<Response>();

    subscription = connectivity.onConnectivityChanged.listen((event) {
      subscription.cancel();
      completer.complete(dio.request(
        options.path,
        cancelToken: options.cancelToken,
        data: options.data,
        onReceiveProgress: options.onReceiveProgress,
        onSendProgress: options.onSendProgress,
        queryParameters: options.queryParameters,
        options: options as dynamic,
      ));
    });

    return completer.future;
  }
}
