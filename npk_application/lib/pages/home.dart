import 'title_box.dart';
import '../auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firebase data map
  Map<String, dynamic> _weatherData = {
    "cel": "Loading...",
    "far": "Loading...",
    "humidity": "Loading...",
    "speed": "Loading...", // Adding the speed variable
  };

  // // Original dummy data
  // final List<Map<String, String>> _dummyData = [
  //   {"title": "Location", "value": "45.123, -93.456"},
  //   {"title": "Nitrogen", "value": "23.5"},
  //   {"title": "Phosphate", "value": "15.8"},
  //   {"title": "Potassium", "value": "30.2"},
  // ];

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  // Method to fetch data from Firebase
  Future<void> _fetchWeatherData() async {
    try {
      final ref =
          FirebaseDatabase.instance.ref('Outside'); // Adjust path if needed
      final snapshot = await ref.get();

      if (snapshot.exists) {
        setState(() {
          // Update our local data with Firebase values
          Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);
          _weatherData["cel"] = data["cel"] ?? "N/A";
          _weatherData["far"] = data["far"] ?? "N/A";
          _weatherData["humidity"] = data["humidity"] ?? "N/A";
          _weatherData["speed"] = data["speed"] ?? "N/A"; // Get speed value
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Combined data for display
  List<Map<String, String>> get _combinedData {
    return [
      {"title": "Temperature (°C)", "value": _weatherData["cel"]},
      {"title": "Temperature (°F)", "value": _weatherData["far"]},
      {"title": "Humidity (%)", "value": _weatherData["humidity"]},
      {"title": "Speed", "value": _weatherData["speed"]},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E063), Color.fromARGB(255, 187, 221, 172)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const TitleBox(title: "Robot ID", icon: Icons.home),
            const SizedBox(height: 16.0),

            // Refresh button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: _fetchWeatherData,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8.0),

            // Data Snippets in Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: _combinedData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 16.0, // Spacing between columns
                    mainAxisSpacing: 16.0, // Spacing between rows
                    childAspectRatio: 1.2, // Adjust for better fit
                  ),
                  itemBuilder: (context, index) {
                    final data = _combinedData[index];
                    return _buildDataBox(data["title"]!, data["value"]!);
                  },
                ),
              ),
            ),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepOrange.shade600,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
