import 'title_box.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

Color oliveGreen = Color.fromARGB(255, 143, 143, 1); // Olive green

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("Controls/");
  String currentActuatorStatus = "idle";
  String currentJob = "idle";
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _listenToStatus();
  }

  void _listenToStatus() {
    // Listen for job status updates
    FirebaseDatabase.instance.ref("Status/job").onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          currentJob = event.snapshot.value.toString();
        });
      }
    });

    // Listen for actuator status updates
    FirebaseDatabase.instance.ref("Status/actuator").onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          currentActuatorStatus = event.snapshot.value.toString();
        });
      }
    });
  }

  void _controlActuator(String direction) {
    setState(() {
      isUpdating = true;
    });

    _databaseRef.child("actuator").set(direction).then((_) {
      setState(() {
        currentActuatorStatus = direction;
        isUpdating = false;
      });
      print("Actuator command sent: $direction");
    }).catchError((error) {
      setState(() {
        isUpdating = false;
      });
      print("Failed to send actuator command: $error");
    });
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
              title: "Status",
              icon: Icons.info,
            ),
          ),

          // Current job box
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                children: [
                  Text(
                    "Current job: ",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    currentJob,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control actuator box
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                  Text(
                    "Control actuator:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            isUpdating ? null : () => _controlActuator("up"),
                        icon: Icon(Icons.arrow_upward),
                        label: Text("Up"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            isUpdating ? null : () => _controlActuator("down"),
                        icon: Icon(Icons.arrow_downward),
                        label: Text("Down"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            isUpdating ? null : () => _controlActuator("stop"),
                        icon: Icon(Icons.stop),
                        label: Text("stop"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Current status: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            currentActuatorStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentActuatorStatus == "up"
                                  ? Colors.green
                                  : currentActuatorStatus == "down"
                                      ? Colors.blue
                                      : Colors.black,
                            ),
                          ),
                          if (isUpdating)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control robot box - leaving this as is from your original code
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          //   child: Container(
          //     padding: const EdgeInsets.all(16.0),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(
          //         color: Colors.deepOrange.shade600,
          //         width: 2,
          //       ),
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
          //             Text(
          //               "Control robot: ",
          //               style: TextStyle(fontSize: 18),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
