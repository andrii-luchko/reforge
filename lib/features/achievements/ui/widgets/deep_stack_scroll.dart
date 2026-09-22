import 'package:flutter/material.dart';

class DeepStackScroll extends StatefulWidget {
  const DeepStackScroll({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  State<DeepStackScroll> createState() => _DeepStackScrollState();
}

class _DeepStackScrollState extends State<DeepStackScroll> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _maxIndex => (widget.children.length - 1).toDouble();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      value: _maxIndex > 0 ? _maxIndex : 0,
      lowerBound: -1,
      upperBound: double.infinity,
      duration: const Duration(milliseconds: 600),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(DeepStackScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.children.length != oldWidget.children.length) {
      if (_controller.value > _maxIndex) {
        _controller.value = _maxIndex;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox();

    return GestureDetector(
      onVerticalDragStart: (_) => _controller.stop(),
      onVerticalDragUpdate: (details) {
        final delta = details.delta.dy * 0.005;

        final newValue = _controller.value - delta;

        _controller.value = newValue.clamp(0.0, _maxIndex);
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        final currentValue = _controller.value;
        var target = currentValue.roundToDouble();

        if (velocity.abs() > 300) {
          target = velocity < 0 ? currentValue.ceilToDouble() : currentValue.floorToDouble();
        }

        if (target < 0) target = 0;
        if (target > _maxIndex) target = _maxIndex;

        _controller.animateTo(
          target,
          curve: Curves.easeOutQuart,
        );
      },
      child: ColoredBox(
        color: Colors.transparent,

        child: Stack(
          alignment: Alignment.center,

          children: List.generate(widget.children.length, (index) {
            final scrollOffset = _controller.value;
            final diff = index - scrollOffset;

            if (diff > 1.5 || diff < -4) return const SizedBox.shrink();

            var translateY = 0.0;
            var scale = 1.0;
            var opacity = 1.0;

            if (diff <= 0) {
              scale = (1 + (diff * 0.05)).clamp(0.0, 1.0);
              translateY = diff * 26;
              opacity = (1 + (diff * 0.2)).clamp(0.0, 1.0);
            } else {
              translateY = diff * 500;
              opacity = (1 - diff).clamp(0.0, 1.0);
            }

            return Positioned.fill(
              child: Center(
                child: Transform(
                  alignment: Alignment.center,

                  transform: Matrix4.identity()
                    ..translateByDouble(0, translateY, 0, 1)
                    ..scaleByDouble(scale, scale, 1, 1),
                  child: Opacity(
                    opacity: opacity,

                    child: KeyedSubtree(
                      key: ValueKey(index),
                      child: widget.children[index],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
