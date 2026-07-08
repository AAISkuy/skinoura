import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/views/form_discovery.dart';
import 'package:skinoura/views/form_home.dart';
import 'package:skinoura/views/form_profile.dart';
import 'package:skinoura/views/form_ritual.dart';

class AppBottomnav extends StatefulWidget {
  const AppBottomnav({super.key});

  @override
  State<AppBottomnav> createState() => _AppBottomNav();
}

class _AppBottomNav extends State<AppBottomnav> {
  int _selectedIndex = 0;

  ImageProvider _getProfileImage() {
    final String base64Str = PreferencesHandler.profilePicture;
    if (base64Str.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(base64Str));
      } catch (e) {
        print("Error decoding profile image: $e");
      }
    }
    return const AssetImage('assets/images/Exampprofil.jpeg');
  }
  String? selected;



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
      appBar: AppBar(
        backgroundColor: Color(0xFFF5FAFD),
        title: Text(
          'Careskin+',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C9A92),
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ).then((_) {
                setState(() {});
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7C9A92),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE2ECE9),
                  backgroundImage: PreferencesHandler.profilePicture.isNotEmpty
                      ? _getProfileImage()
                      : null,
                  child: PreferencesHandler.profilePicture.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF7C9A92),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 226, 237, 243),

      body: [
        Homepage(userName: PreferencesHandler.nama),
        const DiscoverPage(),
        const RitualPage(),
      ][_selectedIndex],

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
            label: 'Routine',
          ),
        ],
      ),
    );
  }
}
