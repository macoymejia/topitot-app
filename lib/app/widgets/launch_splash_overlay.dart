import 'package:flutter/material.dart';

class LaunchSplashOverlay extends StatelessWidget {
  const LaunchSplashOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return const IgnorePointer(
      child: SizedBox.expand(
        child: ColoredBox(
          color: Colors.transparent,
          child: Center(
            child: Image(
              image: AssetImage('assets/images/launch/speech_relay_launch.png'),
            ),
          ),
        ),
      ),
    );
  }
}
