import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/pickers/universal_number_piker.dart';

class DistanceScrollPicker extends StatefulWidget {
  const DistanceScrollPicker({
    required this.initialDistance,
    required this.onDistanceChanged,
    this.numberTextStyle,
    this.system = MeasurementSystem.metric,
    this.start = 0.0,
    this.end = 100.0,
    this.step = 0.01,
    super.key,
  });

  final double initialDistance;
  final ValueChanged<double> onDistanceChanged;
  final TextStyle? numberTextStyle;
  final MeasurementSystem system;
  final double start;
  final double end;
  final double step;

  @override
  State<DistanceScrollPicker> createState() => _DistanceScrollPickerState();
}

class _DistanceScrollPickerState extends State<DistanceScrollPicker> {
  late int _selectedKm;
  late int _selectedMeters;

  late List<int> _kmItems;
  late List<int> _meterItems;

  @override
  void initState() {
    super.initState();
    _generateLists();

    _selectedKm = widget.initialDistance.truncate();

    if (_selectedKm < widget.start.truncate()) _selectedKm = widget.start.truncate();
    if (_selectedKm > widget.end.truncate()) _selectedKm = widget.end.truncate();

    final rawMeters = ((widget.initialDistance - _selectedKm) * 100).round();
    _selectedMeters = _getClosestMeterStep(rawMeters);
  }

  void _generateLists() {
    final startKm = widget.start.truncate();
    final endKm = widget.end.truncate();
    _kmItems = List.generate(endKm - startKm + 1, (index) => startKm + index);

    var stepInHundreds = (widget.step * 100).round();
    if (stepInHundreds <= 0) stepInHundreds = 1;

    _meterItems = [];
    for (var i = 0; i < 100; i += stepInHundreds) {
      _meterItems.add(i);
    }
  }

  int _getClosestMeterStep(int value) {
    return _meterItems.reduce((a, b) => (value - a).abs() < (value - b).abs() ? a : b);
  }

  void _notifyChange() {
    final newDistance = _selectedKm + (_selectedMeters / 100.0);
    widget.onDistanceChanged(newDistance);
  }

  @override
  Widget build(BuildContext context) {
    final systemLabel = widget.system.distanceSymbol(t);
    final style = widget.numberTextStyle ?? subheadH1Medium.copyWith(color: context.appTheme.beige100);

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: UniversalNumberPicker<int>(
              items: _kmItems,
              initialValue: _selectedKm,
              textStyle: style,
              onChanged: (val) {
                _selectedKm = val;
                _notifyChange();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('.', style: style.copyWith(fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                UniversalNumberPicker<int>(
                  items: _meterItems,
                  initialValue: _selectedMeters,
                  textStyle: style,
                  valueFormatter: (val) => val.toString().padLeft(2, '0'),
                  onChanged: (val) {
                    _selectedMeters = val;
                    _notifyChange();
                  },
                ),

                Positioned(
                  right: 8,
                  child: Text(systemLabel, style: style),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
