import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/curry.dart';

typedef ContextfulAction<T> = T Function(BuildContext);

extension ContextfulActionM<T> on ContextfulAction<T> {
  ContextfulAction<T1> map<T1>(Fn1<T1, T> fn) => mapC(this, fn);
  ContextfulAction<T1> bind<T1>(Fn1<ContextfulAction<T1>, T> fn) =>
      bindC(this, fn);
}

extension ContextfulActionApply<A, B> on ContextfulAction<Fn1<B, A>> {
  ContextfulAction<B> lift(ContextfulAction<A> action) =>
      action.bind((a) => map((fn) => fn(a)));
  ContextfulAction<B> operator <<(ContextfulAction<A> argument) =>
      lift(argument);
}

T _id<T>(T v) => v;

const ContextfulAction<BuildContext> readC = _id;
T runC<T>(ContextfulAction<T> a, BuildContext context) => a(context);
ContextfulAction<T> returnC<T>(T value) => (c) => value;

Widget buildC(ContextfulAction<Widget> builder, [Key? key]) => Builder(
      key: key,
      builder: builder,
    );

ContextfulAction<T1> mapC<T, T1>(
  ContextfulAction<T> a,
  Fn1<T1, T> fn,
) =>
    (c) => fn(runC(a, c));

ContextfulAction<T1> bindC<T, T1>(
  ContextfulAction<T> a,
  Fn1<ContextfulAction<T1>, T> fn,
) =>
    (c) => runC(runC(mapC(a, fn), c), c);

final ContextfulAction<ThemeData> themeData = readC.map(Theme.of);
final ContextfulAction<ColorScheme> colorScheme =
    themeData.map((t) => t.colorScheme);
final ContextfulAction<TextTheme> textTheme = themeData.map((t) => t.textTheme);
final ContextfulAction<MD3TextTheme> md3TextTheme =
    readC.map((c) => c.textTheme);
final ContextfulAction<DefaultTextStyle> defaultTextStyle =
    readC.map(DefaultTextStyle.of);
