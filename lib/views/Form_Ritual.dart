import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skinoura/database/database_helper.dart';
import 'package:skinoura/database/firebase_db_helper.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/models/ritual_model.dart';
import 'package:skinoura/services/notification_service.dart';
import 'package:skinoura/widgets/calendar_card.dart';
import 'package:skinoura/widgets/ritual_card.dart';

class RitualPage extends StatefulWidget {
  const RitualPage({super.key});

  @override
  State<RitualPage> createState() => _RitualPageState();
}

class _RitualPageState extends State<RitualPage> {
  List<RitualModel> rituals = [];
  DateTime _selectedDate = DateTime.now();
  late ScrollController _scrollController;

  bool get _isPastDate {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected.isBefore(today);
  }

  bool get _isFutureDate {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected.isAfter(today);
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  bool _isNotificationEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> loadRituals() async {
    final data = await DBHelper().getRitualsByEmail(PreferencesHandler.email);
    final String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Filter agar langkah skincare yang dibuat hari ini tidak muncul di hari kemarin,
    // dan langkah yang dihapus tidak muncul di hari penghapusan serta setelahnya.
    final filteredData = data.where((ritual) {
      if (ritual.createdAt == null && ritual.deletedAt == null)
        return true; // Data lama
      final bool isCreated =
          ritual.createdAt == null || ritual.createdAt!.compareTo(dateKey) <= 0;
      final bool isNotDeleted =
          ritual.deletedAt == null || dateKey.compareTo(ritual.deletedAt!) < 0;
      return isCreated && isNotDeleted;
    }).toList();

    for (var ritual in filteredData) {
      final String key = "${dateKey}_${ritual.id}";
      ritual.isDone = PreferencesHandler.getStepStatus(key);
    }

    setState(() {
      rituals = filteredData;
    });
  }

  void _loadNotificationSettings() {
    setState(() {
      _isNotificationEnabled = PreferencesHandler.notificationEnabled;
      _reminderTime = TimeOfDay(
        hour: PreferencesHandler.notificationHour,
        minute: PreferencesHandler.notificationMinute,
      );
    });
  }

  Future<User?> _getFirebaseUser() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final email = PreferencesHandler.email;
      final password = PreferencesHandler.password;
      if (email.isNotEmpty && password.isNotEmpty) {
        try {
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          user = credential.user;
        } catch (e) {
          print("Background sign-in failed: $e");
        }
      }
    }
    return user;
  }

  Future<void> _toggleNotification(bool value) async {
    if (value) {
      // Minta izin notifikasi terlebih dahulu
      bool hasPermission = await NotificationService.requestPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Izin notifikasi ditolak. Silakan aktifkan izin di pengaturan.",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      await PreferencesHandler.setNotificationEnabled(true);

      // Kirim notifikasi instan sebagai konfirmasi bahwa fitur aktif & berfungsi
      await NotificationService.showImmediateNotification(
        id: 101,
        title: "Pengingat Skincare Aktif! 🔔",
        body:
            "Kami akan mengingatkanmu setiap hari pada pukul ${_reminderTime.format(context)}.",
      );

      await NotificationService.scheduleDailyNotification(
        id: 100, // ID konstan untuk pengingat rutinitas
        title: "Waktunya Skincare-an! ✨",
        body:
            "Yuk, lakukan rutinitas skincare kamu hari ini agar kulit tetap sehat dan terawat!",
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );

      setState(() {
        _isNotificationEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Pengingat harian aktif pada pukul ${_reminderTime.format(context)}",
            ),
            backgroundColor: const Color(0xFF436155),
          ),
        );
      }
    } else {
      await PreferencesHandler.setNotificationEnabled(false);
      await NotificationService.cancelNotification(100);

      setState(() {
        _isNotificationEnabled = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengingat harian dinonaktifkan"),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }

    // Sinkronisasi status pengingat harian ke Firestore
    final currentUser = await _getFirebaseUser();
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'notificationEnabled': value,
            'notificationHour': _reminderTime.hour,
            'notificationMinute': _reminderTime.minute,
          }, SetOptions(merge: true))
          .catchError(
            (e) => print("Gagal sync status notifikasi ke Firestore: $e"),
          );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF436155),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      await PreferencesHandler.setNotificationTime(picked.hour, picked.minute);
      setState(() {
        _reminderTime = picked;
      });

      // Jika notifikasi sedang aktif, reschedule dengan waktu baru
      if (_isNotificationEnabled) {
        await NotificationService.scheduleDailyNotification(
          id: 100,
          title: "Waktunya Skincare-an! ✨",
          body:
              "Yuk, lakukan rutinitas skincare kamu hari ini agar kulit tetap sehat dan terawat!",
          hour: picked.hour,
          minute: picked.minute,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Waktu pengingat diubah ke pukul ${picked.format(context)}",
            ),
            backgroundColor: const Color(0xFF436155),
          ),
        );
      }

      // Sinkronisasi perubahan waktu pengingat ke Firestore
      final currentUser = await _getFirebaseUser();
      if (currentUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
              'notificationHour': picked.hour,
              'notificationMinute': picked.minute,
            }, SetOptions(merge: true))
            .catchError(
              (e) => print("Gagal sync waktu notifikasi ke Firestore: $e"),
            );
      }
    }
  }

  bool _isSyncing = false;

  Future<void> _syncData() async {
    final email = PreferencesHandler.email;
    if (email.isEmpty) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      await FirebaseDBHelper().syncData();
    } catch (e) {
      print("Error during sync in Ritual page: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadRituals();
    _loadNotificationSettings();
    _scrollController = ScrollController(initialScrollOffset: 840.0);

    // Jalankan sync di background saat halaman dimuat
    _syncData().then((_) {
      if (mounted) {
        loadRituals();
      }
    });
  }

  @override
  void dispose() {
    // Bersihin controller pas halaman ditutup
    _titleController.dispose();
    _subtitleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditDialog(RitualModel ritual) {
    final titleController = TextEditingController(text: ritual.title);
    final subtitleController = TextEditingController(text: ritual.subtitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Skincare"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: "Kandungan"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedRitual = RitualModel(
                  id: ritual.id,
                  title: titleController.text,
                  subtitle: subtitleController.text,
                  isDone: ritual.isDone,
                  ownerEmail: ritual.ownerEmail,
                  createdAt: ritual.createdAt,
                  deletedAt: ritual.deletedAt,
                );

                await DBHelper().updateRitual(updatedRitual);

                // Simpan ke Firestore
                await FirebaseDBHelper().updateRitual(updatedRitual);

                await loadRituals();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  //  fungsi buat nambah  skincare
  void _showAddSkincareDialog() {
    if (_isPastDate) return;
    String selectedType = "Facewash"; // Nilai default

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Tambah Skincare Baru",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF436155),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Biar tinggi pop-up nyesuaian isi
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: "Jenis Skincare",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF436155)),
                        ),
                      ),
                      dropdownColor: Theme.of(context).cardColor,
                      items: const [
                        DropdownMenuItem(value: "Facewash", child: Text("Facewash")),
                        DropdownMenuItem(value: "Sunscreen", child: Text("Sunscreen")),
                        DropdownMenuItem(value: "Toner", child: Text("Toner")),
                        DropdownMenuItem(value: "Cleanser", child: Text("Cleanser")),
                        DropdownMenuItem(value: "Serum", child: Text("Serum")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Nama Produk (cth: Hydrating Toner)",
                        hintText: "Masukkan nama produk...",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF436155)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: "Kandungan (cth: Hyaluronic Acid)",
                        hintText: "Masukkan kandungan...",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF436155)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    _subtitleController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty || selectedType.isNotEmpty) {
                      final String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
                      
                      // Jika nama produk kosong, gunakan jenis skincare sebagai judul utama
                      final String finalTitle = _titleController.text.isEmpty
                          ? selectedType
                          : _titleController.text;

                      // Gabungkan jenis skincare dan kandungan untuk subtitle agar terstruktur
                      final String finalSubtitle = _subtitleController.text.isEmpty
                          ? selectedType
                          : "$selectedType - ${_subtitleController.text}";

                      final newRitual = RitualModel(
                        title: finalTitle,
                        subtitle: finalSubtitle,
                        isDone: false,
                        ownerEmail: PreferencesHandler.email,
                        createdAt: dateKey,
                      );
                      final int localId = await DBHelper().insertRitual(newRitual);
                      newRitual.id = localId;

                      // Sinkronisasi data ke Firestore
                      await FirebaseDBHelper().insertRitual(newRitual);

                      _titleController.clear();
                      _subtitleController.clear();

                      await loadRituals();

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF436155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Tambah"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // double persenHariIni = rituals.isEmpty
    //     ? 0.0
    //     : (jumlahDicentang / rituals.length) * 100;

    DateTime hariIni = DateTime.now();
    String tanggalDiformat =
        "${DateFormat('EEEE, MMMM d').format(_selectedDate)}th";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rutinitas Skincare",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _isSyncing
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF7C9A92)
                                  : const Color(0xFF436155),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.sync,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF7C9A92)
                                : const Color(0xFF436155),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            await _syncData();
                            await loadRituals();
                          },
                        ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tanggalDiformat,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),

              // buat header kalender tanggal (horizontal scrollable)
              SizedBox(
                height: 70,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 31, // 15 hari lalu s.d. 15 hari ke depan
                  itemBuilder: (context, index) {
                    DateTime targetTanggal = hariIni.add(
                      Duration(days: index - 15),
                    );
                    String namaHari = DateFormat(
                      'E',
                    ).format(targetTanggal).toUpperCase();
                    String angkaTanggal = DateFormat('d').format(targetTanggal);

                    bool isActive =
                        targetTanggal.day == _selectedDate.day &&
                        targetTanggal.month == _selectedDate.month &&
                        targetTanggal.year == _selectedDate.year;

                    bool isToday =
                        targetTanggal.day == hariIni.day &&
                        targetTanggal.month == hariIni.month &&
                        targetTanggal.year == hariIni.year;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = targetTanggal;
                          });
                          loadRituals();
                        },
                        child: SizedBox(
                          width: 55,
                          child: CalendarDayCard(
                            day: namaHari,
                            date: angkaTanggal,
                            isActive: isActive,
                            isToday: isToday,
                            hasDot: false,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Pengingat Rutinitas Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.02),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF313F3B)
                            : const Color(0xFFE2ECE9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF7C9A92)
                            : const Color(0xFF436155),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pengingat Harian",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: _selectTime,
                            child: Row(
                              children: [
                                Text(
                                  _reminderTime.format(context),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF436155),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Color(0xFF436155),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isNotificationEnabled,
                      onChanged: _toggleNotification,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF436155),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.02),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: Color(0xFF436155),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Skincare Protocol",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${rituals.where((e) => e.isDone).length} of ${rituals.length} steps",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        if (!_isPastDate)
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Color(0xFF436155),
                              size: 28,
                            ),
                            onPressed: _showAddSkincareDialog,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Column(
                      children: rituals.map((ritual) {
                        int nomorUrut = rituals.indexOf(ritual) + 1;

                        return GestureDetector(
                          onLongPress: _isPastDate
                              ? null
                              : () async {
                                  final String dateKey = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_selectedDate);
                                  await DBHelper().softDeleteRitual(
                                    ritual.id!,
                                    dateKey,
                                  );

                                  // Sinkronisasi soft delete ke Firestore
                                  ritual.deletedAt = dateKey;
                                  await FirebaseDBHelper().updateRitual(ritual);

                                  await loadRituals();
                                },

                          child: RitualStepCard(
                            title: ritual.title,
                            subtitle: ritual.subtitle,
                            stepNumber: "Step $nomorUrut",
                            isDone: ritual.isDone,

                            onTap: () async {
                              if (_isPastDate) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Riwayat hari sebelumnya tidak dapat diubah.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (_isFutureDate) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Rutinitas hari yang akan datang belum dapat diisi.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              final String dateKey = DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDate);
                              final String key = "${dateKey}_${ritual.id}";
                              final bool newStatus = !ritual.isDone;

                              await PreferencesHandler.saveStepStatus(
                                key,
                                newStatus,
                              );

                              // Kita juga update di database untuk keselarasan status umum/offline
                              await DBHelper().updateRitualStatus(
                                ritual.id!,
                                newStatus,
                              );

                              // Sinkronisasi status checklist harian ke Firestore
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              if (currentUser != null) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .collection('step_statuses')
                                    .doc(key)
                                    .set({'isDone': newStatus})
                                    .catchError(
                                      (e) => print(
                                        "Error sync status harian ke Firestore: $e",
                                      ),
                                    );
                              }

                              await loadRituals();
                            },

                            onDelete: _isPastDate
                                ? null
                                : () async {
                                    final String dateKey = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_selectedDate);
                                    await DBHelper().softDeleteRitual(
                                      ritual.id!,
                                      dateKey,
                                    );

                                    // Sinkronisasi soft delete ke Firestore
                                    ritual.deletedAt = dateKey;
                                    await FirebaseDBHelper().updateRitual(
                                      ritual,
                                    );

                                    await loadRituals();
                                  },

                            onEdit: _isPastDate
                                ? null
                                : () {
                                    _showEditDialog(ritual);
                                  },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // // D. CONSISTENCY TRACKER SECTION
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(24),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           const Text(
              //             "Consistency",
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           Container(
              //             padding: const EdgeInsets.all(6),
              //             decoration: const BoxDecoration(
              //               color: Color(0xFF436155),
              //               shape: BoxShape.circle,
              //             ),
              //             child: Text(
              //               "${persenHariIni.toInt()}%",
              //               style: const TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 11,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 8),
              //       const Text(
              //         "You're on a 3-day streak. Keep building that barrier!",
              //         style: TextStyle(color: Colors.grey, fontSize: 14),
              //       ),
              //       const SizedBox(height: 20),

              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.end,
              //         children: [
              //           const BarChartCard(day: "S", percentage: 100),
              //           const BarChartCard(day: "M", percentage: 100),
              //           const BarChartCard(day: "T", percentage: 100),
              //           BarChartCard(day: "W", percentage: persenHariIni),
              //           const BarChartCard(day: "T", percentage: 0),
              //           const BarChartCard(day: "F", percentage: 0),
              //           const BarChartCard(day: "S", percentage: 0),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
