import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skinoura/database/database_helper.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/models/user_model_sql.dart';
import 'package:skinoura/views/Form_Registrasi.dart';
import 'package:skinoura/widgets/app_BottomNav.dart';

class FormLoginNew extends StatefulWidget {
  const FormLoginNew({super.key});

  @override
  State<FormLoginNew> createState() => _FormLoginNewState();
}

class _FormLoginNewState extends State<FormLoginNew> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final pengguna = await DBHelper().loginUser(
        UserModelSql(email: email, password: pass),
      );

      if (!mounted) return;

      if (pengguna != null) {
        await PreferencesHandler.setLogin(true);
        // Save user details to preferences if needed
        await PreferencesHandler.saveUser(
          nama: pengguna.nama ?? "User",
          email: pengguna.email,
          password: pengguna.password,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Selamat datang kembali, ${pengguna.nama ?? 'User'}!",
            ),
            backgroundColor: const Color(0xFF7C9A92),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (!mounted) return;
        context.pushAndRemoveAll(const AppBottomnav());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Login gagal. Email atau Password salah."),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFBF9F8), // Luminous off-white
              Color(0xFFF5E6DA), // Soft warm beige
              Color(0xFFE5F0EE), // Soft hint of sage green
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Space / Logo Section
                    const SizedBox(height: 20),
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 90,
                          width: 90,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C9A92).withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/images/kp2_dm.gif",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE5F0EE),
                                  child: const Icon(
                                    Icons.spa,
                                    color: Color(0xFF7C9A92),
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Skinoura",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C3E35),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your personalized skincare sanctuary",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF7E756E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C9A92).withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E35),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email Input
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email Address",
                                labelStyle: const TextStyle(
                                  color: Color(0xFF7E756E),
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF7C9A92),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFBF9F8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF7C9A92,
                                    ).withOpacity(0.15),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF7C9A92),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email tidak boleh kosong";
                                } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value.trim())) {
                                  return "Format Email tidak valid";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: const TextStyle(
                                  color: Color(0xFF7E756E),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outlined,
                                  color: Color(0xFF7C9A92),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF7C9A92),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFBF9F8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF7C9A92,
                                    ).withOpacity(0.15),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF7C9A92),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password tidak boleh kosong";
                                } else if (value.length < 6) {
                                  return "Password minimal 6 karakter";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  // Add action if desired
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Fitur Lupa Password akan segera hadir.",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFF7C9A92),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Sign In Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          _login();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C9A92),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFF7C9A92,
                                  ).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  shadowColor: const Color(
                                    0xFF7C9A92,
                                  ).withOpacity(0.4),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Google Sign In Button
                            SizedBox(
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Fitur Google Sign-In akan segera hadir.",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/google.png",
                                      width: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.g_mobiledata,
                                              size: 28,
                                              color: Colors.red,
                                            );
                                          },
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Continue with Google",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Register Link
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "New to CareSkin+? ",
                          style: const TextStyle(
                            color: Color(0xFF7E756E),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.push(const LamanRegistrasi());
                                },
                              text: "Create an account",
                              style: const TextStyle(
                                color: Color(0xFF7C9A92),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
