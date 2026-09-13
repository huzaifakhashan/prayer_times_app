import 'package:flutter/material.dart';
import '../models/prayer_item.dart';
import '../utils/constants.dart';
import '../utils/time_formatter.dart';

class NextPrayerCard extends StatelessWidget {
  final PrayerItem? prayer;
  final Duration remaining;
  final bool use24;

  const NextPrayerCard({
    super.key,
    required this.prayer,
    required this.remaining,
    required this.use24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMed],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('الصلاة القادمة',
              style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(prayer?.icon ?? Icons.access_time,
                  size: 32, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                prayer?.name ?? '--',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prayer == null ? '--:--' : TimeFormatter.time(prayer!.time, use24: use24),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              TimeFormatter.duration(remaining),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}