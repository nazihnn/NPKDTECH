import 'title_box.dart';
import 'dart:math' as math;
import '../auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Firebase data map
  Map<String, dynamic> _weatherData = {
    "cel": "Loading...",
    "far": "Loading...",
    "humidity": "Loading...",
    "speed": "Loading...",
  };

  // Animation controller
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to fetch data from Firebase
  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('Outside');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        setState(() {
          // Update our local data with Firebase values
          Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);
          _weatherData["cel"] = data["cel"] ?? "N/A";
          _weatherData["far"] = data["far"] ?? "N/A";
          _weatherData["humidity"] = data["humidity"] ?? "N/A";
          _weatherData["speed"] = data["speed"] ?? "N/A";
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Combined data for display
  List<Map<String, dynamic>> get _combinedData {
    return [
      {
        "title": "Temperature",
        "value": _weatherData["cel"],
        "icon": Icons.thermostat,
        "unit": "°C",
        "color": Colors.redAccent,
      },
      {
        "title": "Temperature",
        "value": _weatherData["far"],
        "icon": Icons.thermostat_outlined,
        "unit": "°F",
        "color": Colors.orangeAccent,
      },
      {
        "title": "Humidity",
        "value": _weatherData["humidity"],
        "icon": Icons.water_drop,
        "unit": "%",
        "color": Colors.blueAccent,
      },
      {
        "title": "Speed",
        "value": _weatherData["speed"],
        "icon": Icons.speed,
        "unit": "km/h",
        "color": Colors.greenAccent,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF68BB7D),
              const Color(0xFFA8E063),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar with robot icon
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _isLoading
                              ? _animationController.value * 2 * math.pi
                              : 0,
                          child: const Icon(
                            Icons.smart_toy,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Robot  Monitor",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _fetchWeatherData();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Status card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.deepOrange.shade600,
                      width: 4,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "System Status",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _isLoading
                                ? "Updating data..."
                                : "All systems operational",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Data cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GridView.builder(
                    itemCount: _combinedData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final data = _combinedData[index];
                      return _buildAnimatedDataBox(
                        data["title"],
                        data["value"],
                        data["icon"],
                        data["unit"],
                        data["color"],
                      );
                    },
                  ),
                ),
              ),

              // Sign Out Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDataBox(
      String title, String value, IconData icon, String unit, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepOrange.shade600,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Show detailed information when tapped
            _showDetailDialog(title, value, unit, icon, color);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _getWidthFactor(value, unit),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getWidthFactor(String value, String unit) {
    double numValue = double.tryParse(value.replaceAll('"', '')) ?? 0;

    switch (unit) {
      case "°C":
        return numValue / 50; // Assuming max range is about 50°C
      case "°F":
        return numValue / 120; // Assuming max range is about 120°F
      case "%":
        return numValue / 100; // Percentage directly
      case "km/h":
        return numValue / 100; // Assuming max speed is 100 km/h
      default:
        return 0.5;
    }
  }

  void _showDetailDialog(
      String title, String value, String unit, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Additional information or charts could be added here
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
