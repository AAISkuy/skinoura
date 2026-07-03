import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skinoura/auth/form_login.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LamanRegistrasi extends StatefulWidget {
  const LamanRegistrasi({super.key});

  @override
  State<LamanRegistrasi> createState() => Laman_RegistrasiState();
}

class Laman_RegistrasiState extends State<LamanRegistrasi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namacontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  void register() async {
    final nama = namacontroller.text.trim();
    final email = emailcontroller.text.trim();
    final pass = passwordcontroller.text.trim();

    if (nama.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon mengisi semua form')));
      return;
    }

    try {
      final user = await FirebaseAuthService().signUpWithEmailAndPassword(
        nama: nama,
        email: email,
        password: pass,
      );

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeay Akun anda berhasil dibuat')),
        );
        context.push(const Formlogin());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pendaftaran gagal. Silakan coba lagi.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Terjadi kesalahan autentikasi")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(35),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F1EE), Color(0xFF7C9A92)],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),

              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    Container(
                      height: 35,
                      width: 35,
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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C9A92),
                      ),
                    ),

                    SizedBox(height: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Masukkan Nama Anda",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C9A92),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: TextFormField(
                            controller: namacontroller,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Nama Anda",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Nama tidak boleh kosong";
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 10),

                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Masukkan Email Anda",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C9A92),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: TextFormField(
                            controller: emailcontroller,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: "example@gmail.com",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
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

                        SizedBox(height: 10),

                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Masukkan Password Anda",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C9A92),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: TextFormField(
                            controller: passwordcontroller,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Password Anda",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password tidak boleh kosong";
                              } else if (value.length < 6) {
                                return "Password harus terdiri dari minimal 6 karakter";
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 10),

                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Konfirmasi Password Anda",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C9A92),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Konfirmasi Password",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF7C9A92),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password tidak boleh kosong";
                              } else if (value != passwordcontroller.text) {
                                return "Password tidak sama";
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 10),

                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                                        title: Text("Berhasil"),
                                        content: Text(
                                          "Anda berhasil Mendaftar",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: register,
                                            child: Text("Lanjut"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF7C9A92),
                              ),

                              child: Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an Account? ",
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Formlogin(),
                                      ),
                                    ),
                                  text: "Log In",
                                  style: TextStyle(
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
