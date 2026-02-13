import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/shared/uikit/app_bottom_bar.dart';

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
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: widget.navigationShell,
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: AppBottomBar(
        navigationShell: widget.navigationShell,
      ),
    );
  }
}
