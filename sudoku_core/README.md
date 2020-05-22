A library with the core utilities for the Sudoku Flutter app.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:sudoku_core/sudoku_core.dart';

main() {
  BidimensionalList<int> initialState = createRandomSudoku();
  SudokuState state = SudokuState(side: 9, initialState: initialState);
  print(state.state);
}
```

## Features and bugs

BidimensionalList and SudokuState are the main features of this library. They are tested, so no bugs hopefully.
More tests and functionality will be added.