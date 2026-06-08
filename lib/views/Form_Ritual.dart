import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/widgets/bar_card.dart';
import 'package:skinoura/widgets/calendar_card.dart';
import 'package:skinoura/widgets/ritual_card.dart';

class RitualPage extends StatefulWidget {
  const RitualPage({super.key});

  @override
  State<RitualPage> createState() => _RitualPageState();
}

class _RitualPageState extends State<RitualPage> {
  // 1. KONTROLLER UNTUK MENANGKAP INPUTAN TEXT
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  // 2. LIST DATA YANG SEKARANG BISA DITAMBAH (GA PAKE FINAL)
  final List<Map<String, String>> _morningSteps = [
    {
      "id": "step1",
      "title": "Gentle Cleanser",
      "subtitle": "Hydrating Oat Wash",
    },
    {
      "id": "step2",
      "title": "Vitamin C Serum",
      "subtitle": "15% L-Ascorbic Acid • Apply 3-4 drops",
    },
    {
      "id": "step3",
      "title": "Lightweight Moisturizer",
      "subtitle": "Ceramide Complex",
    },
    {
      "id": "step4",
      "title": "Mineral SPF 50",
      "subtitle": "Zinc Oxide formulation • Don't skip!",
    },
  ];

  Map<String, bool> _stepStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadSavedRitualData();
  }

  @override
  void dispose() {
    // Bersihin controller pas halaman ditutup biar ga kebocoran memori
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedRitualData() async {
    Map<String, bool> tempStatuses = {};
    for (var step in _morningSteps) {
      String id = step["id"]!;
      bool status = PreferencesHandler.getStepStatus(id);
      tempStatuses[id] = status;
    }
    setState(() {
      _stepStatuses = tempStatuses;
    });
  }

  // ===========================================================================
  // 3. FUNGSI POP-UP UNTUK TAMBAH SKINCARE LANGSUNG DARI TAMPILAN
  // ===========================================================================
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
                Navigator.pop(context); // Tutup Pop-up
              },
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  // Bikin ID unik berdasarkan timestamp waktu saat ini
                  String uniqueId =
                      "step_${DateTime.now().millisecondsSinceEpoch}";

                  setState(() {
                    // Masukkan data baru hasil ketikan user ke dalam List
                    _morningSteps.add({
                      "id": uniqueId,
                      "title": _titleController.text,
                      "subtitle": _subtitleController.text.isEmpty
                          ? "Custom Product"
                          : _subtitleController.text,
                    });
                    _stepStatuses[uniqueId] =
                        false; // Set status awal belum dicentang
                  });

                  // Bersihkan form inputan
                  _titleController.clear();
                  _subtitleController.clear();
                  Navigator.pop(context); // Tutup Pop-up
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
    // LOGIKA HITUNG PERSENTASE DINAMIS (.length)
    int jumlahDicentang = 0;
    for (var step in _morningSteps) {
      String id = step["id"]!;
      if (_stepStatuses[id] == true) {
        jumlahDicentang++;
      }
    }

    double persenHariIni = _morningSteps.isEmpty
        ? 0.0
        : (jumlahDicentang / _morningSteps.length) * 100;

    DateTime hariIni = DateTime.now();
    String tanggalDiformat = "${DateFormat('EEEE, MMMM d').format(hariIni)}th";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A. HEADER SECTION
              const Text(
                "Today's Ritual",
                style: TextStyle(
                  fontSize: 28,
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

              // B. CALENDAR TIMELINE
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

              // C. MORNING PROTOCOL CARD (DENGAN TOMBOL TAMBAH "+")
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
                                  "Morning Protocol",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${_morningSteps.length} steps • ~5 mins",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 🟢 DI SINI TOMBOL TAMBAHNYA, BANG!
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF436155),
                            size: 28,
                          ),
                          onPressed:
                              _showAddSkincareDialog, // Pas diklik panggil pop-up dialog
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LOOPING LIST DATA SKINCARE
                    Column(
                      children: _morningSteps.map((step) {
                        String id = step["id"]!;
                        bool isDone = _stepStatuses[id] ?? false;
                        int nomorUrut = _morningSteps.indexOf(step) + 1;

                        return RitualStepCard(
                          title: step["title"]!,
                          subtitle: step["subtitle"]!,
                          stepNumber: "Step $nomorUrut",
                          isDone: isDone,
                          onTap: () async {
                            setState(() {
                              _stepStatuses[id] = !isDone;
                            });
                            await PreferencesHandler.saveStepStatus(
                              id,
                              !isDone,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // D. CONSISTENCY TRACKER SECTION
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
                        const Text(
                          "Consistency",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF436155),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${persenHariIni.toInt()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You're on a 3-day streak. Keep building that barrier!",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const BarChartCard(day: "S", percentage: 100),
                        const BarChartCard(day: "M", percentage: 100),
                        const BarChartCard(day: "T", percentage: 100),
                        BarChartCard(day: "W", percentage: persenHariIni),
                        const BarChartCard(day: "T", percentage: 0),
                        const BarChartCard(day: "F", percentage: 0),
                        const BarChartCard(day: "S", percentage: 0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
