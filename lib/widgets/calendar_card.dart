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
    // Tentukan warna latar belakang
    Color backgroundColor = Colors.white;
    if (isActive) {
      backgroundColor = const Color(0xFF436155);
    } else if (isToday) {
      backgroundColor = const Color(0xFFE2ECE9); // Hijau muda soft untuk menandakan hari ini
    }

    // Tentukan border
    Border border = Border.all(color: Colors.grey.withOpacity(0.15));
    if (isActive) {
      border = Border.all(color: Colors.transparent);
    } else if (isToday) {
      border = Border.all(color: const Color(0xFF436155).withOpacity(0.3), width: 1.5);
    }

    // Tentukan warna teks hari
    Color dayTextColor = Colors.grey;
    if (isActive) {
      dayTextColor = Colors.white70;
    } else if (isToday) {
      dayTextColor = const Color(0xFF436155);
    }

    // Tentukan warna teks tanggal
    Color dateTextColor = Colors.black87;
    if (isActive) {
      dateTextColor = Colors.white;
    } else if (isToday) {
      dateTextColor = const Color(0xFF436155);
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
