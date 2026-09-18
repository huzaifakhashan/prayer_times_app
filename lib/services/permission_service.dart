import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Real-device background alarms get silently killed unless the user grants
/// these two. Without them the alarm either never fires (no exact-alarm
/// permission) or gets frozen by the OS before it can play (battery
/// optimization) — both fail silently with no error the app can see.
class PermissionService {
  static Future<bool> needsSetup() async {
    if (!Platform.isAndroid) return false;
    final exactAlarm = await Permission.scheduleExactAlarm.status;
    final battery = await Permission.ignoreBatteryOptimizations.status;
    return !exactAlarm.isGranted || !battery.isGranted;
  }

  static Future<void> requestExactAlarm() async {
    if (!Platform.isAndroid) return;
    await Permission.scheduleExactAlarm.request();
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;
    await Permission.ignoreBatteryOptimizations.request();
  }
}
