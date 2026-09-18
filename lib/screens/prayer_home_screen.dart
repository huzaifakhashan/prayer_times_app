import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:prayer_timer/Drawer/drawerPage.dart';

import '../models/app_settings.dart';
import '../models/prayer_item.dart';
import '../services/adhan_service.dart';
import '../services/alarm_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/prayer_service.dart';
import '../utils/constants.dart';
import '../utils/time_formatter.dart';
import '../widgets/error_view.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_list_item.dart';
import '../widgets/settings_sheet.dart';

class PrayerHomeScreen extends StatefulWidget {
  const PrayerHomeScreen({super.key});

  @override
  State<PrayerHomeScreen> createState() => _PrayerHomeScreenState();
}

class _PrayerHomeScreenState extends State<PrayerHomeScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _now = DateTime.now();
  double? _lat;
  double? _lng;
  bool _loading = true;
  String? _error;
  List<PrayerItem> _prayers = [];
  DateTime? _tomorrowFajr;
  DateTime? _lastCalcDate;
  AppSettings _settings = AppSettings();

  final _adhan = AdhanService();
  String? _lastPlayed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    await NotificationService.requestPermissions();
    await _loadSettings();
    _startTimer();

    if (_settings.adhanEnabled && await PermissionService.needsSetup()) {
      _showBackgroundPermissionDialog();
    }
  }

  void _showBackgroundPermissionDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.sheetBg,
        title: const Text('صلاحيات ضرورية لتشغيل الأذان'),
        content: const Text(
          'حتى يرن الأذان بوقته حتى لو التطبيق مسكر، لازم تسمح للتطبيق بصلاحيتين:\n\n'
          '١. جدولة التنبيهات الدقيقة (Alarms & reminders)\n'
          '٢. تجاهل توفير البطارية لهذا التطبيق\n\n'
          'من دونهم نظام الأندرويد بيقتل التنبيه قبل ما يرن.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await PermissionService.requestExactAlarm();
              await PermissionService.requestIgnoreBatteryOptimizations();
              if (_lat != null && _lng != null) _recalc();
            },
            child: const Text('السماح'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adhan.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lat != null && _lng != null) {
      _recalc();
    }
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();

    final files = <String, String?>{};
    final volumes = <String, double>{};
    for (final n in AppSettings.adhanPrayers) {
      files[n] = p.getString('adhan_$n');
      volumes[n] = p.getDouble('adhanVolume_$n') ?? 1.0;
    }

    setState(() {
      _settings = AppSettings(
        madhab: Madhab.values[p.getInt('madhab') ?? 0],
        method: CalcMethod.values[p.getInt('method') ?? 0],
        showSunrise: p.getBool('showSunrise') ?? true,
        use24Hour: p.getBool('use24Hour') ?? false,
        adhanEnabled: p.getBool('adhanEnabled') ?? false,
        adhanFiles: files,
        adhanVolumes: volumes,
      );
    });

    await _fetchLocation();
  }

  Future<void> _saveSettings() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('madhab', _settings.madhab.index);
    await p.setInt('method', _settings.method.index);
    await p.setBool('showSunrise', _settings.showSunrise);
    await p.setBool('use24Hour', _settings.use24Hour);
    await p.setBool('adhanEnabled', _settings.adhanEnabled);

    for (final e in _settings.adhanFiles.entries) {
      if (e.value != null) {
        await p.setString('adhan_${e.key}', e.value!);
      } else {
        await p.remove('adhan_${e.key}');
      }
    }

    for (final e in _settings.adhanVolumes.entries) {
      await p.setDouble('adhanVolume_${e.key}', e.value);
    }

    await _scheduleAlarms();
  }

  Future<void> _scheduleAlarms() async {
    if (_lat == null || _lng == null || _prayers.isEmpty) return;
    await AlarmService.scheduleAll(
      todayPrayers: _prayers,
      settings: _settings,
      lat: _lat!,
      lng: _lng!,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final t = DateTime.now();
      final dayChanged = _lastCalcDate != null &&
          (t.year != _lastCalcDate!.year ||
              t.month != _lastCalcDate!.month ||
              t.day != _lastCalcDate!.day);

      if (dayChanged && _lat != null && _lng != null) {
        _now = t;
        _recalc();
        return;
      }

      _checkAdhan(t);
      setState(() => _now = t);
    });
  }

  void _checkAdhan(DateTime t) {
    if (!_settings.adhanEnabled || _prayers.isEmpty) return;

    for (final p in _prayers) {
      if (p.name == PrayerNames.sunrise) continue;

      final diff = t.difference(p.time).inSeconds;
      if (diff >= 0 && diff <= 1) {
        final key = '${p.name}_${p.time.day}';
        if (_lastPlayed != key) {
          _lastPlayed = key;
          final path = _settings.adhanFiles[p.name];
          if (path != null) _adhan.play(path, volume: _settings.volumeFor(p.name));
        }
      }
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await LocationService.getCurrent();

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.error;
      });
      return;
    }

    _lat = result.lat;
    _lng = result.lng;
    await AlarmService.cacheLocation(result.lat!, result.lng!);
    _recalc();
    setState(() => _loading = false);
  }

  void _recalc() {
    if (_lat == null || _lng == null) return;

    final now = DateTime.now();
    _lastCalcDate = DateTime(now.year, now.month, now.day);

    final result = PrayerService.calculate(
      lat: _lat!,
      lng: _lng!,
      settings: _settings,
    );

    _prayers = result.prayers;
    _tomorrowFajr = result.tomorrowFajr;
    setState(() {});
    _scheduleAlarms();
  }

  PrayerItem? _nextPrayer() {
    for (final p in _prayers) {
      if (p.name == PrayerNames.sunrise) continue;
      if (p.time.isAfter(_now)) return p;
    }

    if (_tomorrowFajr != null) {
      return PrayerItem(
        name: PrayerNames.fajr,
        time: _tomorrowFajr!,
        icon: Icons.nightlight_round,
      );
    }
    return null;
  }

  Duration _remaining() {
    final next = _nextPrayer();
    if (next == null) return Duration.zero;
    final d = next.time.difference(_now);
    return d.isNegative ? Duration.zero : d;
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => SettingsSheet(
        settings: _settings,
        adhanService: _adhan,
        onChanged: () {},
        onSave: () async {
          await _saveSettings();
          _recalc();
          if (_settings.adhanEnabled && await PermissionService.needsSetup()) {
            _showBackgroundPermissionDialog();
          }
        },
        onPickFile: (name) async {
          final path = await _adhan.pickAndCopy(name);
          if (path != null) {
            setState(() => _settings.adhanFiles[name] = path);
            await _saveSettings();
          }
        },
        onRemoveFile: (name) async {
          setState(() => _settings.adhanFiles[name] = null);
          await _saveSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawerpage(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('مواقيت الصلاة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocation,
          ),
        ],
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('جاري تحديد الموقع...', style: TextStyle(fontSize: 20)),
          ],
        ),
      );
    }

    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _fetchLocation);
    }

    final next = _nextPrayer();
    final remaining = _remaining();

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          TimeFormatter.hijri(_now),
          style: const TextStyle(fontSize: 18, color: AppColors.primary),
        ),
        const SizedBox(height: 5),
        Text(
          TimeFormatter.date(_now),
          style: const TextStyle(fontSize: 15, color: Colors.white54),
        ),
        const SizedBox(height: 15),
        Text(
          TimeFormatter.time(_now, use24: _settings.use24Hour),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        NextPrayerCard(
          prayer: next,
          remaining: remaining,
          use24: _settings.use24Hour,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _prayers.length,
            itemBuilder: (_, i) {
              final p = _prayers[i];
              final isNext = p.name == next?.name && p.time == next?.time;
              final isPassed = p.time.isBefore(_now) && !isNext;

              return PrayerListItem(
                prayer: p,
                isNext: isNext,
                isPassed: isPassed,
                use24: _settings.use24Hour,
              );
            },
          ),
        ),
      ],
    );
  }
}