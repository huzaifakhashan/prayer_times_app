import 'package:flutter/material.dart';
import '../models/prayer_item.dart';
import '../utils/constants.dart';
import '../utils/time_formatter.dart';

class PrayerListItem extends StatelessWidget {
  final PrayerItem prayer;
  final bool isNext;
  final bool isPassed;
  final bool use24;

  const PrayerListItem({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.use24,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPassed ? Colors.white38 : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryDark
            : isPassed
                ? AppColors.cardDarker
                : AppColors.cardDark,
        borderRadius: BorderRadius.circular(15),
        border: isNext
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                prayer.icon,
                color: isNext
                    ? Colors.white
                    : isPassed
                        ? Colors.white30
                        : Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                prayer.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            TimeFormatter.time(prayer.time, use24: use24),
            style: TextStyle(
              fontSize: 20,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}