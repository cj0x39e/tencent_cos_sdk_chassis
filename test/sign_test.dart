import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos_plus/src/sign.dart';

void main() {
  late int startTimeMs;
  late int expiredTimeMs;
  late String secretKey;
  late String secretId;
  late String method;
  late String uriPathname;
  late Map<String, String> params;
  late Map<String, String> headers;
  late String keyTime;
  late String httpString;
  late String stringToSign;
  late String httpHeaders;
  late String httpParameters;

  setUp(() {
    startTimeMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
    expiredTimeMs = startTimeMs + 2 * 60 * 60 * 1000;
    secretKey = 'secretKey';
    secretId = 'secretId';
    params = {'Name': 'cj', 'Age': '8', 'date': '2023-02-02'};
    headers = {'AUTH': '', 'Content-Type': 'application/json'};
    method = 'POST';
    uriPathname = 'jekfjig';

    keyTime = Sign.generateKeyTime(startTimeMs, expiredTimeMs);
    (paramList: _, parameters: httpHeaders) =
        Sign.generateParamsListAndParameters(Sign.filterHeaders(headers));
    (paramList: _, parameters: httpParameters) =
        Sign.generateParamsListAndParameters(params);
    httpString = Sign.generateHttpString(
        method: method,
        uriPathname: uriPathname,
        httpParameters: httpParameters,
        httpHeaders: httpHeaders);
    stringToSign = Sign.generateStringToSign(keyTime, httpString);
  });

  test('generate key time', () {
    final keyTime = Sign.generateKeyTime(startTimeMs, expiredTimeMs);

    expect(keyTime, '${startTimeMs ~/ 1000};${expiredTimeMs ~/ 1000}');
  });

  test(
      'generate key time should throw an exception when expired time is less than start time',
      () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final end = now - 2 * 60 * 60 * 1000;

    try {
      Sign.generateKeyTime(now, end);
    } catch (e) {
      expect(e, isAssertionError);
    }
  });

  test('generate sign key', () {
    final signKey = Sign.generateSignKey(keyTime, secretKey);
    expect(signKey, 'b6b74c69ecf10928a0d2a00a4ef3f72703743251');
  });

  test('generate params keys and values with empty params', () {
    final (paramList: list, parameters: params) =
        Sign.generateParamsListAndParameters({});

    expect(list, '');
    expect(params, '');
  });

  test('generate params keys and values', () {
    final (paramList: list, parameters: paramsStr) =
        Sign.generateParamsListAndParameters(params);

    expect(list, 'age;date;name');
    expect(paramsStr, 'age=8&date=2023-02-02&name=cj');
  });

  test('generate http string', () {
    final result = Sign.generateHttpString(
        method: method,
        uriPathname: uriPathname,
        httpHeaders: httpHeaders,
        httpParameters: httpParameters);

    expect(result,
        'post\njekfjig\nage=8&date=2023-02-02&name=cj\ncontent-type=application%2Fjson\n');
  });

  test('generate string to sign', () {
    final result = Sign.generateStringToSign(keyTime, httpString);

    expect(result,
        'sha1\n1672502400;1672509600\n2b8209cd0ee3ea73800ede818422de6805a1910b\n');
  });

  test('generate signature', () {
    final result = Sign.generateSignature(stringToSign, secretKey);

    expect(result, 'f033a37930d1e70ddf942e987cf3899bbb3716df');
  });

  test('get signature without headers and params', () {
    final result = Sign(
      startTimeMs: startTimeMs,
      expiredTimeMs: expiredTimeMs,
      secretKey: secretKey,
      secretId: secretId,
      method: method,
      uriPathname: uriPathname,
    ).getSignature();

    expect(result,
        'q-sign-algorithm=sha1&q-ak=secretId&q-sign-time=1672502400;1672509600&q-key-time=1672502400;1672509600&q-header-list=&q-url-param-list=&q-signature=20b27c57d4d0eaa534d3370b972e69cd01bd569f');
  });

  test('get signature with headers and params', () {
    final result = Sign(
      startTimeMs: startTimeMs,
      expiredTimeMs: expiredTimeMs,
      secretKey: secretKey,
      secretId: secretId,
      method: method,
      uriPathname: uriPathname,
      headers: headers,
      params: params,
    ).getSignature();

    expect(result,
        'q-sign-algorithm=sha1&q-ak=secretId&q-sign-time=1672502400;1672509600&q-key-time=1672502400;1672509600&q-header-list=content-type&q-url-param-list=age;date;name&q-signature=f033a37930d1e70ddf942e987cf3899bbb3716df');
  });
}
