import 'dart:developer' as dev;

class CblPerformanceLogger {
   DateTime? _startTime;
  String? _operationName;
  PerformanceLogLevel _level = PerformanceLogLevel.debug;

  void setupLogger(PerformanceLogLevel level) {
    _level = level;

  }

  void start(String operationName) {
    _startTime = DateTime.now();
    _operationName = operationName;
  }

  void end(String operationName) {
    if (_startTime == null) {
      throw StateError('start() must be called before end()');
    }

    if (_operationName == operationName) {
      final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    dev.log('$operationName - Start Time: $_startTime, End Time: $endTime - Duration: ${duration.inMilliseconds} milliseconds', 
      time: DateTime.now(),
      level: _level.value,
      name: operationName,
    );
    }
  }
}

enum PerformanceLogLevel {
  off(0),
  debug(100),
  info(200),
  warning(300),
  error(400);

  const PerformanceLogLevel(this.value);

  final int value;
}