import 'package:adhan_dart/adhan_dart.dart';
import '../utils/constants.dart';

enum CalcMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  qatar,
  kuwait,
  turkey,
}

class AppSettings {
  Madhab madhab;
  CalcMethod method;
  bool showSunrise;
  bool use24Hour;
  bool adhanEnabled;
  Map<String, String?> adhanFiles;
  Map<String, double> adhanVolumes;

  AppSettings({
    this.madhab = Madhab.shafi,
    this.method = CalcMethod.muslimWorldLeague,
    this.showSunrise = true,
    this.use24Hour = false,
    this.adhanEnabled = true,
    Map<String, String?>? adhanFiles,
    Map<String, double>? adhanVolumes,
  })  : adhanFiles = adhanFiles ?? {},
        adhanVolumes = adhanVolumes ?? {};

  double volumeFor(String prayer) => adhanVolumes[prayer] ?? 1.0;

  static const adhanPrayers = PrayerNames.adhanList;
}