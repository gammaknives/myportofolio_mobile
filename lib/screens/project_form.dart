import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const String _defaultCategory = "Web Development";

  String _projectName = "";
  String _description = "";
  String _category = _defaultCategory;
  String _technologies = "";
  String _projectLink = "";

  // Dinaikkan setiap form di-reset agar dropdown dibuat ulang dengan nilai awal.
  int _resetCount = 0;

  final List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  // True jika pengguna sudah mengisi sesuatu yang belum disimpan.
  bool get _hasUnsavedChanges =>
      _projectName.trim().isNotEmpty ||
      _description.trim().isNotEmpty ||
      _technologies.trim().isNotEmpty ||
      _projectLink.trim().isNotEmpty ||
      _category != _defaultCategory;

  // Mengembalikan semua isian ke kondisi awal.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _projectName = "";
      _description = "";
      _category = _defaultCategory;
      _technologies = "";
      _projectLink = "";
      _resetCount++;
    });
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

  // Ringkasan isian setelah semua input lolos validasi.
  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Proyek: $_projectName'),
                Text('Deskripsi: $_description'),
                Text('Kategori: $_category'),
                Text('Teknologi: $_technologies'),
                Text('Tautan: $_projectLink'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
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
          title: const Text('Add Project Form'),
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
                // === Project Name ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Nama Proyek",
                      labelText: "Nama Proyek",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _projectName = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Nama proyek tidak boleh kosong!";
                      }
                      return null;
                    },
                  ),
                ),

                // === Description ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Deskripsi Proyek",
                      labelText: "Deskripsi Proyek",
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
                        return "Deskripsi proyek tidak boleh kosong!";
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
                      labelText: "Kategori Proyek",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    initialValue: _category,
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _category = newValue!;
                      });
                    },
                  ),
                ),

                // === Technologies ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Contoh: Flutter, Django, Figma",
                      labelText: "Teknologi yang Digunakan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _technologies = value!;
                      });
                    },
                  ),
                ),

                // === Project Link ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "URL Proyek (opsional)",
                      labelText: "Tautan Proyek",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _projectLink = value!;
                      });
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _showSummary();
                        }
                      },
                      child: const Text(
                        "Save",
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