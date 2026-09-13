import 'package:flutter/material.dart';

class PrayerItem {
  final String name;
  final DateTime time;
  final IconData icon;

  const PrayerItem({
    required this.name,
    required this.time,
    this.icon = Icons.access_time,
  });
}