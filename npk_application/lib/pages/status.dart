import 'package:flutter/material.dart';


class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("System Status"),
      ),
      body: Center(
        child: Text(
          "Welcome to status page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}