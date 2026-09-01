import 'dart:async';

import 'package:flutter/material.dart';

import '../aac/aac_home_page.dart';
import 'widgets/launch_splash_overlay.dart';
import '../theme/topitot_theme.dart';

class TopitotApp extends StatefulWidget {
  const TopitotApp({super.key});

  @override
  State<TopitotApp> createState() => _TopitotAppState();
}

class _TopitotAppState extends State<TopitotApp> {
  static const Duration _launchSplashDuration = Duration(seconds: 3);

  Timer? _launchSplashTimer;
  bool _showLaunchSplash = true;

  @override
  void initState() {
    super.initState();
    _launchSplashTimer = Timer(_launchSplashDuration, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showLaunchSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _launchSplashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Relay by Topitot',
      debugShowCheckedModeBanner: false,
      theme: TopitotTheme.light,
      home: Stack(
        children: <Widget>[
          const AacHomePage(),
          if (_showLaunchSplash)
            const Positioned.fill(child: LaunchSplashOverlay(visible: true)),
        ],
      ),
    );
  }
}
