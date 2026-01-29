import 'package:flutter/material.dart';

class WorkoutCongratulationsShell extends StatelessWidget {
  const WorkoutCongratulationsShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: child,
    );
  }
}
