import 'dart:collection';

class BidimensionalList<T> extends ListBase<List<T>> {
  int _resizeCounter = 0;
  List<T> _underlyingList;
  int _x;
  int _y;
  final bool canMutate;
  BidimensionalList._(
      List<T> underlyingList, int width, int height, bool canMutate)
      : assert(underlyingList != null && width != null),
        assert(underlyingList.length == width * (height ?? width)),
        assert(canMutate != null),
        _x = width,
        _y = height ?? width,
        _underlyingList = underlyingList,
        canMutate = canMutate;

  factory BidimensionalList.view(List<T> underlyingList, int width,
          {int height}) =>
      BidimensionalList._(underlyingList, width, height, false);

  factory BidimensionalList.view2d(List<List<T>> subject, {bool canMutate = false}) {
    final width = subject.first.length;
    final height = subject.length;
    assert(subject.every((row) => row.length == width));
    final list = List<T>(width*height);
    for (var i = 0; i < height; i++) {
      list.setRange(i*width, (i+1)*width, subject[i]);
    }
    return BidimensionalList._(list, width, height, canMutate);
  }

  factory BidimensionalList(int width, {bool canMutate = false, int height}) =>
      BidimensionalList._(
          List<T>(width * (height ?? width)), width, height, canMutate);

  factory BidimensionalList.filled(int width, T fill,
          {bool canMutate = false, int height}) =>
      BidimensionalList._(List<T>.filled(width * (height ?? width), fill),
          width, height, canMutate);

  factory BidimensionalList.generate(int width, T generator(int x, int y),
      {bool canMutate = false, int height}) {
    height ??= width;
    final list =
        BidimensionalList<T>(width, canMutate: canMutate, height: height);
    for (var x = 0; x < width; x++)
      for (var y = 0; y < height; y++) list[y][x] = generator(x, y);
    return list;
  }

  int get height => _y;
  int get width => _x;
  set width(int n) {
    assert(n > _x && canMutate);
    final temp = BidimensionalList.view(_underlyingList, _x, height: _y);
    _resizeCounter++;
    _x = n;
    final newList = List<T>(_x * _y);
    _underlyingList = newList;
    for (var i = 0; i < temp.length; i++) {
      this[i] = temp[i];
    }
  }

  @override
  int get length => _y;

  set length(_) => throw StateError(
      "You can't change the size directly, change the width and the height");

  List<List<T>> get rows => this;
  List<List<T>> get columns => _ColumnsViewer<T>(this, _resizeCounter);
  List<T> flat([bool copy = true]) =>
      copy ? List<T>.from(_underlyingList, growable: false) : _underlyingList;
  /**
   * Applies the function [f] to each element of this collection in iteration
   * order.
   */
  void forEachInner(void f(T element)) {
    for (T element in _underlyingList) f(element);
  }

  bool anyInner(bool test(T element)) => _underlyingList.any(test);

  void forEachIndexed(void f(T element, int x, int y)) {
    for (var y = 0; y < this.height; y++) {
      final row = this[y];
      for (var x = 0; x < this.width; x++) {
        final element = row[x];
        f(element, x, y);
      }
    }
  }

  bool everyInner(bool test(T e)) => _underlyingList.every(test);

  Iterable<V> mapInner<V>(V f(T element)) => _underlyingList.map<V>(f);
  Iterable<T> whereInner(bool test(T element)) => _underlyingList.where(test);

  List<T> row(int i) => _RowViewer(this, i, _resizeCounter);
  List<T> column(int i) => _ColumnViewer(this, i, _resizeCounter);

  @override
  List<T> operator [](int y) => row(y);

  @override
  void operator []=(int index, List<T> value) {
    if (value.length != _x) {
      throw StateError("Invalid value");
    }
    final row = this[index];
    for (var i = 0; i < _y; i++) {
      row[i] = value[i];
    }
  }

  @override
  BidimensionalList<T> toList({bool growable: true}) {
    final list = _underlyingList.toList(growable: false);
    return BidimensionalList._(list, _x, _y, growable);
  }

  @override
  Set<List<T>> toSet() => throw StateError("nope");

  @override
  String toString() => rows.join('\n');
}

class _ColumnsViewer<T> extends ListBase<List<T>> {
  final BidimensionalList<T> base;
  final int resizeCounter;

  _ColumnsViewer(this.base, this.resizeCounter);

  @override
  int get length {
    _validate();
    return base._x;
  }

  set length(_) =>
      throw StateError("You cant change the height like this bruh");

  void _validate() {
    assert(base._resizeCounter == resizeCounter);
  }

  @override
  List<T> operator [](int index) {
    _validate();
    return _ColumnViewer(base, index, resizeCounter);
  }

  @override
  void operator []=(int index, List<T> value) {
    _validate();
    if (value.length != base._y) {
      throw StateError("Invalid value");
    }
    final column = this[index];
    for (var i = 0; i < base._y; i++) {
      column[i] = value[i];
    }
  }
}

class _ColumnViewer<T> extends _SideViewer<T> {
  _ColumnViewer(BidimensionalList<T> base, int crossAxisI, int changeCounter)
      : super(base, crossAxisI, changeCounter);

  @override
  int get length {
    _validate();
    return base._y;
  }

  @override
  int _getIndexOnArray(int i) => crossAxisI + i*base._y;
}

class _RowViewer<T> extends _SideViewer<T> {
  _RowViewer(BidimensionalList<T> base, int crossAxisI, int changeCounter)
      : super(base, crossAxisI, changeCounter);

  @override
  int get length {
    _validate();
    return base._x;
  }

  @override
  int _getIndexOnArray(int i) => crossAxisI * length + i;
}

abstract class _SideViewer<T> extends ListBase<T> {
  final BidimensionalList<T> base;
  final int crossAxisI;
  final int resizeCounter;

  _SideViewer(this.base, this.crossAxisI, this.resizeCounter);

  set length(int _) =>
      throw Exception("You can't change the size of the 2d array from a side");

  int _getIndexOnArray(int i);

  void _validate([int i]) {
    if (i != null && (i >= length || i < 0)) {
      throw StateError("Index out of bounds");
    }
    assert(base._resizeCounter == resizeCounter);
  }

  @override
  T operator [](int i) {
    _validate(i);
    return base._underlyingList[_getIndexOnArray(i)];
  }

  @override
  void operator []=(int i, T value) {
    _validate(i);
    base._underlyingList[_getIndexOnArray(i)] = value;
  }
}
