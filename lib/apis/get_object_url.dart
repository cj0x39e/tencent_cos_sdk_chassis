import 'package:tencent_cos_sdk_chassis/chassis/utils/date_time_helper.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

extension COSGetObjectUrl on COSClient {
  /// 获取对象访问 url
  /// 参考文档： https://cloud.tencent.com/document/product/436/57420
  /// [sign] 链接是否需要带上签名
  /// [cache] 获取的链接是否缓存，目前带签名的链接默认开启缓存，在签名有效期内不会重新生成
  /// [signValidity] 签名有效期，单位 ms
  String getObjectUrl({
    required String bucket,
    required String key,
    String? region,
    bool? sign,
    bool cache = true,
    int? signValidity,
  }) {
    region ??= config.region;

    final endPoint = config.getEndpoint(bucket, region);
    String url = '$endPoint$key';

    getCOSSign() {
      final startTimeMs = DateTimeHelper.now.millisecondsSinceEpoch;
      final expiredTimeMs = startTimeMs + (signValidity ?? config.signValidity);

      return COSSign(
          startTimeMs: startTimeMs,
          expiredTimeMs: expiredTimeMs,
          secretKey: config.secretKey,
          secretId: config.secretId,
          method: 'GET',
          uriPathname: key);
    }

    if (sign == true) {
      if (cache == true) {
        final cacheKey = '$region-$bucket-$key';
        final cacheValue = memoryCache.getValue(cacheKey);

        if (cacheValue != null) {
          return cacheValue;
        } else {
          final cosSign = getCOSSign();

          final result = '$url?${cosSign.getSignature()}';

          // let the expiration time earlier than the sign, to avoid
          // the sign expiring when arrived the server.
          final expired = cosSign.expiredTimeMs - 1000 * 60;

          memoryCache.addValue(cacheKey, result, expired);

          return result;
        }
      } else {
        final cosSign = getCOSSign();

        return '$url?${cosSign.getSignature()}';
      }
    } else {
      return url;
    }
  }
}
