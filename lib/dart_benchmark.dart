import 'dart:async';
import 'dart:collection';

import 'package:quick_log/quick_log.dart';

/// Benchmark callback definition.
typedef benchmarkCallback = FutureOr<void> Function();

/// Dart Benchmark
class DartBenchmark {
  /// Benchmark logger.
  final Logger log;

  /// Function called before [execute], not counted in the result.
  final benchmarkCallback setup;

  /// Function called to be benchmarked.
  final benchmarkCallback execute;

  /// Function called after [execute], not counted in the result.
  final benchmarkCallback cleanup;

  /// How many times [execute] is called.
  final int count;

  /// True to run [execute] 5 times to warmup.
  final bool warmup;

  /// Initialize an instance of [DartBenchMark].
  /// A [name] for the logger and the function to be [execute]d are required.
  /// If [setup] or [cleanup] are provided they are called before and after
  /// the benchmark respectively.
  /// [execute] is called [count] times, defaults to 100.
  /// If [warmup] is true (default), [execute] is called 5 times before
  /// the benchmark starts.
  /// Call [run] to start the benchmark.
  DartBenchmark(String name, this.execute,
      {this.setup, this.cleanup, this.count = 100, this.warmup = true})
      : assert(count > 0, 'count must be greater than 0'),
        log = Logger(name);

  /// Start the benchmark.
  /// Use [log] to track down the benchmark progress.
  /// If [setup], [execute] or [cleanup] are futures, they are awaited.
  Future<BenchmarkResult> run() async {
    log.info('Start benchmarking.');

    log.fine('Running setup.');
    await setup?.call();

    if (warmup) {
      log.fine('Running 5 warmup test');
      for (var i = 0; i < 5; i++) {
        await execute();
      }
    }

    final results = <int>[];
    log.fine('Executing code $count times.');
    var stopwatch = Stopwatch();
    for (var i = 0; i < count; i++) {
      log.debug('Running test ${i + 1}/${count}');
      stopwatch.start();
      await execute();
      stopwatch.stop();
      results.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    log.fine('Running cleanup.');
    await cleanup?.call();

    log.fine('Benchmark done!');
    var r = BenchmarkResult._(results);
    log.info(r.prettify());
    return r;
  }

  /// Start the benchmark synchronously.
  /// Use [log] to track down the benchmark progress.
  /// [setup], [execute] and [cleanup], cannot return a Future.
  BenchmarkResult runSync() {
    log.info('Start benchmarking synchronously.');

    log.fine('Running setup.');
    setup?.call();

    if (warmup) {
      log.fine('Running 5 warmup test');
      for (var i = 0; i < 5; i++) {
        execute();
      }
    }

    final results = <int>[];
    final stopwatch = Stopwatch();

    log.fine('Executing code $count times.');
    for (var i = 0; i < count; i++) {
      log.debug('Running test ${i + 1}/${count}');
      stopwatch.start();
      execute();
      stopwatch.stop();
      results.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    log.fine('Running cleanup.');
    cleanup?.call();

    log.fine('Benchmark done!');
    var r = BenchmarkResult._(results);
    log.info(r.prettify());
    return r;
  }
}

/// Benchmark results
class BenchmarkResult {
  /// Raw list of time (microseconds) taken for each execution in ascending order.
  final UnmodifiableListView<int> resultsList;

  /// The average execution time in microseconds.
  double get avg => resultsList.reduce((v, e) => v + e) / resultsList.length;

  /// The peak (longest) execution time in microseconds.
  int get peak => resultsList.last;

  /// The bottom (shortest) execution time in microseconds.
  int get bottom => resultsList.first;

  BenchmarkResult._(List<int> resultsList)
      : resultsList = UnmodifiableListView(resultsList..sort());

  /// Returns a String representation of this containing [avg], [peak] and bottom.
  String prettify() {
    return '\tpeak: ${Duration(microseconds: peak)}\tbottom: ${Duration(microseconds: bottom)}\tavg: ~${Duration(microseconds: avg.round())}';
  }
}
