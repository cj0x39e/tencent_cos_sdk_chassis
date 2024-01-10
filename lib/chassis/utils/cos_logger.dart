import 'package:logger/logger.dart';

class COSLogger {
  static final logger = Logger(
      printer: PrettyPrinter(
          methodCount: 0, // Number of method calls to be displayed
          errorMethodCount:
              8, // Number of method calls if stacktrace is provided
          lineLength: 80, // Width of the output
          colors: true, // Colorful log messages
          noBoxingByDefault: true,
          printEmojis: true, // Print an emoji for each log message
          printTime: false // Should each log print contain a timestamp
          ));
  static Level level = Level.info;

  static String getMessage(String message, String level) {
    return '[COS_CHASSIS $level ${DateTime.now().toLocal()}]: $message';
  }

  static void t(dynamic message) {
    logger.t(getMessage(message.toString(), 'trace'));
  }

  static void i(dynamic message) {
    logger.i(getMessage(message.toString(), 'info'));
  }
}
