import 'package:flutter/cupertino.dart';

class ValueScrollPicker extends StatefulWidget {
  const ValueScrollPicker({
    required this.initialItem,
    required this.children,
    required this.onSelectedItemChanged,
    super.key,
  });

  final int initialItem;
  final List<Widget> children;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  State<ValueScrollPicker> createState() => _ValueScrollPickerState();
}

class _ValueScrollPickerState extends State<ValueScrollPicker> {
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    final initialItem = widget.initialItem > 0 ? widget.initialItem - 1 : 0;

    _scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const itemExtent = 35.0;
    const visibleItems = 5;

    return SizedBox(
      height: itemExtent * visibleItems,
      child: CupertinoPicker(
        itemExtent: itemExtent,
        scrollController: _scrollController,
        onSelectedItemChanged: widget.onSelectedItemChanged,
        selectionOverlay: null,
        children: widget.children,
      ),
    );
  }
}
