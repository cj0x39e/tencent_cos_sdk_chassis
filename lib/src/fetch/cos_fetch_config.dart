import 'package:tencent_cos_sdk_chassis/src/utils/date_time_helper.dart';
import 'package:tencent_cos_sdk_chassis/src/utils/sign.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class COSFetchConfig {
  final COSConfig config;
  final String bucket;
  final String key;
  final String? region;
  final Map<String, String>? headers;
  final Map<String, String>? params;

  COSFetchConfig(
      {required this.config,
      required this.bucket,
      required this.key,
      this.region,
      this.headers,
      this.params});

  String get regionFormatted => region ?? config.region;

  String get keyFormatted => !key.startsWith('/') ? '/$key' : key;

  String get urlParamsFormatted {
    String urlParams = '';

    if (params != null && params!.isNotEmpty) {
      urlParams = params!.keys.map((e) => '$e=${params![e] ?? ""}').join('&');

      if (urlParams.isNotEmpty) {
        urlParams = "?$urlParams";
      }
    }

    return urlParams;
  }

  String get url {
    return '${config.getEndpoint(bucket, regionFormatted)}$keyFormatted$urlParamsFormatted';
  }

  String getSign({
    required String method,
    int? signValidity,
  }) {
    final startTimeMs = DateTimeHelper.now.millisecondsSinceEpoch;
    final expiredTimeMs = startTimeMs + (signValidity ?? config.signValidity);

    return Sign(
            expiredTimeMs: expiredTimeMs,
            startTimeMs: startTimeMs,
            secretKey: config.secretKey,
            secretId: config.secretId,
            method: method,
            uriPathname: key)
        .getSignature();
  }
}
