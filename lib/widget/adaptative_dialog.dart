import 'package:app/util/l10n.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

typedef WidgetWrapperBuilder = Widget Function(BuildContext context, Widget);

Future<T?> showAdaptativeDialog<T>(
  BuildContext context, {
  WidgetWrapperBuilder? builder,
  required WidgetBuilder titleBuilder,
  required WidgetBuilder saveBuilder,
  required WidgetBuilder bodyBuilder,
  bool scrollable = true,
}) {
  final body = _AdaptativeDialogBody<T>(
    titleBuilder: titleBuilder,
    saveBuilder: saveBuilder,
    bodyBuilder: bodyBuilder,
    scrollable: scrollable,
  );
  return Navigator.of(context).push<T>(
    _AdaptativeDialogRoute(
      (context) => builder == null ? body : builder(context, body),
    ),
  );
}

class _AdaptativeDialogRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  final WidgetBuilder _buildContent;

  _AdaptativeDialogRoute(
    this._buildContent,
  ) : super(fullscreenDialog: true);

  @override
  Widget buildContent(BuildContext context) => _buildContent(context);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => Colors.black38;
  bool get opaque => false;
  @override
  bool get barrierDismissible => true;
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (context.sizeClass) {
      case MD3WindowSizeClass.compact:
        return super.buildTransitions(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case MD3WindowSizeClass.medium:
      case MD3WindowSizeClass.expanded:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child,
        );
    }
  }
}

class _AdaptativeDialogBody<T> extends StatelessWidget {
  const _AdaptativeDialogBody({
    Key? key,
    required this.saveBuilder,
    required this.titleBuilder,
    required this.bodyBuilder,
    this.scrollable = true,
  }) : super(key: key);
  final WidgetBuilder titleBuilder;
  final WidgetBuilder saveBuilder;
  final WidgetBuilder bodyBuilder;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final saveButton = saveBuilder(context);
    switch (context.sizeClass) {
      case MD3WindowSizeClass.compact:
        final body = Builder(
          builder: (context) {
            final gutterPadding = EdgeInsets.symmetric(
                vertical: InheritedMD3BodyMargin.of(context).margin / 2);
            return scrollable
                ? SingleChildScrollView(
                    padding: gutterPadding,
                    child: bodyBuilder(context),
                  )
                : Padding(
                    padding: gutterPadding,
                    child: bodyBuilder(context),
                  );
          },
        );
        return MD3FullScreenDialog(
          action: saveButton,
          title: titleBuilder(context),
          body: body,
        );
      case MD3WindowSizeClass.medium:
      case MD3WindowSizeClass.expanded:
        return MD3BasicDialog(
          title: titleBuilder(context),
          content: bodyBuilder(context),
          scrollable: scrollable,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop<T>(),
              child: Text(context.l10n.cancel),
            ),
            saveButton,
          ],
        );
    }
  }
}
