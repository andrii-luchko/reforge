import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/exercise_session/controllers/exercise_swap/exercise_swap_cubit.dart';
import 'package:reforge/features/exercise_session/ui/exercise_swap/widgets/exercise_swap_confirmation_button.dart';
import 'package:reforge/features/exercise_session/ui/exercise_swap/widgets/exercise_swap_header.dart';
import 'package:reforge/features/exercise_session/ui/exercise_swap/widgets/exercise_swap_results.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:toastification/toastification.dart';

class ExerciseSwapSearchPage extends StatefulWidget {
  const ExerciseSwapSearchPage({super.key});

  @override
  State<ExerciseSwapSearchPage> createState() => _ExerciseSwapSearchPageState();
}

class _ExerciseSwapSearchPageState extends State<ExerciseSwapSearchPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 240) {
      unawaited(context.read<ExerciseSwapCubit>().loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExerciseSwapCubit, ExerciseSwapState, bool>(
      selector: (state) => state.isSwapping,
      builder: (context, isSwapping) {
        return PopScope(
          canPop: !isSwapping,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: DefaultBackground(
              body: BlocListener<ExerciseSwapCubit, ExerciseSwapState>(
                listenWhen: (previous, current) => current.error != null && previous.error != current.error,
                listener: (context, state) => toastification.showErrorToast(state.error!, context),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          ExerciseSwapHeader(
                            onBack: isSwapping ? null : () => Navigator.of(context).pop(),
                          ),
                          ExerciseSwapSearchHeader(isSwapping: isSwapping),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          const ExerciseSwapResults(),
                          BlocSelector<ExerciseSwapCubit, ExerciseSwapState, bool>(
                            selector: (state) {
                              return state.selectedExerciseId != null;
                            },
                            builder: (context, hasSelection) {
                              return AppBottomPaddingWidget.sliver(
                                extraSpace: hasSelection ? context.appTheme.buttonConstrains.maxHeight : 0,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: ExerciseSwapConfirmationButton(),
                    ),
                    if (isSwapping) const ScreenLoadingIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
