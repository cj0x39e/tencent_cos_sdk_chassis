import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos_sdk_chassis/src/utils/sign.dart';

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
  late String signKey;

  setUp(() {
    startTimeMs =
        DateTime.utc(2023, 1, 1, 0, 0, 0, 0, 0).millisecondsSinceEpoch;
    expiredTimeMs = startTimeMs + 2 * 60 * 60 * 1000;
    secretKey = 'secretKey';
    secretId = 'secretId';
    params = {'Name': 'cj', 'Age': '8', 'date': '2023-02-02'};
    headers = {'AUTH': '', 'Content-Type': 'application/json'};
    method = 'GET';
    uriPathname = '/jekfjig';

    keyTime = Sign.generateKeyTime(startTimeMs, expiredTimeMs);
    signKey = Sign.generateSignKey(keyTime, secretKey);
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
    expect(signKey, '2eac9aeab28825d92da6c608a81bf20c4c4d4f51');
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

  test('generate http string without headers and params', () {
    final result = Sign.generateHttpString(
        method: method,
        uriPathname: uriPathname,
        httpHeaders: '',
        httpParameters: '');

    expect(result, 'get\n/jekfjig\n\n\n');
  });

  test('generate http string', () {
    final result = Sign.generateHttpString(
        method: method,
        uriPathname: uriPathname,
        httpHeaders: httpHeaders,
        httpParameters: httpParameters);

    expect(result,
        'get\n/jekfjig\nage=8&date=2023-02-02&name=cj\ncontent-type=application%2Fjson\n');
  });

  test('generate string to sign', () {
    final result = Sign.generateStringToSign(keyTime, httpString);

    expect(result,
        'sha1\n1672531200;1672538400\nc21d55c1472b7aa05ba5a54fec4e7fbf0384093c\n');
  });

  test('generate signature', () {
    final result = Sign.generateSignature(stringToSign, signKey);

    expect(result, '056c0f0a36154290a595c0d01fa7a3a28f4d69c1');
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
        'q-sign-algorithm=sha1&q-ak=secretId&q-sign-time=1672531200;1672538400&q-key-time=1672531200;1672538400&q-header-list=&q-url-param-list=&q-signature=40e9b425dcb3873edcf2de31920b5e491bdb3f58');
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
        'q-sign-algorithm=sha1&q-ak=secretId&q-sign-time=1672531200;1672538400&q-key-time=1672531200;1672538400&q-header-list=content-type&q-url-param-list=age;date;name&q-signature=056c0f0a36154290a595c0d01fa7a3a28f4d69c1');
  });
}
