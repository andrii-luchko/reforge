import 'package:flutter/cupertino.dart';

class ValueScrollPicker extends StatefulWidget {
  const ValueScrollPicker({
    required this.initialItem,
    required this.children,
    required this.onSelectedItemChanged,
    this.looping = true,
    super.key,
  });

  final int initialItem;
  final List<Widget> children;
  final ValueChanged<int> onSelectedItemChanged;
  final bool looping;

  @override
  State<ValueScrollPicker> createState() => _ValueScrollPickerState();
}

class _ValueScrollPickerState extends State<ValueScrollPicker> {
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    final initialItem = widget.initialItem > 0 ? widget.initialItem : 0;

    _scrollController = FixedExtentScrollController(initialItem: initialItem);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelectedItemChanged(initialItem);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const itemExtent = 45.0;
    const visibleItems = 7;

    return SizedBox(
      height: itemExtent * visibleItems,
      child: CupertinoPicker(
        looping: widget.looping,
        itemExtent: itemExtent,
        scrollController: _scrollController,
        onSelectedItemChanged: widget.onSelectedItemChanged,
        selectionOverlay: null,
        children: widget.children,
      ),
    );
  }
}
