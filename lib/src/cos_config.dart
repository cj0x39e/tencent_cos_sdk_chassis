class COSConfig {
  /// [secretKey] 从腾讯云控制台获取。
  final String secretKey;

  /// [secretId] 从腾讯云控制台获取。
  final String secretId;

  /// [appid] 从腾讯云控制台获取。
  final String appid;

  /// 默认的 [region]，调用具体方法时不指定则会使用。
  final String region;

  /// 请求协议，默认使用 https。
  final String scheme;

  /// 签名的有限期，单位为毫秒，默认为 900 秒
  final int signValidity;

  COSConfig(
      {required this.appid,
      required this.secretKey,
      required this.secretId,
      required this.region,
      this.scheme = 'https',
      this.signValidity = 900000})
      : assert(secretKey.isNotEmpty),
        assert(secretId.isNotEmpty),
        assert(appid.isNotEmpty);

  /// 获取接入点
  /// [bucket] 存储桶名称
  /// [regionValue] 地域名称，默认使用 [region]
  String getEndpoint(String bucket, String? regionValue) =>
      '$scheme://$bucket.cos.${regionValue ?? region}.myqcloud.com';
}
