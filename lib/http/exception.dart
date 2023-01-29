// 错误处理类

// http成功状态码
import 'package:dio/dio.dart';

const HTTP_CODE_OK = 200;

// 业务成功状态码
const BIZ_CODE_OK = 0;

class AppException implements Exception {
  late final String _message;
  late final int _code;

  AppException([this._code = BIZ_CODE_OK, this._message = '']);

  @override
  String toString() {
    return "$_code:$_message";
  }

  factory AppException.create(DioError e) {
    switch (e.type) {
      case DioErrorType.cancel:
        return BadRequestException(-1, '请求取消');
      case DioErrorType.connectTimeout:
        return BadRequestException(-1, '连接超时');
      case DioErrorType.sendTimeout:
        return BadRequestException(-1, '请求超时');
      case DioErrorType.receiveTimeout:
        return BadRequestException(-1, '服务器响应超时');
      case DioErrorType.response:
        {
          try {
            return _httpHandle(e.response?.statusCode ?? 0);
          } on Exception catch (_) {
            return AppException(-1, '未知错误');
          }
        }

      default:
        return BadRequestException(-1, '请求取消');
    }
  }

  // http 错误处理
  _httpHandle([int code = BIZ_CODE_OK]) {
    switch (code) {
      case 400:
        return BadRequestException(-1, '客户端请求语法错误');
      case 401:
        return BadRequestException(-1, '未登录或登录已失效');
      case 403:
        return BadRequestException(-1, '权限认证失败,服务器拒绝执行');
      case 404:
        return BadRequestException(-1, '访问的资源不存在');
      case 405:
        return BadRequestException(-1, '请求方法被禁止');
      case 500:
        return BadRequestException(-1, '服务器内部错误');
      case 501:
      case 502:
        return BadRequestException(-1, '无效的请求');
      case 503:
        return BadRequestException(-1, '系统正在维护,请稍后再试');
      case 505:
        return BadRequestException(-1, '不支持的HTTP协议');
      default:
        return BadRequestException(-1, '未知错误');
    }
  }

  // 业务逻辑错误处理

  // http 错误处理
  _bizHandle([int code = BIZ_CODE_OK]) {
    switch (code) {
      case 400:
        return BadRequestException(-1, '请求语法错误');
      case 401:
        return BadRequestException(-1, '未登录或登录已失效');
      case 403:
        return BadRequestException(-1, '服务器拒绝执行');
      case 404:
        return BadRequestException(-1, '访问的资源不存在');
      case 405:
        return BadRequestException(-1, '请求方式不合法');
      case 500:
        return BadRequestException(-1, '服务器内部错误');
      case 502:
        return BadRequestException(-1, '无效的请求');
      case 503:
        return BadRequestException(-1, '服务器正在维护,请稍后再试');
      case 505:
        return BadRequestException(-1, '不支持的HTTP协议请求');
      default:
        return BadRequestException(-1, '未知错误');
    }
  }
}

// 请求阶段错误
class BadRequestException extends AppException {
  BadRequestException([int code = BIZ_CODE_OK, String message = ''])
      : super(code, message);
}
