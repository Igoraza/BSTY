import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

openWebsite(String urlLink) async {
  debugPrint('Opening website');
  final url = Uri.parse(urlLink);

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $url ';
  }
}

openBrowser(String url) async {
  Uri uri = Uri.parse(url);
  if (await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    //app opened
  } else {
    throw 'Could not launch $url ';
  }
}
