import 'package:hijri/hijri_calendar.dart';

class TimeFormatter {
  static String time(DateTime t, {bool use24 = false}) {
    if (use24) {
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
    }

    var h = t.hour;
    final period = h >= 12 ? 'م' : 'ص';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  static String duration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  static String hijri(DateTime d) {
    final h = HijriCalendar.fromDate(d);
    const months = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
      'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    return '${h.hDay} ${months[h.hMonth - 1]} ${h.hYear} هـ';
  }
}