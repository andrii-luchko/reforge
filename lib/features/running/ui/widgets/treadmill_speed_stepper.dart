import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/constants/workout_constants.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class TreadmillSpeedStepper extends StatefulWidget {
  const TreadmillSpeedStepper({
    required this.speedKmH,
    required this.measureSystem,
    required this.onChangedKmH,
    this.enabled = true,
    super.key,
  });

  static const Key decrementKey = ValueKey('treadmill-speed-decrement');
  static const Key incrementKey = ValueKey('treadmill-speed-increment');
  static const Key valueKey = ValueKey('treadmill-speed-value');

  final double speedKmH;
  final MeasurementSystem measureSystem;
  final ValueChanged<double> onChangedKmH;
  final bool enabled;

  @override
  State<TreadmillSpeedStepper> createState() => _TreadmillSpeedStepperState();
}

class _TreadmillSpeedStepperState extends State<TreadmillSpeedStepper> {
  static const _repeatDelay = Duration(milliseconds: 500);
  static const _repeatInterval = Duration(milliseconds: 100);
  static const _commandInterval = Duration(milliseconds: 250);
  static const _confirmationTimeout = Duration(seconds: 2);
  static const _epsilon = 0.0001;

  Timer? _repeatTimer;
  Timer? _commandTimer;
  Timer? _confirmationTimer;
  DateTime? _lastCommandAt;
  double? _lastCommandDisplaySpeed;
  late double _displaySpeed;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _displaySpeed = _toDisplaySpeed(widget.speedKmH);
  }

  @override
  void didUpdateWidget(covariant TreadmillSpeedStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.measureSystem != widget.measureSystem) {
      _cancelInteraction();
      _displaySpeed = _toDisplaySpeed(widget.speedKmH);
      _lastCommandDisplaySpeed = null;
      return;
    }

    if ((oldWidget.speedKmH - widget.speedKmH).abs() > _epsilon) {
      _confirmationTimer?.cancel();
      if (!_isInteracting) {
        _lastCommandDisplaySpeed = null;
        _displaySpeed = _toDisplaySpeed(widget.speedKmH);
      }
    }
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _commandTimer?.cancel();
    _confirmationTimer?.cancel();
    super.dispose();
  }

  double get _minimumDisplaySpeed => WorkoutConstants.minTreadmillSpeed(widget.measureSystem);

  double get _maximumDisplaySpeed => WorkoutConstants.maxTreadmillSpeed(widget.measureSystem);

  bool get _canDecrement => widget.enabled && _displaySpeed > _minimumDisplaySpeed + _epsilon;

  bool get _canIncrement => widget.enabled && _displaySpeed < _maximumDisplaySpeed - _epsilon;

  double _toDisplaySpeed(double speedKmH) {
    final converted = widget.measureSystem == MeasurementSystem.imperial
        ? MeasureSystemValues.toMiles(speedKmH)
        : speedKmH;
    return _roundToStep(converted.clamp(_minimumDisplaySpeed, _maximumDisplaySpeed));
  }

  double _toCanonicalSpeed(double displaySpeed) {
    return widget.measureSystem == MeasurementSystem.imperial ? MeasureSystemValues.toKm(displaySpeed) : displaySpeed;
  }

  double _roundToStep(double value) {
    return (value / WorkoutConstants.speedStep).round() * WorkoutConstants.speedStep;
  }

  void _startRepeating(double delta) {
    if (!widget.enabled || !_canApply(delta)) return;

    _isInteracting = true;
    _applyDelta(delta, forceCommand: true);
    _repeatTimer = Timer(_repeatDelay, () {
      _repeatTimer = Timer.periodic(_repeatInterval, (_) {
        if (_canApply(delta)) {
          _applyDelta(delta);
        } else {
          _stopRepeating();
        }
      });
    });
  }

  bool _canApply(double delta) => delta < 0 ? _canDecrement : _canIncrement;

  void _applyDelta(double delta, {bool forceCommand = false}) {
    final next = _roundToStep(
      (_displaySpeed + delta).clamp(_minimumDisplaySpeed, _maximumDisplaySpeed),
    );
    if ((next - _displaySpeed).abs() <= _epsilon) return;

    setState(() => _displaySpeed = next);
    unawaited(HapticFeedback.selectionClick());
    _queueCommand(force: forceCommand);
  }

  void _queueCommand({bool force = false}) {
    final now = DateTime.now();
    final elapsed = _lastCommandAt == null ? _commandInterval : now.difference(_lastCommandAt!);

    if (force || elapsed >= _commandInterval) {
      _sendCommand();
      return;
    }

    _commandTimer ??= Timer(_commandInterval - elapsed, () {
      _commandTimer = null;
      _sendCommand();
    });
  }

  void _sendCommand() {
    _commandTimer?.cancel();
    _commandTimer = null;

    if ((_lastCommandDisplaySpeed ?? double.nan) == _displaySpeed) return;

    _lastCommandAt = DateTime.now();
    _lastCommandDisplaySpeed = _displaySpeed;
    widget.onChangedKmH(_toCanonicalSpeed(_displaySpeed));
  }

  void _stopRepeating() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    if (!_isInteracting) return;

    _isInteracting = false;
    _sendCommand();
    _confirmationTimer?.cancel();
    _confirmationTimer = Timer(_confirmationTimeout, () {
      if (!mounted || _isInteracting) return;
      setState(() {
        _displaySpeed = _toDisplaySpeed(widget.speedKmH);
        _lastCommandDisplaySpeed = null;
      });
    });
  }

  void _cancelInteraction() {
    _repeatTimer?.cancel();
    _commandTimer?.cancel();
    _confirmationTimer?.cancel();
    _repeatTimer = null;
    _commandTimer = null;
    _confirmationTimer = null;
    _isInteracting = false;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: appTheme.beige900,
            border: Border.all(color: appTheme.strokeCard),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SpeedButton(
                key: TreadmillSpeedStepper.decrementKey,
                icon: Icons.remove,
                enabled: _canDecrement,
                onStart: () => _startRepeating(-WorkoutConstants.speedStep),
                onStop: _stopRepeating,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    spacing: 4,
                    children: [
                      Text(
                        _displaySpeed.toStringAsFixed(1),
                        key: TreadmillSpeedStepper.valueKey,
                        style: subheadH1Medium.copyWith(color: appTheme.beige100),
                      ),

                      Text(
                        WorkoutMetric.speed.title(t, widget.measureSystem),
                        style: bodyMRegular.copyWith(color: appTheme.beige500),
                      ),
                    ],
                  ),
                ),
              ),
              _SpeedButton(
                key: TreadmillSpeedStepper.incrementKey,
                icon: Icons.add,
                enabled: _canIncrement,
                onStart: () => _startRepeating(WorkoutConstants.speedStep),
                onStop: _stopRepeating,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeedButton extends StatefulWidget {
  const _SpeedButton({
    required this.icon,
    required this.enabled,
    required this.onStart,
    required this.onStop,
    super.key,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  bool _isPressed = false;

  void _start() {
    if (!widget.enabled || _isPressed) return;

    setState(() => _isPressed = true);
    widget.onStart();
  }

  void _stop() {
    if (!_isPressed) return;

    setState(() => _isPressed = false);
    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final enabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _start(),
        onTapUp: (_) => _stop(),
        onTapCancel: _stop,
        child: AnimatedContainer(
          duration: Durations.short3,
          curve: Curves.easeInOut,
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: enabled ? (_isPressed ? appTheme.orange300 : appTheme.orange500) : appTheme.beige800,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            widget.icon,
            color: enabled ? appTheme.beige100 : appTheme.beige600,
            size: 28,
          ),
        ),
      ),
    );
  }
}
