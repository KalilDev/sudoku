
enum SudokuDifficulty {
  begginer,
  easy,
  medium,
  hard,
  extreme,
  impossible
}

enum StateSource {
  storage,
  random,
  storageIfPossible
}

class SudokuConfiguration {
  SudokuConfiguration._copy(this.side, this.difficulty, this.source);
  SudokuConfiguration._(this.side, int difficulty, this.source) : difficulty = SudokuDifficulty.values[difficulty];
  final int side;
  final SudokuDifficulty difficulty;
  final StateSource source;

  SudokuConfiguration newSudoku() => SudokuConfiguration._copy(side, difficulty, StateSource.random);

  factory SudokuConfiguration(int side, int difficulty) {
    assert(factorySide.contains(side));
    return SudokuConfiguration._(side, difficulty, StateSource.storageIfPossible);
  }


  static SudokuConfiguration four(int difficulty, StateSource source) => SudokuConfiguration._(4, difficulty, source);
  static SudokuConfiguration nine(int difficulty, StateSource source) => SudokuConfiguration._(9, difficulty, source);
  static SudokuConfiguration sixteen(int difficulty, StateSource source) => SudokuConfiguration._(16, difficulty, source);
  static List<SudokuConfiguration Function(int, StateSource)> factories = [four, nine, /*sixteen*/];
  static List<int> factorySide = [4, 9, /*16*/];
}