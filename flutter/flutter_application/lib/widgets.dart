import 'package:flutter/material.dart';

class NeumorphicIconButton extends StatelessWidget {
  final IconData icon;
  const NeumorphicIconButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.08).toInt()),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF718096), size: 20),
    );
  }
}

class PillTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const PillTag({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
