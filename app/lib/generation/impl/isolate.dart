import 'dart:isolate';

import 'package:app/generation/impl/isolate_local.dart';

import 'data.dart';

class IsolateStartMessage {
  final SendPort bus;
  final int sideSqrt;
  final SudokuDifficulty difficulty;

  IsolateStartMessage(this.bus, this.sideSqrt, this.difficulty);
}

void isolateStreamingMain(IsolateStartMessage args) {
  generateSudokuStreamingIsolateLocal(args.sideSqrt, args.difficulty).listen(
    args.bus.send,
    onDone: () {
      // TODO: is this needed?
      Isolate.current.kill(
        priority: Isolate.immediate,
      );
    },
  );
}

void isolateFutureMain(IsolateStartMessage args) {
  generateSudokuIsolateLocal(
    args.sideSqrt,
    args.difficulty,
  ).then(args.bus.send).then((_) {
    // TODO: is this needed?
    Isolate.current.kill(
      priority: Isolate.immediate,
    );
  });
}

void isolateMain(IsolateStartMessage args) {
  generateSudokuIsolateLocal(args.sideSqrt, args.difficulty);
}

Stream<SudokuGenerationEvent> generateSudokuStreaming(
  int sideSqrt,
  SudokuDifficulty difficulty,
) async* {
  final receiveBus = ReceivePort();
  final isolate = await Isolate.spawn<IsolateStartMessage>(
    isolateStreamingMain,
    IsolateStartMessage(receiveBus.sendPort, sideSqrt, difficulty),
  );
  await for (final isolateE in receiveBus) {
    final e = isolateE as SudokuGenerationEvent;
    yield e;
    if (e is SudokuGenerationFinished) {
      break;
    }
  }
  isolate.kill(priority: Isolate.immediate);
}

Future<SolvedAndChallengeBoard> generateSudoku(
  int sideSqrt,
  SudokuDifficulty difficulty,
) async {
  final receiveBus = ReceivePort();
  final isolate = await Isolate.spawn<IsolateStartMessage>(
    isolateFutureMain,
    IsolateStartMessage(receiveBus.sendPort, sideSqrt, difficulty),
  );
  final isolateR = await receiveBus.first;
  final r = isolateR as SolvedAndChallengeBoard;
  isolate.kill(priority: Isolate.immediate);
  return r;
}
