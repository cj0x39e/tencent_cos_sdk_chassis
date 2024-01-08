class DateTimeHelper {
  static DateTime? _now;

  static DateTime get now {
    if (_now == null) {
      return DateTime.now();
    } else {
      return _now!;
    }
  }

  static set now(DateTime? value) {
    _now = value;
  }
}
