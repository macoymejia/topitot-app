import 'package:flutter/material.dart';

import '../aac/aac_home_page.dart';
import '../theme/topitot_theme.dart';

class TopitotApp extends StatelessWidget {
  const TopitotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topitot',
      debugShowCheckedModeBanner: false,
      theme: TopitotTheme.light,
      home: const AacHomePage(),
    );
  }
}
