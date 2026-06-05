import 'package:flutter/material.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/views/Form_Login.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Skinoura",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C9A92),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(
                          'assets/images/Exampprofil.jpeg',
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {},
                      child: IconButton(
                        onPressed: () async {
                          await PreferencesHandler.logOut();

                          if (!mounted) return;

                          context.pushAndRemoveAll(const Formlogin());
                        },
                        icon: const Icon(Icons.exit_to_app_sharp),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${PreferencesHandler.nama}.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your skin is looks great today.',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 50),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF7C9A92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "Skin Combination Summary",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Combination",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
