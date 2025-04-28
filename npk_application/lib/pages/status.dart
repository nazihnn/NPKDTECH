import 'title_box.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// Define a consistent color scheme
class AppColors {
  static const Color primary = Color.fromARGB(255, 143, 143, 1); // Olive green
  static const Color secondary = Color(0xFF68BB7D);
  static const Color accent = Color(0xFFE65100); // Deep orange
  static const Color upColor = Color(0xFF4CAF50);
  static const Color downColor = Color(0xFF2196F3);
  static const Color stopColor = Color(0xFFE53935);
}

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

  Color _getStatusColor(String status) {
    switch (status) {
      case "up":
        return AppColors.upColor;
      case "down":
        return AppColors.downColor;
      case "stop":
        return AppColors.stopColor;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "up":
        return Icons.arrow_upward;
      case "down":
        return Icons.arrow_downward;
      case "stop":
        return Icons.stop;
      default:
        return Icons.linear_scale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF68BB7D),
            const Color(0xFFA8E063),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Title Box
              // Padding(
              //   padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
              //   child: TitleBox(
              //     title: "System Status",
              //     icon: Icons.dashboard_rounded,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
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
                        Icons.dashboard_customize_rounded,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "System Status",
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
              const SizedBox(
                height: 50.0,
              ),
              // Current job card
              _buildStatusCard(
                title: "Current Job",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_rounded,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currentJob,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actuator control card
              _buildStatusCard(
                title: "Actuator Control",
                icon: Icons.precision_manufacturing_rounded,
                child: Column(
                  children: [
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(currentActuatorStatus),
                            color: _getStatusColor(currentActuatorStatus),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentActuatorStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(currentActuatorStatus),
                            ),
                          ),
                          if (isUpdating)
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          label: "Up",
                          icon: Icons.arrow_upward,
                          color: AppColors.upColor,
                          onPressed:
                              isUpdating ? null : () => _controlActuator("up"),
                        ),
                        _buildControlButton(
                          label: "Down",
                          icon: Icons.arrow_downward,
                          color: AppColors.downColor,
                          onPressed: isUpdating
                              ? null
                              : () => _controlActuator("down"),
                        ),
                        _buildControlButton(
                          label: "Stop",
                          icon: Icons.stop,
                          color: AppColors.stopColor,
                          onPressed: isUpdating
                              ? null
                              : () => _controlActuator("stop"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.accent.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card title
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.accent,
                  size: 22,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          // Card content
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        shadowColor: color.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
