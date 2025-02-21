import 'package:flutter/material.dart';

class TitleBox extends StatelessWidget {
  final String title;

  const TitleBox({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16), // Add margin for spacing
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.lightGreen.shade300,
            Colors.green.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black38,
              offset: Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
