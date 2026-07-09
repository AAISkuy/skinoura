import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinoura/auth/form_login.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/extension/extension.dart';
import 'package:skinoura/theme/theme_color.dart';

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
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final String base64Str = base64Encode(bytes);

        await PreferencesHandler.saveProfilePicture(base64Str);

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
                  await PreferencesHandler.saveUser(
                    nama: newName,
                    email: PreferencesHandler.email,
                    password: PreferencesHandler.password,
                    profilePicture: PreferencesHandler.profilePicture,
                  );

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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
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
                color: Theme.of(context).cardColor,
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
                        Container(
                          padding: const EdgeInsets.all(
                            4,
                          ), // Jarak border ke foto
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [ThemeColor.primaryColor, Color(0xFF436155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x33436155),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              2,
                            ), // Lapisan putih pembatas
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: const Color(0xFFE2ECE9),
                              backgroundImage:
                                  PreferencesHandler.profilePicture.isNotEmpty
                                  ? _getProfileImage()
                                  : null,
                              child: PreferencesHandler.profilePicture.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 46,
                                      color: ThemeColor.primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF436155),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x26000000),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                      const SizedBox(width: 20),
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
                    'Tipe kulit kamu: ${PreferencesHandler.skinType}',
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
                color: Theme.of(context).cardColor,
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
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      radius: 22,
                      child: Icon(
                        Icons.palette_outlined,
                        color: Colors.grey[700],
                      ),
                    ),
                    title: const Text(
                      "Ubah Tema",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text(
                      "Ganti tema warna aplikasi",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: Switch(
                      value: ThemeColor.isDarkMode.value,
                      activeColor: const Color(0xFF7C9A92),
                      onChanged: (bool value) async {
                        await ThemeColor.toggleTheme(value);
                        setState(() {});
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      radius: 22,
                      child: Icon(
                        Icons.book_online_outlined,
                        color: Colors.grey[700],
                      ),
                    ),
                    title: const Text(
                      'Tentang Kami',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text(
                      "Syarat, Ketentuan, dan Kebijakan Privasi",
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
