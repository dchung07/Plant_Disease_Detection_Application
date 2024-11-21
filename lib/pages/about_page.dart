import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 75, 180, 94),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Plantly',
              style: TextStyle(
                fontFamily: 'Concert One',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/logo.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'About Page',
              style: TextStyle(
                fontFamily: 'Concert One',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'About Plantly',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Plantly is an app designed to help users detect plant diseases and learn more about plant diseases. '
                'It combines machine learning with educational resources to empower anyone interested in agriculture such as hobbyists or farmers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              Text(
                'Special Thanks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Thank you to my supervisor, Dr Ayesha Ubaid, for the guidance and support throughout this project.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'I would also like to thank UTS for providing the resources and platform to make this app possible.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
