import 'title_box.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final DatabaseReference _uwbDatabaseRef =
      FirebaseDatabase.instance.ref("UWB/");
  final DatabaseReference _gpsDatabaseRef =
      FirebaseDatabase.instance.ref("GPS/");

  // UWB data
  Map<String, String> uwbData = {"x": "Loading...", "y": "Loading..."};
  bool isUwbConnected = false;
  String uwbConnectionError = "";

  // GPS data
  Map<String, dynamic> gpsData = {
    "latitude": 37.422, // Default coordinate (Google HQ)
    "longitude": -122.084, // Default coordinate (Google HQ)
    "connected": false,
    "error": ""
  };

  // Google Maps Controller
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateMapMarker();
  }

  // Toggle state
  bool showGpsView = false;

  // Store parsed coordinates for the UWB grid
  double xCoord = 0;
  double yCoord = 0;

  // Define grid size and scale factors
  final double gridSize = 250;
  final double maxX = 150; // Adjust based on max expected value
  final double maxY = 150; // Adjust based on max expected value

  @override
  void initState() {
    super.initState();
    print("Initializing location page");
    _listenToUwbDatabase();
    _listenToGpsDatabase();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void _listenToUwbDatabase() {
    print("Setting up UWB location database listener");

    // First try to get the data once
    _uwbDatabaseRef.get().then((DataSnapshot snapshot) {
      print("One-time UWB location data fetch result: ${snapshot.value}");
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _updateUwbData(data);
      } else {
        print("No UWB location data available");
        setState(() {
          uwbConnectionError = "No data found at the specified path";
        });
      }
    }).catchError((error) {
      print("Error fetching UWB location data: $error");
      setState(() {
        uwbConnectionError = "Error: $error";
      });
    });

    // Then set up ongoing listener
    _uwbDatabaseRef.onValue.listen(
      (DatabaseEvent event) {
        print("UWB location database event received: ${event.snapshot.value}");
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        _updateUwbData(data);
      },
      onError: (error) {
        print("Error listening to UWB location database: $error");
        setState(() {
          uwbConnectionError = "Error: $error";
        });
      },
    );
  }

  void _updateUwbData(Map<dynamic, dynamic>? data) {
    if (data != null) {
      print("Processing UWB location data: $data");
      setState(() {
        // Update text display values
        uwbData = {
          "x": data["x"]?.toString() ?? "No data",
          "y": data["y"]?.toString() ?? "No data"
        };

        // Parse for grid positioning
        xCoord = double.tryParse(data["x"]?.toString() ?? "0") ?? 0;
        yCoord = double.tryParse(data["y"]?.toString() ?? "0") ?? 0;

        isUwbConnected = true;
        uwbConnectionError = "";
      });
      print("State updated with UWB location: {x: $xCoord, y: $yCoord}");
    } else {
      print("UWB location data is null");
    }
  }

  void _listenToGpsDatabase() {
    print("Setting up GPS location database listener");

    // First try to get the data once
    _gpsDatabaseRef.get().then((DataSnapshot snapshot) {
      print("One-time GPS location data fetch result: ${snapshot.value}");
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        _updateGpsData(data);
      } else {
        print("No GPS location data available");
        setState(() {
          gpsData["connected"] = false;
          gpsData["error"] = "No GPS data found at the specified path";
        });
      }
    }).catchError((error) {
      print("Error fetching GPS location data: $error");
      setState(() {
        gpsData["connected"] = false;
        gpsData["error"] = "Error: $error";
      });
    });

    // Then set up ongoing listener
    _gpsDatabaseRef.onValue.listen(
      (DatabaseEvent event) {
        print("GPS location database event received: ${event.snapshot.value}");
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        _updateGpsData(data);
      },
      onError: (error) {
        print("Error listening to GPS location database: $error");
        setState(() {
          gpsData["connected"] = false;
          gpsData["error"] = "Error: $error";
        });
      },
    );
  }

  void _updateGpsData(Map<dynamic, dynamic>? data) {
    if (data != null) {
      print("Processing GPS location data: $data");
      setState(() {
        // Parse latitude and longitude
        gpsData["latitude"] =
            double.tryParse(data["latitude"]?.toString() ?? "0") ?? 0;
        gpsData["longitude"] =
            double.tryParse(data["longitude"]?.toString() ?? "0") ?? 0;
        gpsData["connected"] = true;
        gpsData["error"] = "";
      });
      print(
          "State updated with GPS location: {lat: ${gpsData["latitude"]}, lng: ${gpsData["longitude"]}}");

      // Update map marker and camera position if map is initialized
      _updateMapMarker();
    } else {
      print("GPS location data is null");
    }
  }

  void _updateMapMarker() {
    if (mapController != null) {
      // Move camera to the new position
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(gpsData["latitude"], gpsData["longitude"]),
        ),
      );

      // Update marker
      setState(() {
        markers = {
          Marker(
            markerId: const MarkerId('robotLocation'),
            position: LatLng(gpsData["latitude"], gpsData["longitude"]),
            infoWindow: const InfoWindow(title: 'Robot Location'),
          ),
        };
      });
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
            padding: const EdgeInsets.only(top: 1.0),
            child: TitleBox(
              title: "Robot Location",
              icon: Icons.location_on,
            ),
          ),

          // Toggle Switch
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.deepOrange.shade600,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // UWB Toggle
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showGpsView = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: !showGpsView
                              ? Colors.deepOrange.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "UWB",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: !showGpsView
                                  ? Colors.deepOrange.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // GPS Toggle
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showGpsView = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: showGpsView
                              ? Colors.deepOrange.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "GPS",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: showGpsView
                                  ? Colors.deepOrange.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content based on selected view
          Expanded(
            child: showGpsView ? _buildGpsView() : _buildUwbView(),
          ),
        ],
      ),
    );
  }

  Widget _buildUwbView() {
    return Column(
      children: [
        // Connection error indicator
        if (!isUwbConnected && uwbConnectionError.isNotEmpty)
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
                    uwbConnectionError,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),

        // Coordinate Box (combined X and Y)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
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
                      uwbData["x"] ?? "Loading...",
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
                      uwbData["y"] ?? "Loading...",
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

        // Grid visualization
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: gridSize,
            height: gridSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade800, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomPaint(
              painter: GridPainter(
                xCoord: xCoord,
                yCoord: yCoord,
                maxX: maxX,
                maxY: maxY,
              ),
              size: Size(gridSize, gridSize),
            ),
          ),
        ),

        // Debug refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              print("Manual UWB location refresh requested");
              _uwbDatabaseRef.get().then((snapshot) {
                print("Manual UWB location fetch result: ${snapshot.value}");
                final data = snapshot.value as Map<dynamic, dynamic>?;
                _updateUwbData(data);
              }).catchError((error) {
                print("Manual UWB location fetch error: $error");
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: Text("Refresh UWB Data"),
          ),
        ),

        // Spacer to push content up and keep the button at the bottom
        Expanded(child: Container()),
      ],
    );
  }

  Widget _buildGpsView() {
    return Column(
      children: [
        // Connection error indicator
        if (!gpsData["connected"] && gpsData["error"].isNotEmpty)
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
                    gpsData["error"],
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),

        // Coordinate Box (combined Lat and Long)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
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
                      "Latitude: ",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      gpsData["latitude"].toString(),
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
                      "Longitude: ",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      gpsData["longitude"].toString(),
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

        // Map visualization
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade800, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: gpsData["connected"]
                  ? GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target:
                            LatLng(gpsData["latitude"], gpsData["longitude"]),
                        zoom: 15.0,
                      ),
                      markers: markers,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      mapType: MapType.normal,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_sharp, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "GPS data not available",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),

        // Debug refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ElevatedButton(
            onPressed: () {
              print("Manual GPS location refresh requested");
              _gpsDatabaseRef.get().then((snapshot) {
                print("Manual GPS location fetch result: ${snapshot.value}");
                final data = snapshot.value as Map<dynamic, dynamic>?;
                _updateGpsData(data);
              }).catchError((error) {
                print("Manual GPS location fetch error: $error");
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: Text("Refresh GPS Data"),
          ),
        ),
      ],
    );
  }
}

// Custom painter for drawing the grid and position marker
class GridPainter extends CustomPainter {
  final double xCoord;
  final double yCoord;
  final double maxX;
  final double maxY;

  GridPainter({
    required this.xCoord,
    required this.yCoord,
    required this.maxX,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / 10;
    final double cellHeight = size.height / 10;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 10; i++) {
      double y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 10; i++) {
      double x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Calculate robot position on grid
    final double xPos = (xCoord / maxX) * size.width;
    // Invert Y coordinate because screen coordinates increase downward
    final double yPos = size.height - (yCoord / maxY) * size.height;

    // Draw position marker (robot location)
    final markerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(xPos, yPos), 8, markerPaint);

    // Draw border ring around marker
    final markerBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(xPos, yPos), 8, markerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint when new data comes in
  }
}
