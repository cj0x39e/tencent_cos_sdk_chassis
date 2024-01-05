import 'dart:convert';
import 'dart:io';
import 'package:tencent_cos_plus/src/fetch/cos_fetch_config.dart';
import 'package:xml/xml.dart';

import 'package:tencent_cos_plus/src/cos_exception.dart';
import 'package:tencent_cos_plus/src/fetch/fetch.dart';

class COSFetch {
  late Fetch fetch;

  COSFetch() {
    fetch = Fetch(
        reqHandlers: [reqAddingSign, reqAddingHeaders],
        resHandlers: [resCommonHandler]);
  }

  Future<void> delete(COSFetchConfig config) async {
    return fetch.send(method: 'DELETE', url: config.url);
  }

  Future<void> reqAddingHeaders(HttpClientRequest req, dynamic attach) async {
    final config = attach as COSFetchConfig;

    config.headers?.forEach((key, value) {
      req.headers.add(key, value);
    });
  }

  Future<void> reqAddingSign(HttpClientRequest req, dynamic attach) async {
    final config = attach as COSFetchConfig;

    req.headers.add('Authorization', config.getSign(method: req.method));
  }

  Future<dynamic> resCommonHandler(HttpClientResponse res, dynamic data) async {
    String content = await res.transform(utf8.decoder).join("");

    if (res.statusCode != 200 || res.statusCode != 204) {
      throw COSException(res.statusCode, content);
    } else {
      if (res.statusCode == 200) {
        return XmlDocument.parse(content);
      }
    }
  }
}
