// lib/core/utils/logger.dart
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:spaceverse/constants.dart';
// import 'package:spaceverse/app/constants/app_constants.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: AppConstants.isDebugMode ? Level.debug : Level.info,
    output: MultiOutput([
      ConsoleOutput(),
      if (!AppConstants.isDebugMode) FileOutput(),
    ]),
  );

  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void v(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}

class FileOutput extends LogOutput {
  late IOSink _sink;
  late File _file;

  @override
  Future<void> init() async {
    super.init();
    _file = File('logs/app.log');
    _sink = _file.openWrite(mode: FileMode.append);
  }

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      _sink.writeln('${DateTime.now().toIso8601String()}: $line');
    }
  }

  @override
  Future<void> destroy() async {
    _sink.close();
    super.destroy();
  }
}