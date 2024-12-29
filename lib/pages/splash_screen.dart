import 'package:flutter/material.dart';
import 'package:notes_task/pages/home_page.dart';
import 'package:notes_task/pages/notes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    // Delay for 4 seconds
    await Future.delayed(Duration(seconds: 4), () {
      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }
//hello
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFF8493A8),  // Lighter blue-grey
          Color(0xFF4A5568),
        ],
        // stops: [0.4, 1.0], // Now matches the number of colors
        // tileMode: TileMode.clamp,
    ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/h.jpg', // Path to your logo
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Diary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
