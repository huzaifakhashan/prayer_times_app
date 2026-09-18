import 'package:adhan_dart/adhan_dart.dart';
import '../models/app_settings.dart';
import '../models/prayer_item.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';

class PrayerResult {
  final List<PrayerItem> prayers;
  final DateTime tomorrowFajr;

  PrayerResult(this.prayers, this.tomorrowFajr);
}

class PrayerService {
  static CalculationParameters _paramsFor(CalcMethod m) {
    switch (m) {
      case CalcMethod.muslimWorldLeague:
        return CalculationMethodParameters.muslimWorldLeague();
      case CalcMethod.egyptian:
        return CalculationMethodParameters.egyptian();
      case CalcMethod.karachi:
        return CalculationMethodParameters.karachi();
      case CalcMethod.ummAlQura:
        return CalculationMethodParameters.ummAlQura();
      case CalcMethod.dubai:
        return CalculationMethodParameters.dubai();
      case CalcMethod.qatar:
        return CalculationMethodParameters.qatar();
      case CalcMethod.kuwait:
        return CalculationMethodParameters.kuwait();
      case CalcMethod.turkey:
        return CalculationMethodParameters.turkiye();
    }
  }

  static List<PrayerItem> forDate({
    required double lat,
    required double lng,
    required AppSettings settings,
    required DateTime date,
  }) {
    final coords = Coordinates(lat, lng);
    final params = _paramsFor(settings.method)..madhab = settings.madhab;

    final times = PrayerTimes(
      coordinates: coords,
      date: date,
      calculationParameters: params,
      precision: false,
    );

    final fajr = times.fajr.toLocal();
    final sunrise = times.sunrise.toLocal();
    final dhuhr = times.dhuhr.toLocal();
    final asr = times.asr.toLocal();
    final maghrib = times.maghrib.toLocal();
    final isha = times.isha.toLocal();

    return <PrayerItem>[
      PrayerItem(name: PrayerNames.fajr, time: fajr, icon: Icons.nightlight_round),
      if (settings.showSunrise)
        PrayerItem(name: PrayerNames.sunrise, time: sunrise, icon: Icons.wb_sunny),
      PrayerItem(name: PrayerNames.dhuhr, time: dhuhr, icon: Icons.wb_sunny_outlined),
      PrayerItem(name: PrayerNames.asr, time: asr, icon: Icons.cloud_outlined),
      PrayerItem(name: PrayerNames.maghrib, time: maghrib, icon: Icons.wb_twilight),
      PrayerItem(name: PrayerNames.isha, time: isha, icon: Icons.nights_stay),
    ];
  }

  static PrayerResult calculate({
    required double lat,
    required double lng,
    required AppSettings settings,
  }) {
    final now = DateTime.now();
    final list = forDate(lat: lat, lng: lng, settings: settings, date: now);

    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowList = forDate(lat: lat, lng: lng, settings: settings, date: tomorrow);
    final tomorrowFajr = tomorrowList.firstWhere((p) => p.name == PrayerNames.fajr).time;

    return PrayerResult(list, tomorrowFajr);
  }
}