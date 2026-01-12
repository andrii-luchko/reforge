import 'dart:async';

import 'package:flutter/material.dart';

import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/step_progress_indicator.dart';

class MultiStepForm extends StatefulWidget {
  const MultiStepForm({
    required this.steps,
    required this.totalSteps,
    required this.backButtonText,
    required this.nextButtonText,
    required this.finishButtonText,
    this.onStepChanged,
    this.onCompleted,
    this.onStepValidate,
    this.isNextButtonEnabled = true,
    this.showProgressIndicator = true,
    this.progressIndicatorPadding,
    this.buttonSpacing = 16,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.easeInOut,
    super.key,
  });

  /// List of step widgets to display
  final List<Widget> steps;

  /// Total number of steps (for progress indicator)
  final int totalSteps;

  /// Callback when step changes (receives new step index, 0-based)
  final ValueChanged<int>? onStepChanged;

  /// Callback when all steps are completed
  final VoidCallback? onCompleted;

  /// Optional validation function called before moving to next step
  /// Returns true if step is valid and can proceed, false otherwise
  /// Receives current step index (0-based)
  final bool Function(int stepIndex)? onStepValidate;

  /// Text for the back button
  final String backButtonText;

  /// Text for the next button
  final String nextButtonText;

  /// Text for the finish button (shown on last step)
  final String finishButtonText;

  /// Whether to show the progress indicator
  final bool showProgressIndicator;

  /// Padding around the progress indicator
  final EdgeInsetsGeometry? progressIndicatorPadding;

  /// Spacing between back and next buttons
  final double buttonSpacing;

  /// Duration for page transitions
  final Duration pageTransitionDuration;

  /// Curve for page transitions
  final Curve pageTransitionCurve;

  final bool isNextButtonEnabled;

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  late final PageController _controller;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      unawaited(
        _controller.previousPage(
          duration: widget.pageTransitionDuration,
          curve: widget.pageTransitionCurve,
        ),
      );
      widget.onStepChanged?.call(_currentStep - 1);
    }
  }

  void _goToNextStep() {
    final currentStepIndex = _currentStep - 1;

    // Validate current step if validator is provided
    if (widget.onStepValidate != null) {
      final isValid = widget.onStepValidate!(currentStepIndex);
      if (!isValid) {
        return; // Don't proceed if validation fails
      }
    }

    if (_currentStep < widget.totalSteps) {
      setState(() {
        _currentStep++;
      });
      unawaited(
        _controller.nextPage(
          duration: widget.pageTransitionDuration,
          curve: widget.pageTransitionCurve,
        ),
      );
      widget.onStepChanged?.call(_currentStep - 1);
    } else {
      // Last step - call completion callback
      widget.onCompleted?.call();
    }
  }

  bool get _isFirstStep => _currentStep == 1;
  bool get _isLastStep => _currentStep == widget.totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showProgressIndicator)
          Padding(
            padding: widget.progressIndicatorPadding ?? const EdgeInsets.only(top: 16, bottom: 32),
            child: StepProgressIndicator(
              currentStep: _currentStep,
              totalSteps: widget.totalSteps,
            ),
          ),
        Expanded(
          child: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.steps,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: widget.backButtonText,
                onPressed: _isFirstStep ? null : _goToPreviousStep,
              ),
            ),
            SizedBox(width: widget.buttonSpacing),
            Expanded(
              child: PrimaryButton(
                text: _isLastStep ? (widget.finishButtonText) : (widget.nextButtonText),
                onPressed: widget.isNextButtonEnabled ? _goToNextStep : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

