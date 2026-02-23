import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/features/notifications/data/service/fcm_notification_service.dart';
import 'package:reforge/shared/uikit/app_bottom_bar.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

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
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: PressableAnimation(
        child: FloatingActionButton(
          onPressed: () async {
            await di.getIt<FcmNotificationService>().sendTestNotification();
            // FirebaseMessaging.instance
            //     .getToken()
            //     .then((token) {
            //       debugPrint('FCM Token: $token');
            //     })
            //     .catchError((error) {
            //       debugPrint('Error fetching FCM token: $error');
            //     });
          },
          child: const Icon(
            Icons.notification_add_outlined,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        navigationShell: widget.navigationShell,
      ),
    );
  }
}
