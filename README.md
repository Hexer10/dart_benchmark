A simple benchmarking library for Dart.

## Usage

A simple usage example:

```dart
Future<void> main() async {
  await DartBenchmark('Slow Benchmark', () {
    return slowThingy();
  }, count: 3, warmup: false)
      .run(); // If you want to run synchronously use runSync.
}

Future<void> slowThingy() async {
  await Future.delayed(Duration(seconds: 1));
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Hexer10/dart_benchmark/issues
