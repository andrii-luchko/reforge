import 'dart:ui' show FlutterView;

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

@immutable
class KeyboardVisibilityState {
  const KeyboardVisibilityState({
    required this.isVisible,
    required this.height,
  });

  static const hidden = KeyboardVisibilityState(
    isVisible: false,
    height: 0,
  );

  final bool isVisible;

  final double height;

  @override
  bool operator ==(Object other) {
    return other is KeyboardVisibilityState && other.isVisible == isVisible && other.height == height;
  }

  @override
  int get hashCode => Object.hash(isVisible, height);
}

class KeyboardVisibilityController extends ChangeNotifier with WidgetsBindingObserver {
  KeyboardVisibilityController(FlutterView view) : _view = view {
    WidgetsBinding.instance.addObserver(this);
    _update(notify: false);
  }

  FlutterView _view;
  KeyboardVisibilityState _state = KeyboardVisibilityState.hidden;

  KeyboardVisibilityState get state => _state;

  bool get isVisible => _state.isVisible;

  double get height => _state.height;

  void updateView(FlutterView view) {
    if (identical(_view, view)) return;

    _view = view;
    _update();
  }

  @override
  void didChangeMetrics() {
    _update();
  }

  void _update({bool notify = true}) {
    final height = _view.viewInsets.bottom / _view.devicePixelRatio;

    final nextState = KeyboardVisibilityState(
      isVisible: height > 0,
      height: height,
    );

    if (nextState == _state) return;

    _state = nextState;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class KeyboardVisibilityProvider extends StatefulWidget {
  const KeyboardVisibilityProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  static bool isKeyboardVisible(BuildContext context) {
    final isKeyboardVisible = context.select<KeyboardVisibilityController, bool>(
      (controller) => controller.isVisible,
    );

    return isKeyboardVisible;
  }

  @override
  State<KeyboardVisibilityProvider> createState() => _KeyboardVisibilityProviderState();
}

class _KeyboardVisibilityProviderState extends State<KeyboardVisibilityProvider> {
  KeyboardVisibilityController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final view = View.of(context);
    final controller = _controller;

    if (controller == null) {
      _controller = KeyboardVisibilityController(view);
    } else {
      controller.updateView(view);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller!,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
