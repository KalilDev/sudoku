import 'dart:async';
import 'dart:isolate';
import 'package:sudoku_core/sudoku_core.dart';
import '../../sudoku_configuration.dart';

class _IsolateSudokuParams {
  final int side;
  final double mask;

  _IsolateSudokuParams(this.side, this.mask);
}

class IsolateChunkedSudoku implements ChunkedSudoku {
  final Isolate _isolate;
  final ReceivePort _mainPort;
  final _IsolateSudokuParams _params;
  SendPort _isolatePort;
  StreamSubscription<dynamic> _portSubscription;
  final StreamController<ChunkedSudokuSquare> _squareController =
      StreamController();
  final Completer<SudokuState> _completer = Completer<SudokuState>();

  IsolateChunkedSudoku(this._isolate, this._mainPort, this._params);

  void _setupListener() {
    _portSubscription = _mainPort.listen((dynamic msg) {
      if (msg is SendPort) {
        _isolatePort = msg;
        _isolatePort.send(_params);
      } else {
        final chunkedMsg = msg as ChunkedSudokuPiece;
        if (chunkedMsg is ChunkedSudokuResult) {
          _completer.complete(chunkedMsg.state);
        } else {
          _squareController.add(chunkedMsg as ChunkedSudokuSquare);
        }
      }
    });
  }

  @override
  Future<void> cancel() async {
    await _portSubscription?.cancel();
    _isolate.kill(priority: Isolate.immediate);
    await _squareController.close();
    _mainPort.close();
  }

  @override
  Future<SudokuState> get onComplete => _completer.future;

  @override
  Stream<ChunkedSudokuSquare> get squares => _squareController.stream;
}

void isolateChunkedSudoku(SendPort p) {
  final port = ReceivePort();
  p.send(port.sendPort);
  port.listen((dynamic msg) {
    final sudokuMsg = msg as _IsolateSudokuParams;
    rawCreateRandomSudoku(side: sudokuMsg.side, maskRate: sudokuMsg.mask)
        .listen((piece) {
      p.send(piece);
    });
  });
}

Future<ChunkedSudoku> genRandomSudoku(
    int side, SudokuDifficulty difficulty) async {
  final port = ReceivePort();
  final isolate = await Isolate.spawn(isolateChunkedSudoku, port.sendPort);
  final params = _IsolateSudokuParams(side, difficultyMaskMap[difficulty]);
  final chunked = IsolateChunkedSudoku(isolate, port, params);
  chunked._setupListener();
  return chunked;
}
