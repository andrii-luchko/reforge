//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/features/notifications/data/service/fcm_notification_service.dart';
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
              onPressed: () async {
                const token =
                    'f05gB9U-fUWCjmui7MmQ2i:APA91bFzyoy71iYPBYWpE4cUYKe-rcr2qJZWbZ35ykvCP0BKlL4-ZpQzruns1o5VI0UiDB8Lhtw9L4LwAlFBTx2Ww3Wds7hHp8eWUcBqyS5BkDybR8aPvmg';
                await di.getIt<FcmNotificationService>().sendTestNotification(token);
                // FirebaseMessaging.instance
                //     .getToken()
                //     .then((token) {
                //       debugPrint('FCM Token: $token');
                //     })
                //     .catchError((error) {
                //       debugPrint('Error fetching FCM token: $error');
                //     });
              },
              child: const Icon(Icons.notification_add),
            )
          : null,
      bottomNavigationBar: AppBottomBar(
        navigationShell: widget.navigationShell,
      ),
    );
  }
}
