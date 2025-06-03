import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('APP_LOG: $message');
      if (error != null) {
        print('APP_ERROR: $error');
      }
      if (stackTrace != null) {
        print('APP_STACKTRACE: $stackTrace');
      }
    }
    // In production, you might want to send logs to a service like Sentry or Firebase Crashlytics
  }
}