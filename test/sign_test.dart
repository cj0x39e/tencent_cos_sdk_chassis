import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos_plus/src/sign.dart';

void main() {
  test('running generateKeyTime with default expired time', () {
    final sign = Sign();
    expect(sign.generateKeyTime(), '1');
  });
}
