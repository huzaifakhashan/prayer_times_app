import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'adhan_channel',
      'تنبيه الأذان',
      description: 'إشعار عند دخول وقت الصلاة',
      importance: Importance.high,
      // Sound is handled by AdhanService (allows playing arbitrary picked
      // files, which isn't possible via a notification channel sound).
      playSound: false,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Requests the runtime permissions needed for the adhan alarm to actually
  /// fire and notify while the app is closed. Must be called from the
  /// foreground app (needs an attached Activity) — never from the background
  /// alarm isolate.
  static Future<void> requestPermissions() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  static Future<void> showAdhanNotification(String prayerName) async {
    await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'adhan_channel',
        'تنبيه الأذان',
        channelDescription: 'إشعار عند دخول وقت الصلاة',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        category: AndroidNotificationCategory.alarm,
      ),
    );

    await _plugin.show(
      prayerName.hashCode,
      'حان الآن وقت صلاة $prayerName',
      'حي على الصلاة',
      details,
    );
  }
}
