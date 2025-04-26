import 'title_box.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("UWB/");
  Map<String, String> locationData = {"x": "Loading...", "y": "Loading..."};
  bool isConnected = false;
  String connectionError = "";

  @override
  void initState() {
    super.initState();
    print("Initializing location page");
    _listenToDatabase();
  }

  void _listenToDatabase() {
    print("Setting up location database listener");

    // First try to get the data once
    _databaseRef.get().then((DataSnapshot snapshot) {
      print("One-time location data fetch result: ${snapshot.value}");
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _updateData(data);
      } else {
        print("No location data available");
        setState(() {
          connectionError = "No data found at the specified path";
        });
      }
    }).catchError((error) {
      print("Error fetching location data: $error");
      setState(() {
        connectionError = "Error: $error";
      });
    });

    // Then set up ongoing listener
    _databaseRef.onValue.listen(
      (DatabaseEvent event) {
        print("Location database event received: ${event.snapshot.value}");
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        _updateData(data);
      },
      onError: (error) {
        print("Error listening to location database: $error");
        setState(() {
          connectionError = "Error: $error";
        });
      },
    );
  }

  void _updateData(Map<dynamic, dynamic>? data) {
    if (data != null) {
      print("Processing location data: $data");
      setState(() {
        locationData = {
          "x": data["x"]?.toString() ?? "No data",
          "y": data["y"]?.toString() ?? "No data"
        };
        isConnected = true;
        connectionError = "";
      });
      print("State updated with location: $locationData");
    } else {
      print("Location data is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFA8E063),
            Color.fromARGB(255, 187, 221, 172)
          ], // lime to green
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Title Box
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: TitleBox(
              title: "Robot Location",
              icon: Icons.location_on,
            ),
          ),

          // Connection error indicator
          if (!isConnected && connectionError.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      connectionError,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),

          // Coordinate Box (combined X and Y)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                        locationData["x"] ?? "Loading...",
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
                        locationData["y"] ?? "Loading...",
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

          // Map Title Box (you can keep or remove this as needed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                "Current Location", // Changed from "Map Title Here"
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Debug refresh button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                print("Manual location refresh requested");
                _databaseRef.get().then((snapshot) {
                  print("Manual location fetch result: ${snapshot.value}");
                  final data = snapshot.value as Map<dynamic, dynamic>?;
                  _updateData(data);
                }).catchError((error) {
                  print("Manual location fetch error: $error");
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text("Refresh Location Data"),
            ),
          ),

          // Spacer to push content up and keep the button at the bottom
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
