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
      FirebaseDatabase.instance.ref("Outside/");

  // UWB data
  Map<String, String> uwbData = {"x": "Loading...", "y": "Loading..."};
  bool isUwbConnected = false;
  String uwbConnectionError = "";

  // GPS data
  Map<String, dynamic> gpsData = {
    "latitude": 0.0,
    "longitude": 0.0,
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
  final double maxX = 150;
  final double maxY = 150;

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
    print("Setting up GPS location database listener from Outside node");

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

      // Extract latitude and longitude directly from Outside node
      final latitudeStr = data["latitude"]?.toString() ?? "0.0";
      final longitudeStr = data["longitude"]?.toString() ?? "0.0";
      print(
          "Processing GPS location data after changing to string: $longitudeStr");
      print(
          "Processing GPS location data after changing to string: $latitudeStr");
      // Convert to numbers and remove quotes if present
      final latitudeClean = latitudeStr.replaceAll('"', '');
      final longitudeClean = longitudeStr.replaceAll('"', '');

      setState(() {
        // Parse latitude and longitude
        gpsData["latitude"] = double.tryParse(latitudeClean) ?? 0;
        gpsData["longitude"] = double.tryParse(longitudeClean) ?? 0;
        print("Longitude string before parsing: '$longitudeClean'");
        final parsedLongitude = double.tryParse(longitudeClean);
        print("Parsed longitude result: $parsedLongitude");

        // Only mark as connected if we have non-zero coordinates
        final hasValidCoordinates =
            gpsData["latitude"] != 0 || gpsData["longitude"] != 0;

        gpsData["connected"] = hasValidCoordinates;
        gpsData["error"] = hasValidCoordinates
            ? ""
            : "GPS coordinates are (0,0). Waiting for valid data.";
      });
      print("Longitude immediately after assignment: ${gpsData["longitude"]}");
      print(
          "State updated with GPS location: {lat: ${gpsData["latitude"]}, lng: ${gpsData["longitude"]}}");

      // Update map marker and camera position if map is initialized
      _updateMapMarker();
    } else {
      print("GPS location data is null");
    }
  }

  void _updateMapMarker() {
    if (mapController != null && gpsData["connected"]) {
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
            Color(0xFF68BB7D),
            Color(0xFFA8E063),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with title and icon
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
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
                      Icons.location_on,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Robot Location",
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

            // Toggle Switch
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
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
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: !showGpsView
                                ? Colors.orange.shade600
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.share_location,
                                  color: !showGpsView
                                      ? Colors.white
                                      : Colors.white70,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "UWB",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: !showGpsView
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !showGpsView
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ],
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
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: showGpsView
                                ? Colors.orange.shade600
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  color: showGpsView
                                      ? Colors.white
                                      : Colors.white70,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "GPS",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: showGpsView
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: showGpsView
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildUwbView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Connection error indicator
          if (!isUwbConnected && uwbConnectionError.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      uwbConnectionError,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // Coordinate Card
          Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UWB Coordinates",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                Divider(height: 24, thickness: 1, color: Colors.grey.shade200),
                _buildCoordinateRow("X", uwbData["x"] ?? "Loading..."),
                SizedBox(height: 12),
                _buildCoordinateRow("Y", uwbData["y"] ?? "Loading..."),
              ],
            ),
          ),

          // Grid visualization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: EnhancedGridPainter(
                    xCoord: xCoord,
                    yCoord: yCoord,
                    maxX: maxX,
                    maxY: maxY,
                  ),
                  size: Size(gridSize, gridSize),
                ),
              ),
            ),
          ),

          // Refresh button
          Container(
            margin: const EdgeInsets.only(top: 24.0),
            width: double.infinity,
            child: ElevatedButton.icon(
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
              icon: Icon(Icons.refresh),
              label: Text("Refresh UWB Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Connection error indicator
          if (!gpsData["connected"] && gpsData["error"].isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gpsData["error"],
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // Coordinate Card
          Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GPS Coordinates",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                Divider(height: 24, thickness: 1, color: Colors.grey.shade200),
                _buildCoordinateRow("Latitude", gpsData["latitude"].toString()),
                SizedBox(height: 12),
                _buildCoordinateRow(
                    "Longitude", gpsData["longitude"].toString()),
              ],
            ),
          ),

          // Map visualization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                    : Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "GPS data not available",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Waiting for location data...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Refresh button
          Container(
            margin: const EdgeInsets.only(top: 24.0),
            width: double.infinity,
            child: ElevatedButton.icon(
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
              icon: Icon(Icons.refresh),
              label: Text("Refresh GPS Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey.shade600,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto Mono',
              color: Colors.blueGrey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced custom painter for drawing the grid and position marker
class EnhancedGridPainter extends CustomPainter {
  final double xCoord;
  final double yCoord;
  final double maxX;
  final double maxY;

  EnhancedGridPainter({
    required this.xCoord,
    required this.yCoord,
    required this.maxX,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    final bgPaint = Paint()..color = Colors.grey.shade50;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.blueGrey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    final double cellWidth = size.width / 10;
    final double cellHeight = size.height / 10;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.blueGrey.shade100
      ..strokeWidth = 0.8;

    // Draw axes with darker color
    final axesPaint = Paint()
      ..color = Colors.blueGrey.shade300
      ..strokeWidth = 1.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 10; i++) {
      double y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        i == 5 ? axesPaint : gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 10; i++) {
      double x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        i == 5 ? axesPaint : gridPaint,
      );
    }

    // Calculate robot position on grid
    final double xPos = (xCoord / maxX) * size.width;
    // Invert Y coordinate because screen coordinates increase downward
    final double yPos = size.height - (yCoord / maxY) * size.height;

    // Draw position marker with drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(xPos, yPos + 2), 12, shadowPaint);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = Colors.orange.shade200.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(xPos, yPos), 16, glowPaint);

    // Draw position marker (robot location)
    final markerPaint = Paint()
      ..color = Colors.orange.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(xPos, yPos), 10, markerPaint);

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(xPos, yPos), 4, innerCirclePaint);

    // Add coordinate labels at edges
    final textStyle = TextStyle(
      color: Colors.blueGrey.shade700,
      fontSize: 10,
    );
    final textSpan = TextSpan(
      text: '0',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw X-axis labels
    for (int i = 0; i <= 10; i++) {
      if (i % 2 == 0) {
        final value = (i * maxX / 10).toInt().toString();
        final textSpan = TextSpan(text: value, style: textStyle);
        textPainter.text = textSpan;
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(i * cellWidth - textPainter.width / 2, size.height + 4),
        );
      }
    }

    // Draw Y-axis labels
    for (int i = 0; i <= 10; i++) {
      if (i % 2 == 0) {
        final value = (i * maxY / 10).toInt().toString();
        final textSpan = TextSpan(text: value, style: textStyle);
        textPainter.text = textSpan;
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(-textPainter.width - 4,
              size.height - i * cellHeight - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint when new data comes in
  }
}
