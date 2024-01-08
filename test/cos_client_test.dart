import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos_sdk_chassis/src/utils/date_time_helper.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

void main() {
  late COSConfig config;
  late COSClient client;

  setUp(() {
    DateTimeHelper.now = DateTime.utc(2023, 1, 1, 0, 0, 0, 0, 0);
  });

  setUp(() {
    config = COSConfig(
      secretId: 'secretId',
      secretKey: 'secretKey',
      appid: 'appid',
      region: 'region',
    );
    client = COSClient(config: config);
  });

  test('getAuthorization', () {
    final result = client.getAuthorization(key: '/xx.jpg', method: 'GET');
    expect(result,
        'q-sign-algorithm=sha1&q-ak=secretId&q-sign-time=1672531200;1672532100&q-key-time=1672531200;1672532100&q-header-list=&q-url-param-list=&q-signature=1f6bd6d85154a8d01d43fca4f51afc6e99f8b058');
  });

  group('getObjectUrl', () {
    test('without sign', () {
      final result = client.getObjectUrl(
        bucket: 'bucket',
        key: '/xx.jpg',
      );
      expect(result, 'https://bucket.cos.region.myqcloud.com/xx.jpg');
    });

    test('with sign', () {
      final result =
          client.getObjectUrl(bucket: 'bucket', key: '/xx.jpg', sign: true);
      expect(result,
          'https://bucket.cos.region.myqcloud.com/xx.jpg?q-sign-algorithm=sha1&q-ak=secretId&q-sign-time=1672531200;1672532100&q-key-time=1672531200;1672532100&q-header-list=&q-url-param-list=&q-signature=1f6bd6d85154a8d01d43fca4f51afc6e99f8b058');
    });

    test('with cache', () {
      final client = COSClient(config: config);
      final firstCall = client.getObjectUrl(
        bucket: 'bucket',
        key: '/xx.jpg',
        sign: true,
      );
      final secondCall = client.getObjectUrl(
        bucket: 'bucket',
        key: '/xx.jpg',
        sign: true,
      );

      expect(firstCall, secondCall);
    });

    test('with cache but the cache is expired', () {
      DateTimeHelper.now = null;

      final client = COSClient(
          config: COSConfig(
              secretId: 'secretId',
              secretKey: 'secretKey',
              appid: 'appid',
              region: 'region',
              signValidity: 1000));

      final firstCall = client.getObjectUrl(
        bucket: 'bucket',
        key: '/xx.jpg',
        sign: true,
      );

      return Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final secondCall = client.getObjectUrl(
          bucket: 'bucket',
          key: '/xx.jpg',
          sign: true,
        );

        expect(firstCall == secondCall, isFalse);
      });
    });

    test('without cache', () {
      DateTimeHelper.now = null;
      final client = COSClient(config: config);
      final firstCall = client.getObjectUrl(
          bucket: 'bucket', key: '/xx.jpg', sign: true, cache: false);
      return Future.delayed(const Duration(seconds: 1)).then((value) {
        final secondCall = client.getObjectUrl(
            bucket: 'bucket', key: '/xx.jpg', sign: true, cache: false);

        expect(firstCall == secondCall, isFalse);
      });
    });
  });
}
