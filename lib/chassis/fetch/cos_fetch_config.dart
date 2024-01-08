import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch_context.dart';

class COSFetchConfig {
  /// 存储桶
  final String bucket;

  /// 存储对象
  final String key;

  /// 存储桶所在地域
  final String? region;

  /// 请求头
  final Map<String, String>? headers;

  /// 请求参数
  final Map<String, String>? params;

  /// 请求方法
  final String method;

  /// 签名有效期
  final int? signValidity;

  /// 请求处理函数
  final List<Future<void> Function(COSFetchContext fetchContext)>? reqHandlers;

  /// 响应处理函数
  final List<
          Future<dynamic> Function(COSFetchContext fetchContext, dynamic data)>?
      resHandlers;

  COSFetchConfig({
    required this.bucket,
    required this.key,
    required this.method,
    this.region,
    this.headers,
    this.params,
    this.reqHandlers,
    this.resHandlers,
    this.signValidity,
  });
}
