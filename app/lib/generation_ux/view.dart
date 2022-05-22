import 'package:app/base/controller.dart';
import 'package:app/generation/impl/data.dart';
import 'package:app/generation_ux/controller.dart';
import 'package:app/monadic.dart';
import 'package:app/ui/view.dart';
import 'package:app/view/controller.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/value_notifier.dart';

import '../widgets/memo.dart';

final ContextfulAction<ScaffoldMessengerState> scaffoldMessenger =
    readC.map(ScaffoldMessenger.of);
ContextfulAction<void> showSnackbar(SnackBar snackBar) =>
    scaffoldMessenger.map((messenger) => messenger.showSnackBar(snackBar));

class GenerationView extends ControllerWidget<GenerationController> {
  final SudokuViewController Function(SolvedAndChallengeBoard)
      createBoardControllerFromGenerated;
  const GenerationView({
    Key? key,
    required this.createBoardControllerFromGenerated,
    required ControllerHandle<GenerationController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  @override
  Widget build(ControllerContext<GenerationController> context) {
    final generatedBoard = context.use(controller.generatedBoard);
    void _onGenerationEvent(SudokuGenerationEvent? event) {
      if (event == null) {
        return;
      }
      //showSnackbar(SnackBar(content: Text(event.toString())))(context);
    }

    context.useEventHandler(controller.generationEvents, _onGenerationEvent);
    final progress = context.use(controller.generationProgress);
    return generatedBoard
        .map(
          (maybeGeneratedBoard) => maybeGeneratedBoard == null
              ? progress.map((p) => _LoadingGenerationView(progress: p)).build()
              : ControllerInjectorBuilder<SudokuViewController>(
                  factory: (context) =>
                      createBoardControllerFromGenerated(maybeGeneratedBoard),
                  builder: (context, controller) =>
                      SudokuView(controller: controller),
                  key: ValueKey(maybeGeneratedBoard),
                ),
        )
        .build();
  }
}

class _LoadingGenerationView extends StatelessWidget {
  const _LoadingGenerationView({Key? key, required this.progress})
      : super(key: key);
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        Expanded(child: Placeholder()),
      ],
    );
  }
}
