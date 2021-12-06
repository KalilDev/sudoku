import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_presentation/errors.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showExceptionSnackbar(BuildContext context, UserFriendly<Object> exception) {
  final snackbar = SnackBar(content: Text(exception.getText(kDebugMode)));
  return Scaffold.of(context).showSnackBar(snackbar);
}