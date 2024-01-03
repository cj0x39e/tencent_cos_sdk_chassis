const defaultExpiredTime = 2 * 60 * 60 * 1000;

class Sign {
  /// [expiredTime] in milliseconds with default value is 2 hours
  final int expiredTime;

  Sign({this.expiredTime = defaultExpiredTime});

  generateKeyTime() {
    final startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60;
    final endTimestamp = expiredTime ~/ 1000;
    return '$startTimestamp;$endTimestamp';
  }
}
