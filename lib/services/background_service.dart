import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../utils/constants.dart';
import 'notification_service.dart';
import 'prayer_service.dart';

const _prefLat = 'lastLat';
const _prefLng = 'lastLng';
const _channelId = 'adhan_service';

@pragma('vm:entry-point')
void adhanServiceOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stop').listen((_) => service.stopSelf());

  final fired = <String>{};
  var running = false;

  Future<void> tick() async {
    if (running) return;
    running = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (!(prefs.getBool('adhanEnabled') ?? true)) return;

      final lat = prefs.getDouble(_prefLat);
      final lng = prefs.getDouble(_prefLng);
      if (lat == null || lng == null) return;

      final settings = AppSettings(
        madhab: Madhab.values[prefs.getInt('madhab') ?? 0],
        method: CalcMethod.values[prefs.getInt('method') ?? 0],
      );
      final now = DateTime.now();
      final prayers =
          PrayerService.forDate(lat: lat, lng: lng, settings: settings, date: now);

      for (final p in prayers) {
        if (p.name == PrayerNames.sunrise) continue;
        final diff = now.difference(p.time).inSeconds;
        if (diff < 0 || diff > 60) continue;
        final key = '${p.name}_${now.year}${now.month}${now.day}';
        if (!fired.add(key)) continue;

        await NotificationService.showAdhanNotification(p.name);
        await _playAdhan(prefs, p.name);
      }
    } catch (_) {
    } finally {
      running = false;
    }
  }

  Timer.periodic(const Duration(seconds: 1), (_) => tick());
}

Future<void> _playAdhan(SharedPreferences prefs, String name) async {
  final path = prefs.getString('adhan_$name');
  if (path == null || path.isEmpty || !await File(path).exists()) return;

  final player = AudioPlayer();
  try {
    await player.setAndroidAudioAttributes(const AndroidAudioAttributes(
      usage: AndroidAudioUsage.alarm,
      contentType: AndroidAudioContentType.music,
    ));
    await player.setVolume((prefs.getDouble('adhanVolume_$name') ?? 1.0).clamp(0.0, 1.0));
    await player.setFilePath(path);
    await player.play();
    await player.playerStateStream
        .firstWhere((s) => s.processingState == ProcessingState.completed)
        .timeout(const Duration(minutes: 6),
            onTimeout: () => PlayerState(false, ProcessingState.completed));
  } catch (_) {
  } finally {
    await player.dispose();
  }
}

class BackgroundAdhanService {
  static Future<void> init() async {
    if (!Platform.isAndroid) return;

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          'خدمة الأذان',
          description: 'تبقي التطبيق جاهزاً لتشغيل الأذان بوقته',
          importance: Importance.low,
        ));

    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: adhanServiceOnStart,
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'مواقيت الصلاة',
        initialNotificationContent: 'الأذان مفعّل',
        foregroundServiceTypes: [AndroidForegroundType.mediaPlayback],
      ),
      iosConfiguration: IosConfiguration(autoStart: false),
    );
  }

  static Future<void> cacheLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefLat, lat);
    await prefs.setDouble(_prefLng, lng);
  }

  static Future<void> sync(bool enabled) async {
    if (!Platform.isAndroid) return;
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    if (enabled && !running) {
      await service.startService();
    } else if (!enabled && running) {
      service.invoke('stop');
    }
  }
}
