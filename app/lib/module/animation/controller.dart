import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'data.dart';
import 'sudoku_animation_db.dart';

class _SudokuAnimationDbController extends SubcontrollerBase<
    SudokuAnimationController, _SudokuAnimationDbController> {
  final EventNotifier<SelectionAnimationOptions> _didChangeSelection =
      EventNotifier();
  final EventNotifier<TextAnimationOptions> _didChangeText = EventNotifier();
  final EventNotifier<AnimationSpeed> _didChangeSpeed = EventNotifier();
  late final ValueListenable<SudokuAnimationDb?> _db;
  _SudokuAnimationDbController.alreadyOpen(SudokuAnimationDb db) {
    _db = db.asValueListenable;
  }
  _SudokuAnimationDbController.open() {
    _db = sudokuAnimationDbOpen()
        .toValueListenable()
        .map((r) => r.hasData ? r.requireData : null);
  }
  ValueListenable<SelectionAnimationOptions?> get didChangeSelection =>
      _didChangeSelection.view();
  ValueListenable<TextAnimationOptions?> get didChangeText =>
      _didChangeText.view();
  ValueListenable<AnimationSpeed?> get didChangeSpeed => _didChangeSpeed.view();

  late final ValueListenable<Maybe<AnimationOptions>> _initialAnimationOptions =
      _db.view().bind((db) => db == null
          ? const Maybe<AnimationOptions>.none().asValueListenable
          : sudokuAnimationDbRead(db).toValueListenable(eager: true).map((r) =>
              r.hasData
                  ? Just(r.requireData ?? defaultAnimationOptions)
                  : const None()));

  ValueListenable<AnimationOptions> get animationOptions =>
      _initialAnimationOptions.bind(
        (initialOptions) => initialOptions.visit(
          just: (loadedInitial) =>
              AnimationOptions.new.curry.asValueListenable >>
              didChangeSelection.withDefault(loadedInitial.e0) >>
              didChangeText.withDefault(loadedInitial.e1) >>
              didChangeSpeed.withDefault(loadedInitial.e2),
          none: () => defaultAnimationOptions.asValueListenable,
        ),
      );

  late final changeSelection = _didChangeSelection.add;
  late final changeText = _didChangeText.add;
  late final changeSpeed = _didChangeSpeed.add;

  void changeAnimationOptions(AnimationOptions options) {
    final current = animationOptions.value;
    if (current.e0 != options.e0) {
      changeSelection(options.e0);
    }
    if (current.e1 != options.e1) {
      changeText(options.e1);
    }
    if (current.e2 != options.e2) {
      changeSpeed(options.e2);
    }
  }

  void _onChangeSelection(SelectionAnimationOptions options) {
    sudokuAnimationDbModifySelection(_db.value!, options);
  }

  void _onChangeText(TextAnimationOptions options) {
    sudokuAnimationDbModifyText(_db.value!, options);
  }

  void _onChangeSpeed(AnimationSpeed speed) {
    sudokuAnimationDbModifySpeed(_db.value!, speed);
  }

  void init() {
    super.init();
    // ensure it is kicked off
    _initialAnimationOptions.listen(() {});
    _didChangeSelection.viewNexts().tap(_onChangeSelection);
    _didChangeText.viewNexts().tap(_onChangeText);
    _didChangeSpeed.viewNexts().tap(_onChangeSpeed);
  }

  void dispose() {
    IDisposable.disposeAll([
      _initialAnimationOptions,
      _didChangeSelection,
      _didChangeText,
      _didChangeSpeed,
    ]);
    sudokuAnimationDbClose(_db.value!);
    super.dispose();
  }
}

class SudokuAnimationController
    extends ControllerBase<SudokuAnimationController> {
  final _SudokuAnimationDbController _db;

  SudokuAnimationController.alreadyOpen(SudokuAnimationDb db)
      : _db = ControllerBase.create(
            () => _SudokuAnimationDbController.alreadyOpen(db));

  SudokuAnimationController.open()
      : _db = ControllerBase.create(() => _SudokuAnimationDbController.open());

  ValueListenable<AnimationOptions> get animationOptions =>
      _db.animationOptions;
  ValueListenable<SelectionAnimationOptions> get selectionAnimationOptions =>
      animationOptions.map((opts) => opts.e0);
  ValueListenable<TextAnimationOptions> get textAnimationOptions =>
      animationOptions.map((opts) => opts.e1);
  ValueListenable<AnimationSpeed> get animationSpeed =>
      animationOptions.map((opts) => opts.e2);

  late final changeAnimationOptions = _db.changeAnimationOptions;
  late final changeSelection = _db.changeSelection;
  late final changeText = _db.changeText;
  late final changeSpeed = _db.changeSpeed;

  void init() {
    super.init();
    addSubcontroller(_db);
  }

  void dispose() {
    disposeSubcontroller(_db);
    super.dispose();
  }
}
