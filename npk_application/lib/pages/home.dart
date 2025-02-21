import 'package:flutter/material.dart';
import 'location.dart';
import 'sensor.dart';
import 'status.dart';
import 'title_box.dart';
import 'button_group.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NPKDTECH',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: const [
          TitleBox(title: "Welcome to the Robot Control Panel"),
          Expanded(
            child: ButtonGroup(),
          ),
        ],
      ),
    );
  }
}
