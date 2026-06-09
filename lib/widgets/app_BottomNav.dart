import 'package:flutter/material.dart';
import 'package:skinoura/views/form_discovery.dart';
import 'package:skinoura/views/form_home.dart';
import 'package:skinoura/views/form_profile.dart';
import 'package:skinoura/views/form_progress.dart';
import 'package:skinoura/views/form_ritual.dart';

class AppBottomnav extends StatefulWidget {
  const AppBottomnav({super.key});

  @override
  State<AppBottomnav> createState() => _AppBottomNav();
}

class _AppBottomNav extends State<AppBottomnav> {
  int _selectedIndex = 0;
  String? selected;

  final List<Widget> _pages = [
    const Homepage(),
    const DiscoverPage(),
    const RitualPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  // List<Widget> get _pages => [
  //   Homepage(
  //     onStartRoutineTap: () => _onBottomNavTapped(2),
  //     onSkinQuizTap: () => _onBottomNavTapped(4),
  //     onRecommendationTap: () => _onBottomNavTapped(1),
  //     onRoutineScheduleTap: () => _onBottomNavTapped(3),
  //   ),

  // Navigator(
  //   onGenerateRoute: (settings) {
  //     return MaterialPageRoute(
  //       builder: (context) => Homepage(
  //         onStartRoutineTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const QuizPage()),
  //           );
  //         },
  //       ),
  //     );
  //   },
  // ),
  //   const DiscoveryPage(),
  //   const RitualPage(),
  //   const ProgressPage(),
  //   const ProfilePage(),
  // ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 237, 243),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF7C9A92),
        unselectedItemColor: Colors.blueGrey,
        onTap: _onBottomNavTapped,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Ritual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
