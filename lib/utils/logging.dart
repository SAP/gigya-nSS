import 'package:logger/logger.dart';

/// Global logger instance.
Logger nssLogger = Logger(
  printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      printTime: true),
);
