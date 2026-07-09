import 'package:flutter/material.dart';
import 'package:skinoura/theme/theme_color.dart';

class BarChartCard extends StatelessWidget {
  final String day;
  final double percentage;

  const BarChartCard({super.key, required this.day, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F7),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (percentage / 100) * 60,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
