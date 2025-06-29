class Logger {
  final String name;
  Logger(this.name);

  void info(Object? message) {
    // ignore: avoid_print
    print(message);
  }
}
