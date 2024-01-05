import 'package:tencent_cos_plus/src/cos_config.dart';
import 'package:tencent_cos_plus/src/memory_cache.dart';
import 'package:tencent_cos_plus/src/sign.dart';

class COSClient {
  final COSConfig config;
  MemoryCache? memoryCache;

  COSClient({required this.config});

  /// 获取对象访问 url
  /// 参考文档： https://cloud.tencent.com/document/product/436/57420
  /// [sign] 链接是否需要带上签名
  /// [cache] 获取的链接是否缓存，目前带签名的链接默认开启缓存，在签名有效期内不会重新生成
  String getObjectUrl({
    required String bucket,
    required String key,
    String? region,
    bool? sign,
    bool cache = true,
  }) {
    region ??= config.region;

    final endPoint = config.getEndpoint(bucket);
    String url = '$endPoint$key';

    if (sign == true) {
      if (cache == true) {
        _initMemoryCache();

        final cacheKey = '$region-$bucket-$key';
        final cacheValue = memoryCache!.getValue(cacheKey);

        if (cacheValue != null) {
          return cacheValue;
        } else {
          final sign = _getSign(key: key, method: 'GET');
          final result = '$url?${sign.getSignature()}';

          // let the expiration time earlier than the sign, to avoid
          // the sign expiring when arrived the server.
          final expired = sign.expiredTimeMs - 1000 * 60;

          memoryCache!.addValue(cacheKey, result, expired);

          return result;
        }
      } else {
        final sign = getAuthorization(
          key: key,
          method: 'GET',
        );

        return '$url?$sign';
      }
    } else {
      return url;
    }
  }

  /// 获取签名字符串
  /// 参考文档： https://cloud.tencent.com/document/product/436/35651
  /// [signValidity] 签名有效期，单位 ms
  String getAuthorization({
    required String key,
    required String method,
    int? signValidity,
  }) {
    return _getSign(key: key, method: method, signValidity: signValidity)
        .getSignature();
  }

  getCurrentDateTime() => DateTime.now();

  void _initMemoryCache() {
    memoryCache ??= MemoryCache();
  }

  Sign _getSign({
    required String key,
    required String method,
    int? signValidity,
  }) {
    final startTimeMs = getCurrentDateTime().millisecondsSinceEpoch;
    final expiredTimeMs = startTimeMs + (signValidity ?? config.signValidity);

    return Sign(
        startTimeMs: startTimeMs,
        expiredTimeMs: expiredTimeMs,
        secretKey: config.secretKey,
        secretId: config.secretId,
        method: method,
        uriPathname: key);
  }
}
