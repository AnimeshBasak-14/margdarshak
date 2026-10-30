import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an official page in the browser, telling the user if it can't.
Future<void> openLink(BuildContext context, Uri url) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Could not open ${url.host}.')));
  }
}
