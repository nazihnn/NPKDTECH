import 'package:flutter/material.dart';

class HomePage  extends StatelessWidget {
  const HomePage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'NPKDTECH',
          style: TextStyle(color: Colors.black54, fontWeight:FontWeight.bold),),
          centerTitle:  true,
          backgroundColor: Colors.lightGreen,
        ),
      
        

    );
  }
}