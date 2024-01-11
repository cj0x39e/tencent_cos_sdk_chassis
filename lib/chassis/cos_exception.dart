import 'dart:convert';
import 'dart:io';

class COSException implements Exception {
  String? message;

  COSException({this.message});

  @override
  String toString() {
    return "[COS_CHASSIS_EXCEPTION] $message";
  }

  static Future<COSException> fromResponse(HttpClientResponse? res) async {
    try {
      final body = await res?.transform(utf8.decoder).join();
      final status = res?.statusCode;

      return COSException(message: 'statusCode: $status\n\n$body');
    } catch (e) {
      return COSException(message: 'unknown exception: $e');
    }
  }
}
