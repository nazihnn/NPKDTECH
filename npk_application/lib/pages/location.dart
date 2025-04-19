import 'title_box.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 25.0), // Adjust the top padding as needed
            child: TitleBox(
              title: "Robot Location",
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "coordinates:",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
