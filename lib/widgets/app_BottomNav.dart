import 'package:flutter/material.dart';
import 'package:skinoura/views/Form_Discovery.dart';
import 'package:skinoura/views/Form_Profile.dart';
import 'package:skinoura/views/Form_Progress.dart';
import 'package:skinoura/views/Form_Ritual.dart';
import 'package:skinoura/views/Home_Page.dart';

class NavigasiDrawer extends StatefulWidget {
  const NavigasiDrawer({super.key});

  @override
  State<NavigasiDrawer> createState() => _NavigasiDrawerState();
}

class _NavigasiDrawerState extends State<NavigasiDrawer> {
  int _selectedIndex = 0;
  String? selected;

  final List<Widget> _pages = [
    const Homepage(),
    const DiscoveryPage(),
    const RitualPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

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

      // SafeArea(
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      //         child: Stack(
      //           alignment: Alignment.center,
      //           children: [
      //             const Center(
      //               child: Text(
      //                 "Skinoura",
      //                 style: TextStyle(
      //                   fontSize: 24,
      //                   fontWeight: FontWeight.bold,
      //                   color: Color(0xFF7C9A92),
      //                 ),
      //               ),
      //             ),
      //             Align(
      //               alignment: Alignment.centerRight,
      //               child: InkWell(
      //                 onTap: () {
      //                   // Navigator.push(
      //                   //   context,
      //                   //   MaterialPageRoute(
      //                   //     builder: (context) => const ProfilePage(),
      //                   //   ),
      //                   // );
      //                 },
      //                 child: CircleAvatar(
      //                   radius: 22,
      //                   backgroundImage: AssetImage(
      //                     'assets/images/Exampprofil.jpeg',
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
