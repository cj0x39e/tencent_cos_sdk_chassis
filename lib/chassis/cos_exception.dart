import 'dart:convert';
import 'dart:io';

class COSException implements Exception {
  HttpClientResponse? res;

  String? message;

  COSException({this.res, this.message});

  @override
  String toString() {
    if (res != null) {
      final statusCode = res?.statusCode ?? '';
      final msg = res?.transform(utf8.decoder).join('');

      return "[COS_CHASSIS_EXCEPTION]\nstatusCode:$statusCode\n\n$msg";
    } else {
      return "[COS_CHASSIS_EXCEPTION] $message";
    }
  }
}
