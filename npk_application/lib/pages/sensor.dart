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

  // Add maps for storing units and colors
  final Map<String, String> _units = {
    "moisture": "%",
    "nitrogen": "mg/kg",
    "phosphorus": "mg/kg",
    "potassium": "mg/kg"
  };

  // Add icons for each parameter
  final Map<String, IconData> _icons = {
    "moisture": Icons.water_drop,
    "nitrogen": Icons.grass,
    "phosphorus": Icons.science,
    "potassium": Icons.emoji_nature
  };

  // Colors for each parameter
  final Map<String, Color> _colors = {
    "moisture": Colors.blue,
    "nitrogen": Colors.green.shade700,
    "phosphorus": Colors.orange,
    "potassium": Colors.purple
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

  String _getDisplayValue(String parameter, String value) {
    if (value == "Loading..." || value == "No data") {
      return value;
    }
    return "$value ${_units[parameter]}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF68BB7D),
            Color(0xFFA8E063),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Title Box
          Padding(
            padding: const EdgeInsets.only(top: 70.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sensors,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Soil Data",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Connection status indicator
          if (!isConnected)
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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

          // Data cards in a grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDataCard("nitrogen", "Nitrogen"),
                  _buildDataCard("phosphorus", "Phosphorus"),
                  _buildDataCard("potassium", "Potassium"),
                  _buildDataCard("moisture", "Moisture"),
                ],
              ),
            ),
          ),

          // Refresh button with better styling
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                print("Manual data refresh requested");
                _databaseRef.get().then((snapshot) {
                  print("Manual data fetch result: ${snapshot.value}");
                  final data = snapshot.value as Map<dynamic, dynamic>?;
                  _updateData(data);
                }).catchError((error) {
                  print("Manual fetch error: $error");
                });
              },
              icon: Icon(Icons.refresh),
              label: Text("Refresh Soil Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                minimumSize:
                    Size(double.infinity, 0), // Makes button full width
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataCard(String parameter, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with colored circle background
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _colors[parameter]!.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icons[parameter],
              size: 32,
              color: _colors[parameter],
            ),
          ),
          SizedBox(height: 8),
          // Parameter label
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          // Value with units
          Text(
            _getDisplayValue(parameter, npkData[parameter] ?? "Loading..."),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: _colors[parameter],
            ),
          ),
        ],
      ),
    );
  }
}
