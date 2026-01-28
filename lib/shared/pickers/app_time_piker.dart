import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class AppTimerPicker extends StatefulWidget {
  const AppTimerPicker({
    required this.initialDuration,
    required this.onTimerDurationChanged,
    this.numberTextStyle,
    this.labelTextStyle,
    this.selectionOverlayColor,
    this.itemExtent = 32.0,
    this.hourLabel = 'h',
    this.minuteLabel = 'm',
    this.secondLabel = 's',
    super.key,
  });

  final Duration initialDuration;
  final ValueChanged<Duration> onTimerDurationChanged;

  final TextStyle? numberTextStyle;
  final TextStyle? labelTextStyle;
  final Color? selectionOverlayColor;
  final double itemExtent;

  final String hourLabel;
  final String minuteLabel;
  final String secondLabel;

  @override
  State<AppTimerPicker> createState() => _AppTimerPickerState();
}

class _AppTimerPickerState extends State<AppTimerPicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialDuration.inHours;
    _selectedMinute = widget.initialDuration.inMinutes % 60;
    _selectedSecond = widget.initialDuration.inSeconds % 60;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _secondController = FixedExtentScrollController(initialItem: _selectedSecond);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final newDuration = Duration(
      hours: _selectedHour,
      minutes: _selectedMinute,
      seconds: _selectedSecond,
    );
    widget.onTimerDurationChanged(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    final numStyle = widget.numberTextStyle ?? subheadH1Medium.copyWith(color: context.appTheme.beige100);

    final lblStyle = widget.labelTextStyle ?? subheadH1Medium.copyWith(color: context.appTheme.beige100);

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildColumn(
            initialItem: _selectedHour,
            count: 24,
            label: widget.hourLabel,
            numStyle: numStyle,
            lblStyle: lblStyle,
            onChanged: (val) {
              _selectedHour = val;
              _notifyChange();
            },
          ),

          _buildColumn(
            initialItem: _selectedMinute,
            count: 60,
            label: widget.minuteLabel,
            numStyle: numStyle,
            lblStyle: lblStyle,
            onChanged: (val) {
              _selectedMinute = val;
              _notifyChange();
            },
          ),

          _buildColumn(
            initialItem: _selectedSecond,
            count: 60,
            label: widget.secondLabel,
            numStyle: numStyle,
            lblStyle: lblStyle,
            onChanged: (val) {
              _selectedSecond = val;
              _notifyChange();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required int initialItem,
    required int count,
    required String label,
    required TextStyle numStyle,
    required TextStyle lblStyle,
    required ValueChanged<int> onChanged,
  }) {
    final items = List.generate(count, (index) {
      return Center(
        child: Text(
          index.toString().padLeft(2, '0'),
          style: numStyle,
        ),
      );
    });

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueScrollPicker(
            initialItem: initialItem,
            onSelectedItemChanged: onChanged,
            children: items,
          ),

          IgnorePointer(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12, bottom: 2),
              child: Text(label, style: lblStyle),
            ),
          ),
        ],
      ),
    );
  }
}
