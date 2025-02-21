import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Robot Location"),
      ),
      body: Center(
        child: Text(
          "coordiantes:",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}


