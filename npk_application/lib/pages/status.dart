import 'home.dart';
import 'title_box.dart';
import 'package:flutter/material.dart';

Color oliveGreen = Color.fromARGB(255, 143, 143, 1); // Olive green

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

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
                  title: "Status",
                  icon: Icons.start_rounded,
                ),
              ),

              // Niteroen data box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: oliveGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(221, 7, 2, 2),
                      width: 10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Current job: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "sampling", // Replace with dynamic data
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: oliveGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(221, 7, 2, 2),
                      width: 10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "control actuator ",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "move up", // Replace with dynamic data
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: oliveGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(221, 7, 2, 2),
                      width: 10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "contorl robot ",
                            style: TextStyle(fontSize: 18),
                          ),
                          // Text(
                          //   "23.5567", // Replace with dynamic data
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
