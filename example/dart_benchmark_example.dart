import 'dart:async';

import 'package:dart_benchmark/dart_benchmark.dart';

Future<void> main() async {
  await DartBenchmark('Slow Benchmark', () {
    return slowThingy();
  }, count: 3, warmup: false)
      .run(); // If you want to run synchronously use runSync.
}

Future<void> slowThingy() async {
  await Future.delayed(Duration(seconds: 1));
}