import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skinoura/auth/Form_Registrasi.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/services/firebase_auth_service.dart';
import 'package:skinoura/services/notification_service.dart';
import 'package:skinoura/widgets/app_BottomNav.dart';
import 'package:skinoura/theme/theme_color.dart';

class Formlogin extends StatefulWidget {
  const Formlogin({super.key});

  @override
  State<Formlogin> createState() => _FormloginState();
}

class _FormloginState extends State<Formlogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namacontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool _isLoading = false;
  void login() async {
    final email = emailcontroller.text.trim();
    final pass = passwordcontroller.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap mengisi form')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pengguna = await FirebaseAuthService().signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;

      if (pengguna != null) {
        await PreferencesHandler.setLogin(true);

        await PreferencesHandler.saveUser(
          nama: pengguna.nama ?? "",
          email: pengguna.email,
          password: pass,
          profilePicture: pengguna.profilePicture,
        );

        if (pengguna.skinType != null) {
          await PreferencesHandler.saveSkinType(pengguna.skinType!);
        }
        if (pengguna.recommendedIngredients != null) {
          await PreferencesHandler.saveRecommendedIngredients(
            pengguna.recommendedIngredients!,
          );
        }

        // Sinkronisasi pengingat harian dari Firestore ke perangkat lokal
        if (pengguna.notificationEnabled != null) {
          await PreferencesHandler.setNotificationEnabled(
            pengguna.notificationEnabled!,
          );
        }
        if (pengguna.notificationHour != null &&
            pengguna.notificationMinute != null) {
          await PreferencesHandler.setNotificationTime(
            pengguna.notificationHour!,
            pengguna.notificationMinute!,
          );
        }

        // Aktifkan alarm pengingat jika sebelumnya aktif di Firestore
        if (pengguna.notificationEnabled == true &&
            pengguna.notificationHour != null &&
            pengguna.notificationMinute != null) {
          try {
            await NotificationService.scheduleDailyNotification(
              id: 100,
              title: "Waktunya Skincare-an! ✨",
              body:
                  "Yuk, lakukan rutinitas skincare kamu hari ini agar kulit tetap sehat dan terawat!",
              hour: pengguna.notificationHour!,
              minute: pengguna.notificationMinute!,
            );
          } catch (e) {
            print("Error scheduling notification after login: $e");
          }
        }

        context.pushAndRemoveAll(AppBottomnav());
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login gagal. Akun tidak ditemukan.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Login gagal. Email atau Password salah."),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF6F1EE), ThemeColor.primaryColor],
              ),
            ),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(35),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage("assets/images/kp2_dm.gif"),
                            ),
                          ),
                        ),
                        Text(
                          "CareSkin+",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.primaryColor,
                          ),
                        ),
                        Text(
                          "Your skincare journey begins here.",
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: TextFormField(
                                controller: emailcontroller,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email),
                                  hintText: "Masukkan Email Anda",
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ThemeColor.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ThemeColor.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email tidak boleh kosong";
                                  } else if (!value.contains('@')) {
                                    return "Format Email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: TextFormField(
                                controller: passwordcontroller,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.key),
                                  hintText: "Masukkan Password Anda",
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ThemeColor.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ThemeColor.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password tidak boleh kosong";
                                  } else if (value.length < 6) {
                                    return "Password Anda Terlalu Singkat";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // const SizedBox(height: 10),
                            // Container(
                            //   margin: const EdgeInsets.only(right: 22),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       GestureDetector(
                            //         onTap: () {
                            //           print("Forgot Password Clicked");
                            //         },
                            //         child: const Text("Forgot Password?"),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeColor.primaryColor,
                                  ),
                                  child: const Text(
                                    "Sign In",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: "New to CareSkin+? ",
                                  children: [
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LamanRegistrasi(),
                                          ),
                                        ),
                                      text: "Create an account",
                                      style: TextStyle(
                                        color: ThemeColor.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/kp2_dm.gif",
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Signing In...",
                        style: TextStyle(
                          color: ThemeColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
