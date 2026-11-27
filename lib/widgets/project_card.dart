import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna unik dari setiap item.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);

          void showMessage(String text) {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  backgroundColor: item.color,
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      Icon(item.icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(text),
                    ],
                  ),
                ),
              );
          }

          if (item.name == "Logout") {
            final auth = context.read<AuthState>();
            if (auth.isLoggedIn) {
              await auth.logout();
              showMessage("Kamu telah logout.");
            } else {
              showMessage("Kamu belum login.");
            }
            return;
          }

          showMessage("Kamu telah menekan tombol ${item.name}!");

          // Navigasi ke halaman yang sesuai.
          if (item.name == "Lihat Proyek") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProjectListScreen(),
              ),
            );
          } else if (item.name == "Tambah Proyek") {
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn || !context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProjectFormPage()),
            );
          } else if (item.name == "Lihat Pengalaman") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExperienceListScreen(),
              ),
            );
          } else if (item.name == "Tambah Pengalaman") {
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn || !context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExperienceFormPage(),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
