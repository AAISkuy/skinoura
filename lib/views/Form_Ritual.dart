import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skinoura/database/database_helper.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/models/ritual_model.dart';
import 'package:skinoura/widgets/calendar_card.dart';
import 'package:skinoura/widgets/ritual_card.dart';

class RitualPage extends StatefulWidget {
  const RitualPage({super.key});

  @override
  State<RitualPage> createState() => _RitualPageState();
}

class _RitualPageState extends State<RitualPage> {
  List<RitualModel> rituals = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  Future<void> loadRituals() async {
    final data = await DBHelper().getRitualsByEmail(PreferencesHandler.email);

    setState(() {
      rituals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadRituals();
  }

  @override
  void dispose() {
    // Bersihin controller pas halaman ditutup
    _titleController.dispose();
    _subtitleController.dispose();
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
                await DBHelper().updateRitual(
                  RitualModel(
                    id: ritual.id,
                    title: titleController.text,
                    subtitle: subtitleController.text,
                    isDone: ritual.isDone,
                    ownerEmail: ritual.ownerEmail,
                  ),
                );

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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
          content: Column(
            mainAxisSize: MainAxisSize.min, // Biar tinggi pop-up nyesuaian isi
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk (cth: Hydrating Toner)",
                  hintText: "Masukkan nama produk...",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: "Keterangan/Kandungan (cth: Hyaluronic Acid)",
                  hintText: "Masukkan keterangan...",
                ),
              ),
            ],
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
                if (_titleController.text.isNotEmpty) {
                  await DBHelper().insertRitual(
                    RitualModel(
                      title: _titleController.text,
                      subtitle: _subtitleController.text.isEmpty
                          ? "Custom Product"
                          : _subtitleController.text,
                      isDone: false,
                      ownerEmail: PreferencesHandler.email,
                    ),
                  );

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
  }

  @override
  Widget build(BuildContext context) {
    // double persenHariIni = rituals.isEmpty
    //     ? 0.0
    //     : (jumlahDicentang / rituals.length) * 100;

    DateTime hariIni = DateTime.now();
    String tanggalDiformat = "${DateFormat('EEEE, MMMM d').format(hariIni)}th";

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Ritual",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tanggalDiformat,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),

              // buat header kalender tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  DateTime targetTanggal = hariIni.add(
                    Duration(days: index - 2),
                  );
                  String namaHari = DateFormat(
                    'E',
                  ).format(targetTanggal).toUpperCase();
                  String angkaTanggal = DateFormat('d').format(targetTanggal);

                  bool isActive =
                      targetTanggal.day == hariIni.day &&
                      targetTanggal.month == hariIni.month &&
                      targetTanggal.year == hariIni.year;

                  return CalendarDayCard(
                    day: namaHari,
                    date: angkaTanggal,
                    isActive: isActive,
                    hasDot: index == 1,
                  );
                }),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                                  "${rituals.length} steps ",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

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
                          onLongPress: () async {
                            await DBHelper().deleteRitual(ritual.id!);

                            await loadRituals();
                          },

                          child: RitualStepCard(
                            title: ritual.title,
                            subtitle: ritual.subtitle,
                            stepNumber: "Step $nomorUrut",
                            isDone: ritual.isDone,

                            onTap: () async {
                              await DBHelper().updateRitualStatus(
                                ritual.id!,
                                !ritual.isDone,
                              );

                              await loadRituals();
                            },

                            onDelete: () async {
                              await DBHelper().deleteRitual(ritual.id!);
                              await loadRituals();
                            },

                            onEdit: () {
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
