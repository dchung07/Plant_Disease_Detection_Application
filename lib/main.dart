import 'package:flutter/material.dart';
import 'pages/educational_page.dart';
import 'pages/detect_page.dart';
import 'pages/about_page.dart';

// Main entry point of application
void main() => runApp(const MyApp());

// MainScreen() is the starting screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variable to track the current navigation screen.
  // Set to 1 so it starts at DetectPage()
  int _selectedIndex = 1;

  // This is run on tap of the navigation bar buttons changing the selectedIndex.
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Depending on the index (the selectedIndex variable) it will return a new page.
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const EducationalPage();
      case 1:
        return const DetectPage();
      case 2:
        return const AboutPage();
      default:
        return const DetectPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Returns whichever page is selected by user through index variable
        child: _getPage(_selectedIndex),
      ),
      // The Flutter framework provides a nav bar, and useful icons 
      // We can use it to populate the buttons without need to download images into the app
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.cast_for_education_sharp), label: 'Education'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Detect'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Page'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 75, 180, 94),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Concert One',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          fontFamily: 'Concert One',
        ),
        onTap: _navigateToPage,
      ),
    );
  }
}
