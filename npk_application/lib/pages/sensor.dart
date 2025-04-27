import 'dart:async';
import 'title_box.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore_for_file: avoid_print

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("NPK/");
  StreamSubscription<DatabaseEvent>? _subscription;
  Map<String, String> npkData = {
    "moisture": "Loading...",
    "nitrogen": "Loading...",
    "phosphorus": "Loading...",
    "potassium": "Loading..."
  };
  bool isConnected = false;
  String connectionError = "";

  @override
  void initState() {
    super.initState();
    print("Initializing sensor page");
    _checkConnection();
    _listenToDatabase();
  }

  void _checkConnection() {
    print("Checking database connection");
    FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
      bool connected = event.snapshot.value as bool? ?? false;
      print("Firebase connection status: $connected");
      setState(() {
        isConnected = connected;
      });
    });
  }

  void _listenToDatabase() {
    print("Setting up database listener");

    // First try to get the data once
    _databaseRef.get().then((DataSnapshot snapshot) {
      print("One-time data fetch result: ${snapshot.value}");
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _updateData(data);
      } else {
        print("No data available at ${_databaseRef.path}");
        setState(() {
          connectionError = "No data found at the specified path";
        });
      }
    }).catchError((error) {
      print("Error fetching data: $error");
      setState(() {
        connectionError = "Error: $error";
      });
    });

    // Then set up ongoing listener
    _subscription = _databaseRef.onValue.listen(
      (DatabaseEvent event) {
        print("Database event received: ${event.snapshot.value}");
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        _updateData(data);
      },
      onError: (error) {
        print("Error listening to database: $error");
        setState(() {
          connectionError = "Error: $error";
        });
      },
    );
  }

  void _updateData(Map<dynamic, dynamic>? data) {
    if (data != null) {
      print("Processing data: $data");
      setState(() {
        npkData = {
          "moisture": data["moisture"]?.toString() ?? "No data",
          "nitrogen": data["nitrogen"]?.toString() ?? "No data",
          "phosphorus": data["phosphorus"]?.toString() ?? "No data",
          "potassium": data["potassium"]?.toString() ?? "No data"
        };
        connectionError = "";
      });
      print("State updated with: $npkData");
    } else {
      print("Data is null");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA8E063), Color.fromARGB(255, 187, 221, 172)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Title Box
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: TitleBox(
              title: "Soil Data",
              icon: Icons.sensors,
            ),
          ),

          // Connection status indicator
          if (!isConnected)
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
                      connectionError.isEmpty
                          ? "Not connected to database"
                          : connectionError,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Data boxes
          _buildDataBox("Nitrogen", npkData["nitrogen"] ?? "Loading..."),
          const SizedBox(height: 10),
          _buildDataBox("Phosphorus", npkData["phosphorus"] ?? "Loading..."),
          const SizedBox(height: 10),
          _buildDataBox("Potassium", npkData["potassium"] ?? "Loading..."),
          const SizedBox(height: 10),
          _buildDataBox("Moisture", npkData["moisture"] ?? "Loading..."),

          // Debug button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                print("Manual data refresh requested");
                _databaseRef.get().then((snapshot) {
                  print("Manual data fetch result: ${snapshot.value}");
                }).catchError((error) {
                  print("Manual fetch error: $error");
                });
              },
              child: Text("Debug: Refresh Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataBox(String label, String value) {
    return Padding(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
