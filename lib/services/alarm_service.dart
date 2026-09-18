import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/prayer_item.dart';
import 'notification_service.dart';
import 'prayer_service.dart';

const _prefLat = 'lastLat';
const _prefLng = 'lastLng';

/// Runs in a background isolate spawned by AlarmManager, independent of the
/// app's UI process, so it fires whether the app is open, backgrounded, or
/// fully killed.
@pragma('vm:entry-point')
void adhanAlarmCallback(int id) async {
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool('adhanEnabled') ?? false)) return;
  if (id < 1 || id > AppSettings.adhanPrayers.length) return;

  final name = AppSettings.adhanPrayers[id - 1];
  final path = prefs.getString('adhan_$name');
  final volume = prefs.getDouble('adhanVolume_$name') ?? 1.0;

  if (path != null && path.isNotEmpty && await File(path).exists()) {
    final player = AudioPlayer();
    try {
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setFilePath(path);
      await player.play();
      await player.playerStateStream
          .firstWhere((s) => s.processingState == ProcessingState.completed)
          .timeout(
            const Duration(minutes: 6),
            onTimeout: () => PlayerState(false, ProcessingState.completed),
          );
    } catch (_) {
    } finally {
      await player.dispose();
    }
  }

  await NotificationService.showAdhanNotification(name);
  await AlarmService._rescheduleTomorrow(id, prefs);
}

class AlarmService {
  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    await AndroidAlarmManager.initialize();
  }

  static Future<void> cacheLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefLat, lat);
    await prefs.setDouble(_prefLng, lng);
  }

  static Future<void> scheduleAll({
    required List<PrayerItem> todayPrayers,
    required AppSettings settings,
    required double lat,
    required double lng,
  }) async {
    if (!Platform.isAndroid) return;

    if (!settings.adhanEnabled) {
      await cancelAll();
      return;
    }

    final now = DateTime.now();
    List<PrayerItem>? tomorrowPrayers;

    for (var i = 0; i < AppSettings.adhanPrayers.length; i++) {
      final name = AppSettings.adhanPrayers[i];
      final id = i + 1;
      final path = settings.adhanFiles[name];

      if (path == null || path.isEmpty) {
        await AndroidAlarmManager.cancel(id);
        continue;
      }

      DateTime? time;
      for (final p in todayPrayers) {
        if (p.name == name) {
          time = p.time;
          break;
        }
      }

      if (time == null || !time.isAfter(now)) {
        tomorrowPrayers ??= PrayerService.forDate(
          lat: lat,
          lng: lng,
          settings: settings,
          date: now.add(const Duration(days: 1)),
        );
        time = tomorrowPrayers.firstWhere((p) => p.name == name).time;
      }

      await AndroidAlarmManager.oneShotAt(
        time,
        id,
        adhanAlarmCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
    }
  }

  static Future<void> cancelAll() async {
    if (!Platform.isAndroid) return;
    for (var i = 1; i <= AppSettings.adhanPrayers.length; i++) {
      await AndroidAlarmManager.cancel(i);
    }
  }

  static Future<void> _rescheduleTomorrow(int id, SharedPreferences prefs) async {
    final lat = prefs.getDouble(_prefLat);
    final lng = prefs.getDouble(_prefLng);
    if (lat == null || lng == null) return;

    final name = AppSettings.adhanPrayers[id - 1];
    final path = prefs.getString('adhan_$name');
    if (path == null || path.isEmpty) return;

    final settings = AppSettings(
      madhab: Madhab.values[prefs.getInt('madhab') ?? 0],
      method: CalcMethod.values[prefs.getInt('method') ?? 0],
    );

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final list = PrayerService.forDate(
      lat: lat,
      lng: lng,
      settings: settings,
      date: tomorrow,
    );
    final time = list.firstWhere((p) => p.name == name).time;

    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      adhanAlarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
  }
}
