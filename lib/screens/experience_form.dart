import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Key kategori mengikuti backend (lihat experienceCategories di model).
  static const String _defaultCategory = 'full-time';

  String _title = "";
  String _category = _defaultCategory;
  DateTime? _endDate; // opsional: null berarti masih berlangsung
  String _description = "";

  bool _isSubmitting = false;

  // Dinaikkan setiap form di-reset agar dropdown dibuat ulang dengan nilai awal.
  int _resetCount = 0;

  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _endDateController.dispose();
    super.dispose();
  }

  // True jika pengguna sudah mengisi sesuatu yang belum disimpan.
  bool get _hasUnsavedChanges =>
      _title.trim().isNotEmpty ||
      _description.trim().isNotEmpty ||
      _endDate != null ||
      _category != _defaultCategory;

  // Hanya tahun yang ditampilkan.
  String _formatYear(DateTime date) => date.toLocal().year.toString();

  Future<DateTime?> _selectDate(DateTime? initial) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
  }

  // Mengembalikan semua isian ke kondisi awal.
  void _resetForm() {
    _formKey.currentState!.reset();
    _endDateController.clear();
    setState(() {
      _title = "";
      _category = _defaultCategory;
      _endDate = null;
      _description = "";
      _resetCount++;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Dialog konfirmasi; true berarti pengguna ingin membuang isian.
  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buang perubahan?'),
          content: const Text('Isian yang belum disimpan akan hilang.'),
          actions: [
            TextButton(
              child: const Text('Lanjut Mengisi'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Buang'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null) return;

    final api = context.read<ApiClient>();
    final endDate = _endDate;
    final newExperience = Experience(
      title: _title.trim(),
      description: _description.trim(),
      category: _category,
      // Dikirim sebagai UTC (…Z) agar tidak ambigu zona waktu di server.
      endedAt: endDate == null
          ? null
          : DateTime.utc(endDate.year, endDate.month, endDate.day),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await api.createExperience(newExperience, token: token);
      if (!mounted) return;
      await _showSummary(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token tidak valid/kedaluwarsa: bersihkan sesi lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showMessage("Sesi berakhir. Silakan login lagi, lalu simpan kembali.");
        await ensureLoggedIn(context);
      } else if (e.statusCode == 403) {
        _showMessage(
          "Hanya pemilik portofolio yang dapat menambah pengalaman (403).",
        );
      } else {
        _showMessage(
          "Gagal menyimpan pengalaman (${e.statusCode}). Periksa isian.",
        );
      }
    } on Exception {
      if (!mounted) return;
      _showMessage("Tidak dapat terhubung ke server.");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Ringkasan dari data balasan server (201 Created), lalu kembali ke daftar.
  Future<void> _showSummary(Experience created) async {
    final endedAt = created.endedAt;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul: ${created.title}'),
                Text('Kategori: ${created.categoryLabel}'),
                Text(
                  'Tahun Selesai: ${endedAt == null ? "Masih berlangsung" : _formatYear(endedAt)}',
                ),
                Text('Deskripsi: ${created.description}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    if (!mounted) return;

    // Kosongkan form dulu agar PopScope tidak meminta konfirmasi lagi.
    _resetForm();

    // Buka daftar baru (initState memuat ulang data dari server) dan buang
    // halaman di antaranya, sehingga tumpukannya: menu -> daftar pengalaman.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ExperienceListScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Jika tidak ada isian, halaman boleh langsung ditutup.
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldDiscard = await _confirmDiscard();
        if (shouldDiscard && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Experience Form'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        drawer: const LeftDrawer(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Title ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Contoh: Asisten Dosen",
                      labelText: "Judul",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _title = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Judul tidak boleh kosong!";
                      }
                      if (value.trim().length > 100) {
                        return "Judul maksimal 100 karakter!";
                      }
                      return null;
                    },
                  ),
                ),

                // === Category ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_resetCount),
                    decoration: InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    initialValue: _category,
                    items: experienceCategories.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _category = newValue!;
                      });
                    },
                  ),
                ),

                // === End Date (opsional) ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Kosongkan jika masih berlangsung",
                      labelText: "Tanggal Selesai (opsional)",
                      suffixIcon: _endDate == null
                          ? const Icon(Icons.calendar_today)
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: "Hapus tanggal selesai",
                              onPressed: () {
                                setState(() {
                                  _endDate = null;
                                  _endDateController.clear();
                                });
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onTap: () async {
                      final picked = await _selectDate(_endDate);
                      if (picked != null && mounted) {
                        setState(() {
                          _endDate = picked;
                          _endDateController.text = _formatYear(picked);
                        });
                      }
                    },
                  ),
                ),

                // === Description ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Deskripsi pengalaman",
                      labelText: "Deskripsi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _description = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Deskripsi tidak boleh kosong!";
                      }
                      if (value.trim().length > 500) {
                        return "Deskripsi maksimal 500 karakter!";
                      }
                      return null;
                    },
                  ),
                ),

                // === Tombol Simpan ===
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.indigo),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Simpan",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
