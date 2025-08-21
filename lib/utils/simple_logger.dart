import 'dart:developer' as developer;

class Logger {
  final String name;
  Logger(this.name);

  void info(Object? message) {
    developer.log(message?.toString() ?? '', name: name);
  }
}
