import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/shared/uikit/app_bottom_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class RootPage extends StatefulWidget {
  const RootPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: DefaultBackground(body: widget.navigationShell),
      bottomNavigationBar: AppBottomBar(
        navigationShell: widget.navigationShell,
      ),
    );
  }
}
