import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class Utils {
  // ignore: non_constant_identifier_names
  static String HMACSha1(String msg, String key) {
    return hex.encode(Hmac(sha1, key.codeUnits).convert(msg.codeUnits).bytes);
  }
}
