import 'dart:io';

class Fetch {
  final List<Future<void> Function(HttpClientRequest req, dynamic attach)>?
      reqHandlers;
  final List<Future<dynamic> Function(HttpClientResponse res, dynamic data)>?
      resHandlers;

  Fetch({this.reqHandlers, this.resHandlers});

  Future<dynamic> send(
      {required String method, required String url, dynamic attach}) async {
    HttpClient client = HttpClient();

    final req = await client.openUrl(method, Uri.parse(url));

    if (reqHandlers != null) {
      for (final handler in reqHandlers!) {
        await handler(req, attach);
      }
    }

    final res = await req.close();

    dynamic data;
    if (resHandlers != null) {
      for (final handler in resHandlers!) {
        data = await handler(res, data);
      }
    }

    return data;
  }
}
