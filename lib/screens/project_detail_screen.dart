import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final thumbnail = project.thumbnail?.trim();
    final link = project.link?.trim();
    final tags = project.tagList;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar hanya ditampilkan bila URL-nya tidak kosong.
              if (thumbnail != null && thumbnail.isNotEmpty)
                Image.network(
                  thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  // Jika gambar gagal dimuat, sembunyikan saja.
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: tags
                            .map((t) => Chip(label: Text(t)))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(project.description),
                    if (link != null && link.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Link',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SelectableText(link),
                    ],
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
