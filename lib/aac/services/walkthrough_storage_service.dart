import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughStorageService {
  static const String walkthroughSeenKey = 'walkthrough_seen';

  Future<bool> hasSeenWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(walkthroughSeenKey) ?? false;
  }

  Future<void> markWalkthroughSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(walkthroughSeenKey, true);
  }
}
