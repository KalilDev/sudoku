import 'dart:collection';
import 'package:meta/meta.dart';

class _OneDBackedBidimensionalList<T> extends BidimensionalList<T> {
  List<T> _underlyingList;
  int _x;
  int _y;

  factory _OneDBackedBidimensionalList.filled(int width, T fill, {int height, bool canMutate = false}) {
    height ??= width;
    final list = List<T>.filled(width*height, fill, growable: false);
    return _OneDBackedBidimensionalList(underlyingList: list, width: width, height: height, canMutate: canMutate);
  }

  _OneDBackedBidimensionalList(
      {@required List<T> underlyingList, @required int width, @required int height, @required bool canMutate})
      : assert(underlyingList.length == width * (height ?? width)),
        _x = width,
        _y = height ?? width,
        _underlyingList = underlyingList,
        super._(canMutate);

  int get height => _y;
  set height(int n) {
    throw UnimplementedError();
  }
  int get width => _x;
  set width(int n) {
    throw UnimplementedError();
  }

  @override
  List<T> flat([bool copy = true]) =>
      copy ? _underlyingList.toList(growable: false) : _underlyingList;
  
  @override
  BidimensionalList<T> toList({bool growable: true}) {
    final list = _underlyingList.toList(growable: false);
    return _OneDBackedBidimensionalList(underlyingList: list, width: _x, height: _y, canMutate: growable);
  }

  @override
  T getValue(int x, int y) => _underlyingList[y*width + x];
  
  @override
  T setValue(int x, int y, T value) => _underlyingList[y*width + x] = value;

  @override
  BidimensionalList<V> castInner<V>() => _OneDBackedBidimensionalList(underlyingList: _underlyingList.cast<V>(), width: width, height: height, canMutate: canMutate);

}

class _TwoDBackedBidimensionalList<T> extends BidimensionalList<T> {
  List<List<T>> _underlyingList;
  int _x;
  _TwoDBackedBidimensionalList._(this._underlyingList, this._x, bool canMutate) : super._(canMutate);

  factory _TwoDBackedBidimensionalList(
      List<List<T>> underlyingList, {bool canMutate = false}) {
   final width = underlyingList.length > 0 ? underlyingList.first.length : 0;
   assert(underlyingList.every((e) => e.length == width));
  return _TwoDBackedBidimensionalList<T>._(underlyingList, width, canMutate);
  }


  @override
  int get height => _underlyingList.length;
  set height(int n) {
    throw UnimplementedError();
  }

  @override
  int get width => _x;
  set width(int n) {
    throw UnimplementedError();
  }

  @override
  T getValue(int x, int y) => _underlyingList[y][x];
  
  
  @override
  T setValue(int x, int y, T value) => _underlyingList[y][x] = value;

  // TODO: ????
  @override
  BidimensionalList<T> toList({bool growable: true}) => BidimensionalList.view2d(super.toList());

  BidimensionalList<V> castInner<V>() => _OneDBackedBidimensionalList(underlyingList: flat().cast<V>(), width: width, height: height, canMutate: canMutate);
}


abstract class BidimensionalList<T> extends ListBase<List<T>> {
  final bool canMutate;
  BidimensionalList._(this.canMutate);

  factory BidimensionalList.view2d(List<List<T>> list) => _TwoDBackedBidimensionalList(list, canMutate: false);
  factory BidimensionalList.view(List<T> list, int width, {int height}) => _OneDBackedBidimensionalList(underlyingList: list, width: width, height: height, canMutate: false);
  factory BidimensionalList.filled(int width, T fill, {int height, bool canMutate = false}) {
    return _OneDBackedBidimensionalList.filled(width, fill, height: height, canMutate: canMutate);
  }
  factory BidimensionalList.generate(int width, T Function(int x, int y) gen, {int height, bool canMutate = false}) {
    height ??= width;
    final list = List<List<T>>.generate(height, (y) => List<T>.generate(width, (x) => gen(x, y), growable: false), growable: false);
    return _TwoDBackedBidimensionalList._(list, width, canMutate);
  }

  int get height;
  set height(int n);
  int get width;
  set width(int n);

  @override
  int get length => height;
  set length(_) => throw StateError(
      "You can't change the size directly, change the width and the height");

  List<List<T>> get rows => this;
  List<List<T>> get columns {
    return Viewer<List<T>>(valueGetter: (int i)=>getColumn(i), valueSetter: (int i, List<T> value)=> setColumn(i, value), lengthGetter: ()=> width, lengthSetter: (int length)=>width = length);
  }
  List<T> flat([bool copy = true]) {
    if (!copy) {
      throw StateError("In this BidimensionalList impl, you NEED to copy");
    }
    // TERRIBLY inneficient
    return reduce((rowA, rowB)=> [...rowA, ...rowB]).toList();
  }
  /**
   * Applies the function [f] to each element of this collection in iteration
   * order.
   */
  void forEachInner(void f(T element)) => forEach((e)=>e.forEach(f));

  bool anyInner(bool test(T element)) => any((e)=>e.any(test));

  void forEachIndexed(void f(T element, int x, int y)) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final element = getValue(x, y);
        f(element, x, y);
      }
    }
  }

  bool everyInner(bool test(T e)) => every((e)=>e.every(test));

  Iterable<V> mapInner<V>(V f(T element)) => map((e)=>e.map<V>(f)).reduce((a,b)=>a.followedBy(b));
  Iterable<V> mapInnerIndexed<V>(V f(int x, int y, T element)) {
    return Iterable.generate(height*width, (i) {
      final x = i % width;
      final y = i ~/ width;
      return f(x, y, getValue(x, y));
    });
  }
  Iterable<T> whereInner(bool test(T element)) => map((e)=>e.where(test)).reduce((a,b) => a.followedBy(b));

  BidimensionalList<V> castInner<V>();

  List<T> getRow(int i) {
    final y = i;
    return Viewer<T>(lengthGetter: ()=> width, valueGetter: (int i) => getValue(i, y), valueSetter: (int i, T value) => setValue(i, y, value), lengthSetter: (int i) => width = i);
  }
  void setRow(int i, List<T> value) {
    if (value.length != width) {
      throw StateError("You can't set an eow that isn't the same size as the width");
    }
    for (int x = 0 ; x < width; x++) {
      setValue(x, i, value[x]);
    }
  }

  List<T> getColumn(int i) {
    final x = i;
    return Viewer<T>(lengthGetter: ()=> height, valueGetter: (int i) => getValue(x, i), valueSetter: (int i, T value) => setValue(x, i, value), lengthSetter: (int i) => height = i);
  }
  void setColumn(int i, List<T> value) {
    if (value.length != height) {
      throw StateError("You can't set an column that isn't the same size as the height");
    }
    for (int y = 0 ; y < height; y++) {
      setValue(i, y, value[y]);
    }
  }

  T getValue(int x, int y);
  T setValue(int x, int y, T value);

  @override
  List<T> operator [](int y) => getRow(y);

  @override
  void operator []=(int index, List<T> value) => setRow(index, value);

  @override
  BidimensionalList<T> toList({bool growable: true});

  @override
  String toString() => rows.join('\n');
}

typedef ValueGetter<T> = T Function(int i);
typedef ValueSetter<T> = void Function(int i, T value);
typedef LengthGetter = int Function();
typedef LengthSetter = void Function(int length);

class Viewer<T> extends ListBase<T> {
  final ValueGetter<T> _valueGetter;
  final ValueSetter<T> _valueSetter;
  final LengthGetter _lengthGetter;
  final LengthSetter _lengthSetter;
  Viewer({@required ValueGetter<T> valueGetter, @required ValueSetter<T> valueSetter, @required LengthGetter lengthGetter, LengthSetter lengthSetter})
    : _valueGetter = valueGetter,
      _valueSetter = valueSetter,
      _lengthGetter = lengthGetter,
      _lengthSetter = lengthSetter;

  @override
  int get length => _lengthGetter();
  set length(int length) {
    if (_lengthSetter == null) {
      throw StateError("You can't change the length");
    }
    _lengthSetter(length);
    
  }

  @override
  T operator [](int index) => _valueGetter(index);
  
  @override
  void operator []=(int index, T value) => _valueSetter(index, value);
}
