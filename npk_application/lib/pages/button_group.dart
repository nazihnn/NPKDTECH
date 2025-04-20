import 'sensor.dart';
import 'status.dart';
import 'location.dart';
import 'package:flutter/material.dart';

Color oliveGreen = Color.fromARGB(255, 143, 143, 1); // Olive green

class ButtonGroup extends StatelessWidget {
  const ButtonGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(400, 100),
              backgroundColor: Color.fromARGB(255, 247, 247, 247),
              foregroundColor: Colors.black54,
              side: BorderSide(
                color: Colors.deepOrange.shade600,
                width: 5, // Border width
              ),
            ),
            child: const Text(
              "Track Robot Location",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SensorPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(400, 100),
              backgroundColor: oliveGreen,
              foregroundColor: Colors.black54,
              side: BorderSide(
                color: const Color.fromARGB(255, 0, 0, 0), // Border color
                width: 10, // Border width
              ),
            ),
            child: const Text(
              "Check Latest Data",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatusPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(400, 100),
              backgroundColor:
                  oliveGreen, // const Color.fromARGB(255, 73, 124, 14),
              foregroundColor: Colors.black54,
              side: BorderSide(
                color: const Color.fromARGB(255, 0, 0, 0), // Border color
                width: 10, // Border width
              ),
            ),
            child: const Text(
              "Robot Status",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
