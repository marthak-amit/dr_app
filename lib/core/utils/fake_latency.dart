import 'dart:math';

final _rnd = Random(7);

/// Simulates network latency (400–800 ms by default).
Future<void> fakeLatency([int minMs = 400, int maxMs = 800]) =>
    Future<void>.delayed(Duration(milliseconds: minMs + _rnd.nextInt(maxMs - minMs + 1)));
