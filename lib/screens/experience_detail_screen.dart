import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';

class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({super.key, required this.experience});

  final Experience experience;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final endedAt = experience.endedAt;
    final starredBy = experience.starredByNames.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(experience.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(label: Text(experience.categoryLabel)),
                    Chip(
                      avatar: Icon(
                        experience.isOngoing ? Icons.timelapse : Icons.event,
                        size: 18,
                      ),
                      label: Text(
                        endedAt == null
                            ? 'Masih berlangsung'
                            : 'Selesai: ${_formatDate(endedAt)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(experience.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      experience.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text('${experience.starCount} bintang'),
                  ],
                ),
                if (starredBy.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Diberi bintang oleh',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(starredBy),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
