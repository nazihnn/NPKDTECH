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
              // Title Box
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: TitleBox(
                  title: "Robot Location",
                  icon: Icons.location_on,
                ),
              ),

              // Coordinate Box (combined X and Y)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepOrange.shade600,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "X Coordinate: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "23.5567", // Replace with dynamic data
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // Spacing between rows
                      Row(
                        children: [
                          Text(
                            "Y Coordinate: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "45.6678", // Replace with dynamic data
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Map Title Box
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepOrange.shade600,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    "Map Title Here", // Replace with actual map title
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              // Spacer to push content up and keep the button at the bottom
              Expanded(child: Container()),
            ],
          ),

          // Home Button
          Positioned(
            bottom: 16.0,
            left: 16.0,
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
