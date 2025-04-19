import 'package:flutter/material.dart';

class TitleBox extends StatelessWidget {
  final String title;
  final IconData icon; // Add an icon field to hold the passed icon

  const TitleBox({
    super.key,
    required this.title,
    required this.icon, // Add the icon parameter to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      margin: const EdgeInsets.all(16), // Add margin for spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.deepOrange.shade600,
          width: 3,
        ),
      ),
      child: Row(
        children: [
          // Icon on the left, dynamically set the icon here
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade600,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, // Use the passed icon here
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12), // Spacing between icon and text
          // Title text
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
