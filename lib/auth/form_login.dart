import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skinoura/auth/Form_Registrasi.dart';
import 'package:skinoura/database/database_helper.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/models/user_model_sql.dart';
import 'package:skinoura/widgets/app_BottomNav.dart';

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
  void login() async {
    final email = emailcontroller.text.trim();
    final pass = passwordcontroller.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap mengisi semua form')));
      return;
    }

    final pengguna = await DBHelper().loginUser(
      UserModelSql(email: email, password: pass),
    );

    if (!mounted) return;

    if (pengguna != null) {
      await PreferencesHandler.setLogin(true);

      await PreferencesHandler.saveUser(
        nama: pengguna.nama ?? "",
        email: pengguna.email,
        password: pengguna.password,
      );

      context.pushAndRemoveAll(AppBottomnav());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal. Email atau Password salah."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F1EE), Color(0xFF7C9A92)],
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
                    const Text(
                      "Skinoura",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C9A92),
                      ),
                    ),
                    const Text(
                      "Your skincare journey begins here.",
                      style: TextStyle(fontSize: 14, color: Color(0xFF7C9A92)),
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
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C9A92),
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
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C9A92),
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
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(right: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print("Forgot Password Clicked");
                                },
                                child: const Text("Forgot Password?"),
                              ),
                            ],
                          ),
                        ),
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
                                backgroundColor: const Color(0xFF7C9A92),
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(child: Text("OR")),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  print("Sudah memenuhi syarat");
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Berhasil"),
                                        content: const Text(
                                          "Anda berhasil login",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Lanjut"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C9A92),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/google.png",
                                    width: 20,
                                  ),
                                  const Text(
                                    "   Continue with Google",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
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
                                  style: const TextStyle(
                                    color: Color(0xFF7C9A92),
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
    );
  }
}
