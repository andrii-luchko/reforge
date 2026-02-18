import 'package:flutter/gestures.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrl {
  LaunchUrl._();

  static TapGestureRecognizer launchUrlRecognizer(String url) {
    return TapGestureRecognizer()
      ..onTap = () async {
        await launchAppLink(url);
      };
  }

  static Future<void> launchAppLink(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      logger.d('Could not launch URL: $e');
    }
  }
}
