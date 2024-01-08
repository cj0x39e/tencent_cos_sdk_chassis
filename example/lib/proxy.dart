import 'package:native_flutter_proxy/custom_proxy.dart';
import 'package:native_flutter_proxy/native_proxy_reader.dart';

class MyProxy {
  static CustomProxy? customProxy;

  static startProxy() async {
    try {
      ProxySetting settings = await NativeProxyReader.proxySetting;

      final enabled = settings.enabled;
      final host = settings.host;
      final port = settings.port;

      if (enabled && host != null) {
        customProxy = CustomProxy(ipAddress: host, port: port);

        customProxy?.enable();
      }
    } catch (e) {
      // nothing
    }
  }

  static stopProxy() {
    customProxy?.disable();
  }

  static String? getProxyInfo() {
    return customProxy?.toString();
  }
}
