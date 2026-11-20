import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _role = "";
  String _organization = "";
  String _category = "Research"; // default
  DateTime? _startDate;
  DateTime? _endDate; // opsional: null berarti masih berlangsung
  String _description = "";

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final List<String> _categories = [
    'Research',
    'Work',
    'Organization',
    'Volunteering',
    'Other',
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // Mengubah DateTime menjadi teks dd/MM/yyyy tanpa package tambahan.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }

  Future<DateTime?> _selectDate(DateTime? initial) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
  }

  // Mengembalikan semua isian ke kondisi awal setelah dialog ditutup.
  void _resetForm() {
    _formKey.currentState!.reset();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _role = "";
      _organization = "";
      _category = "Research";
      _startDate = null;
      _endDate = null;
      _description = "";
    });
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peran: $_role'),
                Text('Organisasi: $_organization'),
                Text('Kategori: $_category'),
                Text('Tanggal Mulai: ${_formatDate(_startDate!)}'),
                Text(
                  'Tanggal Selesai: ${_endDate == null ? "Masih berlangsung" : _formatDate(_endDate!)}',
                ),
                Text('Deskripsi: $_description'),
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
    return Scaffold(
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
              // === Role ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Contoh: Asisten Dosen",
                    labelText: "Peran",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Peran tidak boleh kosong!";
                    }
                    if (value.trim().length > 100) {
                      return "Peran maksimal 100 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Organization ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Contoh: Fasilkom UI",
                    labelText: "Organisasi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _organization = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Organisasi tidak boleh kosong!";
                    }
                    if (value.trim().length > 100) {
                      return "Organisasi maksimal 100 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kategori",
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

              // === Start Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal mulai",
                    labelText: "Tanggal Mulai",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    final picked = await _selectDate(_startDate);
                    if (picked != null && mounted) {
                      setState(() {
                        _startDate = picked;
                        _startDateController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_startDate == null) {
                      return "Tanggal mulai harus dipilih!";
                    }
                    return null;
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
                    final picked = await _selectDate(_endDate ?? _startDate);
                    if (picked != null && mounted) {
                      setState(() {
                        _endDate = picked;
                        _endDateController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_endDate != null &&
                        _startDate != null &&
                        _endDate!.isBefore(_startDate!)) {
                      return "Tanggal selesai tidak boleh sebelum tanggal mulai!";
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSummary();
                      }
                    },
                    child: const Text(
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
    );
  }
}