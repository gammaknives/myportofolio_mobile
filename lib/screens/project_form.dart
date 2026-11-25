import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _description = "";
  String _tags = "";
  String _link = "";
  String _thumbnail = "";
  bool _isSubmitting = false;

  // True jika pengguna sudah mengisi sesuatu yang belum disimpan.
  bool get _hasUnsavedChanges =>
      _title.trim().isNotEmpty ||
      _description.trim().isNotEmpty ||
      _tags.trim().isNotEmpty ||
      _link.trim().isNotEmpty ||
      _thumbnail.trim().isNotEmpty;

  // Mengembalikan semua isian ke kondisi awal.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _title = "";
      _description = "";
      _tags = "";
      _link = "";
      _thumbnail = "";
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

  // URL bersifat opsional di backend; bila diisi harus http/https dan
  // maksimal 200 karakter (batas URLField Django).
  String? _validateOptionalUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > 200) return "URL maksimal 200 karakter!";
    final uri = Uri.tryParse(text);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? null : "Masukkan URL yang valid (http:// atau https://)!";
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null) return;

    final api = context.read<ApiClient>();
    final link = _link.trim();
    final thumbnail = _thumbnail.trim();
    final newProject = Project(
      title: _title.trim(),
      description: _description.trim(),
      tags: _tags.trim(),
      link: link.isEmpty ? null : link,
      thumbnail: thumbnail.isEmpty ? null : thumbnail,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await api.createProject(newProject, token: token);
      if (!mounted) return;
      _showSummary(created);
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
          "Hanya pemilik portofolio yang dapat menambah proyek (403).",
        );
      } else {
        _showMessage(
          "Gagal menyimpan proyek (${e.statusCode}). Periksa isian.",
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

  // Ringkasan setelah server membalas 201 Created.
  void _showSummary(Project created) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul: ${created.title}'),
                Text('Deskripsi: ${created.description}'),
                Text('Tags: ${created.tags}'),
                Text('Link: ${created.link ?? "-"}'),
                Text('Thumbnail: ${created.thumbnail ?? "-"}'),
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
                // === Title ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Judul Proyek",
                      labelText: "Judul Proyek",
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
                        return "Judul proyek tidak boleh kosong!";
                      }
                      if (value.trim().length > 255) {
                        return "Judul maksimal 255 karakter!";
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

                // === Tags (Tech Stack) ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Contoh: Flutter, Django, Figma",
                      labelText: "Tags / Tech Stack (pisahkan dengan koma)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _tags = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Tags tidak boleh kosong!";
                      }
                      if (value.trim().length > 255) {
                        return "Tags maksimal 255 karakter!";
                      }
                      return null;
                    },
                  ),
                ),

                // === Project Link (opsional) ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: "https://... (opsional)",
                      labelText: "Tautan Proyek",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _link = value!;
                      });
                    },
                    validator: _validateOptionalUrl,
                  ),
                ),

                // === Thumbnail URL (opsional) ===
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: "https://... (opsional)",
                      labelText: "URL Gambar Proyek",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _thumbnail = value!;
                      });
                    },
                    validator: _validateOptionalUrl,
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
