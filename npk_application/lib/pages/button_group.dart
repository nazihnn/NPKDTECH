import 'package:flutter/material.dart';
import 'location.dart';
import 'sensor.dart';
import 'status.dart';

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
              backgroundColor: const Color.fromARGB(255, 73, 124, 14),
              foregroundColor: Colors.black54,
            ),
            child: const Text(
              "Track Robot Location",
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SensorPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(400, 100),
              backgroundColor: const Color.fromARGB(255, 73, 124, 14),
              foregroundColor: Colors.black54,
            ),
            child: const Text(
              "Check Latest Data",
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatusPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(400, 100),
              backgroundColor: const Color.fromARGB(255, 73, 124, 14),
              foregroundColor: Colors.black54,
            ),
            child: const Text(
              "Robot Status",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
