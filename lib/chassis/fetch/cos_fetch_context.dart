import 'dart:io';

import 'package:tencent_cos_sdk_chassis/chassis/utils/date_time_helper.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class COSFetchContext {
  /// 请求配置
  final COSFetchConfig fetchConfig;

  /// COS 配置
  final COSConfig config;

  /// 请求实例
  HttpClientRequest? req;

  /// 响应实例
  HttpClientResponse? res;

  COSFetchContext(
      {this.req, required this.fetchConfig, this.res, required this.config});

  String get regionFormatted => fetchConfig.region ?? config.region;

  String get keyFormatted => !fetchConfig.key.startsWith('/')
      ? '/${fetchConfig.key}'
      : fetchConfig.key;

  String get urlParamsFormatted {
    String urlParams = '';

    if (fetchConfig.params != null && fetchConfig.params!.isNotEmpty) {
      urlParams = fetchConfig.params!.keys
          .map((e) => '$e=${fetchConfig.params![e] ?? ""}')
          .join('&');

      if (urlParams.isNotEmpty) {
        urlParams = "?$urlParams";
      }
    }

    return urlParams;
  }

  String get url {
    return '${config.getEndpoint(fetchConfig.bucket, regionFormatted)}$keyFormatted$urlParamsFormatted';
  }

  String getSign() {
    final startTimeMs = DateTimeHelper.now.millisecondsSinceEpoch;
    final expiredTimeMs =
        startTimeMs + (fetchConfig.signValidity ?? config.signValidity);

    return COSSign(
            expiredTimeMs: expiredTimeMs,
            startTimeMs: startTimeMs,
            secretKey: config.secretKey,
            secretId: config.secretId,
            method: fetchConfig.method,
            uriPathname: fetchConfig.key,
            headers: fetchConfig.headers,
            params: fetchConfig.params)
        .getSignature();
  }
}
