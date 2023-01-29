import 'dart:collection';
import 'dart:js_util';

import 'package:dio/dio.dart';
import 'package:sp_util/sp_util.dart';

// 缓存类
class Cache {
  Cache(this.response) : timestamp = DateTime.now().microsecondsSinceEpoch;

  Response response;
  int timestamp;

  @override
  bool operator ==(other) {
    return response.hashCode == other.hashCode;
  }

  // 将请求的uri和method以及参数作为key
  @override
  int get hashCode =>
      response.realUri.hashCode + response.requestOptions.method.hashCode;
}

class NetCacheInterceptor extends Interceptor {
  // linkedHashMap 确保迭代器顺序和对象插入时间顺序一致
  static final enable = true;

  var cache = LinkedHashMap<String, Cache>();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enable) return handler.next(options);
    final extra = options.extra;
    final key = options.uri.toString();

    // 是否刷新缓存
    bool isRefresh = extra['refresh'] == true;
    // 是否磁盘缓存(否则缓存至内存)
    bool isCacheDisk = extra['cashDisk'] == true;

    if (isRefresh) {
      // 擦除内存
      cache.remove(options.uri.path);
      // 擦除磁盘
      if (isCacheDisk) {
        await SpUtil.remove(key);
      }

      return handler.next(options);
    }

    if (extra['cacheable'] != false && options.method.toLowerCase() == 'get') {
      String _key = extra['CacheKey'] ?? key;
      var data = cache[_key];
      if (data != null) {
        // 如果内存中取到数据，且未过期，直接返回数据
        final timeDiff = DateTime.now().microsecondsSinceEpoch - data.timestamp;
        const maxAge = 5 * 60 * 1000;
        if (timeDiff < maxAge) {
          return handler.resolve(cache[_key]!.response);
        }
      }

      // 内存中没有，且开启了磁盘缓存，则继续在磁盘中查找
      if (isCacheDisk) {
        var diskData = SpUtil.getObject(_key);
        if (diskData != null) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: diskData,
          ));
        }
      }

      return handler.next(options);
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 错误状态不缓存
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 将结果缓存
    if (enable) {}
    super.onResponse(response, handler);
  }

  Future<void> _save(Response object) async {
    RequestOptions options = object.requestOptions;
    final extra = options.extra;

    // 只缓存get请求
    if (options.method.toLowerCase() == "get") {
      if (extra['cacheable'] != false) {
        final key = extra['cacheKey'] ?? options.uri.toString();

        // 写入磁盘
        if (extra['cachDisk'] == true) {
          await SpUtil.putObject(key, object.data);
        }

        // 超过缓存最大值则删除第一条缓存
        if (cache.length >= 100) {
          cache.remove(cache[cache.keys.first]);
        }

        // 写入内存
        cache[key] = Cache(object);
      }
    }
  }
}
