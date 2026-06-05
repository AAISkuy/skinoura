import 'package:flutter/material.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/views/form_login.dart';
import 'package:skinoura/widgets/app_bottomnav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = "/splash";
  @override
  State<SplashScreen> createState() => Splash_Screen();
}

class Splash_Screen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;
    if (PreferencesHandler.isLogin) {
      context.pushAndRemoveAll(AppBottomnav());
    } else {
      context.pushAndRemoveAll(const Formlogin());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F1EE), Color.fromARGB(255, 214, 236, 238)],
          ),
        ),

        child: Center(
          child: Container(
            width: 320,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/images/kp2_dm.gif"),
                    ),
                  ),
                ),

                Text(
                  "Skinoura",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C9A92),
                  ),
                ),

                Text(
                  "Your skincare journey begins here.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF7C9A92)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
