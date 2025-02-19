import 'package:flutter/material.dart';
import './option.dart';

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
       body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PageOne()),
                );
              },
              child: Text("Go to Page One"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PageTwo()),
                );
              },
              child: Text("Go to Page Two"),
            ),
          ],
        ),
      ),
    );
  }
}