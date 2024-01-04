import 'package:tencent_cos_plus/src/cos_config.dart';
import 'package:tencent_cos_plus/src/sign.dart';

class COSClient {
  final COSConfig config;

  COSClient({required this.config});

  /// 获取对象访问 url
  /// 参考文档： https://cloud.tencent.com/document/product/436/57420
  String getObjectUrl({
    required String bucket,
    required String key,
    String? region,
    bool? sign,
  }) {
    region ??= config.region;

    final endPoint = config.getEndpoint(bucket);
    String url = '$endPoint$key';

    if (sign == true) {
      final sign = getAuthorization(key: key, method: 'GET');
      return '$url?$sign';
    } else {
      return url;
    }
  }

  /// 获取签名字符串
  /// 参考文档： https://cloud.tencent.com/document/product/436/35651
  String getAuthorization({
    required String key,
    required String method,
    int? signValidity,
  }) {
    return _getSign(key: key, method: method, signValidity: signValidity)
        .getSignature();
  }

  Sign _getSign({
    required String key,
    required String method,
    int? signValidity,
  }) {
    final startTimeMs = DateTime.now().millisecondsSinceEpoch;
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
