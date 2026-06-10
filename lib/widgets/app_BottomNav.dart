import 'package:flutter/material.dart';
import 'package:skinoura/auth/form_login.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
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
  String? selected;

  final List<Widget> _pages = [
    const Homepage(),
    const DiscoverPage(),
    const RitualPage(),
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
      appBar: AppBar(
        backgroundColor: Color(0xFFF5FAFD),
        title: Text(
          'Skinoura',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C9A92),
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            onSelected: (value) async {
              if (value == 'Profile') {
                print('pindah ke halaman profil');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else if (value == 'Logout') {
                print('Proses Logout');
                await PreferencesHandler.logOut();
                if (!mounted) return;
                context.pushAndRemoveAll(const Formlogin());
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/Exampprofil.jpeg'),
              ),
            ),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
