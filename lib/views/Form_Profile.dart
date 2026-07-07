import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinoura/auth/form_login.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 60,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final String base64Str = base64Encode(bytes);

        // Simpan lokal
        await PreferencesHandler.saveProfilePicture(base64Str);

        // Unggah ke Firestore (tanpa await agar respons UI instan)
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'profilePicture': base64Str})
              .catchError((e) {
                print("Error updating profile image to Firestore: $e");
              });
        }

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Foto profil berhasil diperbarui!"),
              backgroundColor: Color(0xFF436155),
            ),
          );
        }
      }
    } catch (e) {
      print("Error picking/uploading image: $e");
      if (mounted) {
        final bool isMissingPlugin = e.toString().contains(
          'MissingPluginException',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMissingPlugin
                  ? "Harap matikan aplikasi sepenuhnya lalu jalankan kembali menggunakan 'flutter run'."
                  : "Gagal memuat gambar: $e",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                "Ubah Foto Profil",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF436155),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF436155),
                ),
                title: const Text("Ambil Foto dari Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF436155),
                ),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: PreferencesHandler.nama,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Ubah Nama",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF436155),
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Masukkan nama baru...",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF436155)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  // 1. Simpan ke lokal
                  await PreferencesHandler.saveUser(
                    nama: newName,
                    email: PreferencesHandler.email,
                    password: PreferencesHandler.password,
                    profilePicture: PreferencesHandler.profilePicture,
                  );

                  // 2. Unggah ke Firestore (tanpa await agar UI langsung tertutup dan update seketika)
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .update({'nama': newName})
                        .catchError((e) {
                          print("Error updating name in Firestore: $e");
                        });
                  }

                  setState(() {});
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF436155),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImageSourceActionSheet,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _getProfileImage(),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF436155),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                      ), // Menyeimbangkan ikon 16px + spasi 4px agar teks nama center sempurna
                      Text(
                        PreferencesHandler.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _showEditNameDialog,
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Color(0xFF436155),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Skin Type: ${PreferencesHandler.skinType}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            SizedBox(height: 20),

            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                'App Setting',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5F5F5),
                      radius: 22,
                      child: Icon(
                        Icons.book_online_outlined,
                        color: Colors.grey[700],
                      ),
                    ),
                    title: const Text(
                      'About us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: const Text(
                      "Syarat dan peraturan",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.blueGrey,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5F5F5),
                      radius: 22,
                      child: Icon(
                        Icons.settings_outlined,
                        color: Colors.grey[700],
                      ),
                    ),
                    title: const Text(
                      "Preferences",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: const Text(
                      "Tema, Bahasa, Sistem",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.blueGrey,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 35),

            SizedBox(
              height: 35,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await PreferencesHandler.logOut();
                  if (!mounted) return;
                  context.pushAndRemoveAll(const Formlogin());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 241, 241, 241),
                  foregroundColor: const Color(0xFFF24545),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
