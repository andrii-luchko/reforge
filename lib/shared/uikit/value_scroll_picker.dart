import 'package:flutter/cupertino.dart';

class ValueScrollPicker extends StatelessWidget {
  const ValueScrollPicker({
    required this.children,
    required this.scrollController,
    required this.onSelectedItemChanged,
    super.key,
  });

  final List<Widget> children;
  final FixedExtentScrollController scrollController;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    const itemExtent = 35.0;
    const visibleItems = 5;

    return SizedBox(
      height: itemExtent * visibleItems,
      child: CupertinoPicker(
        itemExtent: itemExtent,
        scrollController: scrollController,
        onSelectedItemChanged: onSelectedItemChanged,
        selectionOverlay: null,
        children: children,
      ),
    );
  }
}
