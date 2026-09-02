import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/topitot_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const TopitotApp());
}
