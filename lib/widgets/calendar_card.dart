import 'package:flutter/material.dart';

class CalendarDayCard extends StatelessWidget {
  final String day;
  final String date;
  final bool isActive;
  final bool hasDot;

  const CalendarDayCard({
    super.key,
    required this.day,
    required this.date,
    required this.isActive,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF436155) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.white70 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
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
