import 'title_box.dart';
import 'button_group.dart';
import 'package:flutter/material.dart';

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
          TitleBox(title: "Robot ID"),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
          Expanded(
            child: ButtonGroup(),
          ),
        ],
      ),
    );
  }
}
