import 'package:flutter/material.dart';

class CalendarDayCard extends StatelessWidget {
  final String day;
  final String date;
  final bool isActive;
  final bool isToday;
  final bool hasDot;

  const CalendarDayCard({
    super.key,
    required this.day,
    required this.date,
    required this.isActive,
    this.isToday = false,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Tentukan warna latar belakang
    Color backgroundColor = Theme.of(context).cardColor;
    if (isActive) {
      backgroundColor = const Color(0xFF436155);
    } else if (isToday) {
      backgroundColor = isDark ? const Color(0xFF1B2D26) : const Color(0xFFE2ECE9);
    }

    // Tentukan border
    Border border = Border.all(
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
    );
    if (isActive) {
      border = Border.all(color: Colors.transparent);
    } else if (isToday) {
      border = Border.all(
        color: isDark ? const Color(0xFF7C9A92).withOpacity(0.4) : const Color(0xFF436155).withOpacity(0.3),
        width: 1.5,
      );
    }

    // Tentukan warna teks hari
    Color dayTextColor = isDark ? Colors.grey[400]! : Colors.grey;
    if (isActive) {
      dayTextColor = Colors.white70;
    } else if (isToday) {
      dayTextColor = isDark ? const Color(0xFF7C9A92) : const Color(0xFF436155);
    }

    // Tentukan warna teks tanggal
    Color dateTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    if (isActive) {
      dateTextColor = Colors.white;
    } else if (isToday) {
      dateTextColor = isDark ? const Color(0xFF7C9A92) : const Color(0xFF436155);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              color: dayTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: dateTextColor,
            ),
          ),
          if (hasDot && !isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF436155),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
