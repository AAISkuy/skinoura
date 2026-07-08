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
  bool _isAgreed = false;

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Terms and Conditions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C9A92),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Selamat datang di CareSkin+ (Skinoura). Dengan menggunakan aplikasi kami, Anda menyetujui syarat, ketentuan, dan perjanjian pengguna berikut:\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    "1. Penggunaan Layanan\n"
                    "Aplikasi ini ditujukan untuk memberikan informasi rekomendasi perawatan kulit (skincare) berdasarkan analisis kuis tipe kulit Anda. Informasi ini bukan pengganti saran medis profesional dari dokter spesialis kulit.\n\n"
                    "2. Privasi Data Pengguna\n"
                    "Kami mengumpulkan data profil Anda, tipe kulit, rutinitas skincare, dan waktu notifikasi Anda untuk sinkronisasi cloud Firebase. Kami tidak membagikan data pribadi Anda kepada pihak ketiga.\n\n"
                    "3. Notifikasi & Alarm\n"
                    "Dengan mengaktifkan pengingat harian, aplikasi akan mengirimkan notifikasi harian untuk mengingatkan Anda melakukan perawatan kulit. Anda dapat menonaktifkan ini kapan saja melalui halaman pengaturan.\n\n"
                    "4. Pembatasan Tanggung Jawab\n"
                    "CareSkin+ tidak bertanggung jawab atas reaksi alergi, iritasi, atau ketidakcocokan produk skincare yang Anda gunakan. Silakan lakukan patch test sebelum menggunakan produk baru.\n\n"
                    "5. Hak Cipta\n"
                    "Seluruh materi, logo, grafik, dan desain di dalam aplikasi ini adalah milik CareSkin+ dan dilindungi oleh undang-undang hak cipta.",
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(color: Color(0xFF7C9A92), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
  bool _isRegistering = false;

  void register() async {
    if (_isRegistering) return; // Mencegah klik ganda / eksekusi ganda

    final nama = namacontroller.text.trim();
    final email = emailcontroller.text.trim();
    final pass = passwordcontroller.text.trim();

    if (nama.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon mengisi semua form')));
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    // Tampilkan Loading Spinner Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C9A92)),
          ),
        );
      },
    );

    try {
      final user = await FirebaseAuthService().signUpWithEmailAndPassword(
        nama: nama,
        email: email,
        password: pass,
      );

      if (!mounted) return;

      // Tutup Loading Spinner Dialog
      Navigator.pop(context);

      setState(() {
        _isRegistering = false;
      });

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
      Navigator.pop(context); // Tutup Loading Spinner Dialog
      setState(() {
        _isRegistering = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Terjadi kesalahan autentikasi")),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading Spinner Dialog
      setState(() {
        _isRegistering = false;
      });
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
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isAgreed,
                                activeColor: const Color(0xFF7C9A92),
                                onChanged: (value) {
                                  setState(() {
                                    _isAgreed = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: "Saya setuju ",
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    children: [
                                      TextSpan(
                                        text: "Terms and Conditions",
                                        style: const TextStyle(
                                          color: Color(0xFF7C9A92),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _showTermsDialog,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (!_isAgreed) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Harap setujui Terms and Conditions terlebih dahulu.",
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }
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
                                            onPressed: () {
                                              Navigator.pop(context); // Tutup dialog Berhasil terlebih dahulu
                                              register(); // Jalankan proses registrasi
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
