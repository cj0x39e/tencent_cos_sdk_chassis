import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:tencent_cos_sdk_chassis/chassis/utils/cos_logger.dart';

const validHeaders = {
  "cache-control",
  "content-disposition",
  "content-encoding",
  "content-type",
  "expires",
  "content-md5",
  "content-length",
  "host"
};

class COSSign {
  final int startTimeMs;

  final int expiredTimeMs;

  final String secretKey;

  final String secretId;

  final String method;

  final String uriPathname;

  final Map<String, String>? params;

  final Map<String, String>? headers;

  COSSign({
    required this.expiredTimeMs,
    required this.startTimeMs,
    required this.secretKey,
    required this.secretId,
    required this.method,
    required this.uriPathname,
    this.params,
    this.headers,
  })  : assert(expiredTimeMs > startTimeMs),
        assert(secretKey.isNotEmpty),
        assert(secretId.isNotEmpty),
        assert(method.isNotEmpty),
        assert(uriPathname.isNotEmpty);

  String getSignature() {
    final keyTime = generateKeyTime(startTimeMs, expiredTimeMs);
    final signKey = generateSignKey(keyTime, secretKey);
    final (paramList: urlParamList, parameters: httpParameters) =
        generateParamsListAndParameters(params ?? {});
    final (paramList: headerList, parameters: httpHeaders) =
        generateParamsListAndParameters(filterHeaders(headers ?? {}));
    final httpString = generateHttpString(
        method: method,
        uriPathname: uriPathname,
        httpParameters: httpParameters,
        httpHeaders: httpHeaders);
    final stringToSign = generateStringToSign(keyTime, httpString);
    final signature = generateSignature(stringToSign, signKey);

    final result = [
      'q-sign-algorithm=sha1',
      'q-ak=$secretId',
      'q-sign-time=$keyTime',
      'q-key-time=$keyTime',
      'q-header-list=$headerList',
      'q-url-param-list=$urlParamList',
      'q-signature=$signature'
    ].join('&');

    COSLogger.t(
        '\n<signKey>: $signKey \n<httpString>: $httpString \n<stringToSign>: $stringToSign \n<result>: $result');

    COSLogger.t(result);

    return result;
  }

  static String generateKeyTime(int startTimeMs, int expiredTimeMs) {
    assert(expiredTimeMs > startTimeMs);

    final startTimestamp = startTimeMs ~/ 1000;
    final endTimestamp = expiredTimeMs ~/ 1000;

    return '$startTimestamp;$endTimestamp';
  }

  static String generateSignKey(String keyTime, String secretKey) {
    return HMACSha1(keyTime, secretKey);
  }

  static ({String paramList, String parameters})
      generateParamsListAndParameters(Map<String, String> params) {
    final paramsEncoded = params.map((key, value) => MapEntry(
        Uri.encodeComponent(key).toLowerCase(), Uri.encodeComponent(value)));

    final keys = paramsEncoded.keys.toList()..sort();

    final paramList = keys.join(";");
    final parameters =
        keys.map((key) => '$key=${paramsEncoded[key]}').join("&");

    return (paramList: paramList, parameters: parameters);
  }

  static String generateHttpString({
    required String method,
    required String uriPathname,
    required String httpParameters,
    required String httpHeaders,
  }) {
    return '${method.toLowerCase()}\n$uriPathname\n$httpParameters\n$httpHeaders\n';
  }

  static String generateStringToSign(String keyTime, String httpString) {
    return "sha1\n$keyTime\n${hex.encode(sha1.convert(httpString.codeUnits).bytes)}\n";
  }

  static generateSignature(String stringToSign, String signKey) {
    return HMACSha1(stringToSign, signKey);
  }

  static filterHeaders(Map<String, String> headers) {
    Map<String, String> res = {};

    for (final key in headers.keys) {
      if (validHeaders.contains(key.toLowerCase()) ||
          key.toLowerCase().startsWith("x")) {
        if (key == "content-length" && headers["content-length"] == "0") {
          continue;
        }

        res[key] = headers[key] ?? '';
      }
    }

    return res;
  }

  // ignore: non_constant_identifier_names
  static String HMACSha1(String msg, String key) {
    return hex.encode(Hmac(sha1, key.codeUnits).convert(msg.codeUnits).bytes);
  }
}
