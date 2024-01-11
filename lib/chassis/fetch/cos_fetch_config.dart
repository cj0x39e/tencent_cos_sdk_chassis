import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch_context.dart';
import 'package:tencent_cos_sdk_chassis/chassis/utils/cos_logger.dart';

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

  /// 发生网络失败时的重试次数，默认会重试 3 次
  final int retryTimes;

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
    this.retryTimes = 3,
  });

  /// 重试次数
  int alreadyRetryTimes = 0;

  /// 记录重试次数
  increaseRetryTimes() {
    alreadyRetryTimes++;

    COSLogger.t('increaseRetryTimes: $alreadyRetryTimes');
  }

  /// 是否超过重试次数
  bool get isRetryTimesExceed => alreadyRetryTimes >= retryTimes;
}
