import 'home.dart';
import 'title_box.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 25.0), // Adjust the top padding as needed
                child:
                    TitleBox(title: "Robot Location", icon: Icons.location_on),
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
          Positioned(
            bottom: 16.0, // Distance from the bottom
            left: 16.0, // Distance from the left
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Icon(Icons.home),
            ),
          ),
        ],
      ),
    );
  }
}
