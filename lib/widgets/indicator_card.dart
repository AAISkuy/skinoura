import 'package:flutter/material.dart';

class IndicatorCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const IndicatorCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF436155), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
