Gambaran Umum

Aplikasi portofolio pribadi berbasis Flutter yang dibuat untuk mata kuliah Pemrograman Berbasis Platform, dan menjadi versi mobile dari website portofolio Django saya. Proyek myportofolio_mobile dimulai pada Tugas Individu 7 dengan satu halaman utama (MyHomePage) yang menampilkan identitas, profil singkat, dan tiga tombol aksi. Pada Tugas Individu 8, aplikasi dikembangkan dengan drawer navigasi, formulir Tambah Proyek, dan formulir Tambah Pengalaman yang dilengkapi validasi serta dialog ringkasan isian. Kode dipisahkan ke folder screens/ (halaman) dan widgets/ (komponen yang dipakai ulang), sedangkan lib/main.dart hanya berisi bootstrap aplikasi dan konfigurasi tema.

Fitur
Halaman utama StatelessWidget di berkas terpisah MyHomePage berada di lib/screens/menu.dart, terpisah dari main.dart yang hanya menjalankan runApp() dan mengatur MaterialApp
Tiga kartu informasi (InfoCard) menampilkan NPM, nama lengkap, dan kelas PBP saya secara sejajar di bagian atas halaman
Kartu aksi (ItemCard) Lihat Proyek, Tambah Proyek, Tambah Pengalaman, dan Logout, masing-masing dengan ikon dan warna latar yang berbeda (oranye, hijau, ungu, merah) yang disimpan pada class ItemHomepage
SnackBar interaktif menekan kartu memunculkan pesan "Kamu telah menekan tombol [Nama Tombol]!" sesuai nama tombol yang ditekan
Drawer navigasi (LeftDrawer) satu widget drawer yang dipakai di halaman utama dan kedua halaman formulir, dengan opsi Home, Add Project, dan Add Experience
Formulir Tambah Proyek halaman ProjectFormPage dengan input nama, deskripsi, kategori, teknologi, dan tautan proyek, serta validasi isian wajib
Formulir Tambah Pengalaman halaman ExperienceFormPage yang mengikuti model Experience pada proyek Django: peran, organisasi, kategori, tanggal mulai, tanggal selesai (opsional), dan deskripsi
Validasi formulir isian wajib yang kosong atau hanya berisi spasi ditolak, panjang teks dibatasi (peran dan organisasi maksimal 100 karakter, deskripsi maksimal 500 karakter), dan tanggal selesai tidak boleh lebih awal dari tanggal mulai
Pemilih tanggal tanggal mulai dan selesai dipilih lewat showDatePicker(), sehingga format tanggal selalu konsisten
Dialog ringkasan setelah seluruh input lolos validasi dan tombol Simpan ditekan, AlertDialog menampilkan semua isian; tombol OK menutup dialog dan mengosongkan formulir
Analisis kode bersih flutter analyze dijalankan pada root proyek untuk memastikan tidak ada isu
Fitur Tambahan
Konfirmasi sebelum membuang isian (Tugas 8) jika pengguna sudah mengisi sebagian formulir lalu menekan tombol kembali (tombol AppBar, tombol sistem, atau tombol Back browser), muncul dialog "Buang perubahan?" dengan pilihan "Lanjut Mengisi" atau "Buang". Fitur ini memakai PopScope dan mencegah isian yang panjang hilang karena tidak sengaja. Jika formulir masih kosong atau sudah disimpan, halaman langsung ditutup tanpa dialog
Pemulihan nilai awal setelah menyimpan (Tugas 8) setelah dialog ringkasan ditutup, seluruh isian, termasuk dropdown kategori dan tanggal, kembali ke nilai awal sehingga pengiriman berikutnya tidak membawa data lama
SnackBar berwarna dengan ikon (Tugas 7) SnackBar mengambil warna dan ikon dari tombol yang ditekan, dan tampil melayang (SnackBarBehavior.floating)
Animasi fade-in pada kartu aksi (Tugas 7) setiap ItemCard muncul perlahan selama 600 ms memakai TweenAnimationBuilder dan Opacity
Bagian About (AboutCard) (Tugas 7) kartu profil dengan foto dari aset lokal di sisi kiri, serta nama, bio, dan daftar skill (Chip) di sisi kanan. Jika foto gagal dimuat, ditampilkan inisial nama
Latar belakang gradasi (Tugas 7) seluruh halaman memakai gradasi warna biru yang dipasang lewat builder pada MaterialApp
Halaman dapat di-scroll (Tugas 7) isi halaman utama dibungkus SingleChildScrollView agar tidak terjadi overflow pada layar kecil
Struktur Proyek
myportofolio_mobile/
├── assets/
│   └── pbpavatar.jpg           # foto untuk AboutCard
├── lib/
│   ├── main.dart               # bootstrap aplikasi, MaterialApp, tema, gradasi
│   ├── screens/
│   │   ├── menu.dart           # MyHomePage, InfoCard, AboutCard, ItemHomepage
│   │   ├── project_form.dart   # ProjectFormPage (StatefulWidget)
│   │   └── experience_form.dart# ExperienceFormPage (StatefulWidget)
│   └── widgets/
│       ├── left_drawer.dart    # LeftDrawer yang dipakai semua halaman
│       └── project_card.dart   # ItemCard dengan SnackBar dan navigasi
└── pubspec.yaml                # konfigurasi dependensi dan aset
Menjalankan Aplikasi
flutter pub get
flutter run -d chrome
flutter analyze

Setelah menambah atau mengubah aset pada pubspec.yaml, hentikan aplikasi sepenuhnya lalu jalankan ulang flutter run, karena hot reload dan hot restart tidak memuat aset baru.

Tech Stack
Flutter framework UI untuk membangun aplikasi dari satu basis kode, dijalankan di Chrome selama pengembangan
Dart bahasa pemrograman yang dipakai Flutter
Material 3 sistem desain bawaan (useMaterial3: true) dengan skema warna yang dibuat dari warna dasar indigo lewat ColorScheme.fromSeed

## Jawaban Pertanyaan Refleksi Tugas 7

1. Widget tree dan hubungan parent-child
Di Flutter, hampir semua yang tampil di layar adalah widget, mulai dari teks, tombol, hingga tata letak dan padding. Widget tidak berdiri sendiri, tetapi tersusun bersarang membentuk struktur pohon yang disebut **widget tree**. Widget paling atas adalah root (pada proyek ini `MyApp` yang membangun `MaterialApp`), dan setiap widget di bawahnya adalah turunan (child) dari widget di atasnya.

Hubungan parent-child bekerja seperti berikut:
- Parent menentukan di mana dan dalam batasan ukuran apa child ditempatkan. Flutter menerapkan aturan "constraints turun, ukuran naik, parent yang menentukan posisi": parent memberi batasan ukuran (min/maks lebar dan tinggi) kepada child, child memilih ukurannya sendiri dalam batasan itu, lalu parent menentukan posisinya.
- Widget dengan satu child memakai properti `child`, misalnya `Padding`, `Center`, `Card`, atau `Container`. Widget dengan banyak child memakai properti `children`, misalnya `Column`, `Row`, dan `GridView`.
- Perubahan pada sebuah widget akan membangun ulang bagian pohon di bawahnya, sehingga pohon yang rapi dan dipecah ke widget kecil membuat aplikasi mudah dibaca dan dirawat.

Pada proyek ini, pohonnya kira-kira seperti berikut:
```
MyApp
└── MaterialApp
    └── MyHomePage
        └── Scaffold
            ├── AppBar → Text
            └── body: Padding
                └── SingleChildScrollView
                    └── Column
                        ├── Row → InfoCard × 3
                        ├── AboutCard
                        └── Center → Column
                            ├── Text (sambutan)
                            └── GridView.count → ItemCard × 3
```
Di sini `Scaffold` adalah parent dari `AppBar` dan `body`, `Column` adalah parent dari `Row`, `AboutCard`, dan `Center`, dan setiap `ItemCard` adalah child dari `GridView`.

2. Widget yang digunakan dan fungsinya

Widget bawaan Flutter

| Widget | Fungsi pada proyek ini |
|---|---|
| `MaterialApp` | Root aplikasi bergaya Material: mengatur judul, tema, dan halaman awal (`home`), serta `builder` untuk gradasi latar |
| `Scaffold` | Kerangka dasar halaman: menyediakan `appBar` dan `body`, serta tempat SnackBar ditampilkan |
| `AppBar` | Bar di bagian atas halaman yang berisi judul "MyPortfolio" |
| `Text` | Menampilkan teks: judul, isi kartu, sambutan, nama, bio, dan label tombol |
| `Padding` | Memberi jarak di sekeliling child |
| `SingleChildScrollView` | Membuat isi halaman dapat di-scroll agar tidak overflow di layar kecil |
| `Column` | Menyusun child secara vertikal |
| `Row` | Menyusun child secara horizontal, dipakai untuk tiga `InfoCard` dan susunan foto-teks di `AboutCard` |
| `Center` | Menempatkan child di tengah |
| `SizedBox` | Memberi jarak kosong (tinggi/lebar tetap), dan membuat `AboutCard` selebar penuh |
| `GridView.count` | Menampilkan tombol dalam kisi 3 kolom; `shrinkWrap` dan `NeverScrollableScrollPhysics` dipakai karena berada di dalam `SingleChildScrollView` |
| `Card` | Kartu dengan bayangan (elevasi) untuk `InfoCard` dan `AboutCard` |
| `Container` | Kotak serbaguna untuk mengatur lebar, padding, dan dekorasi (termasuk gradasi di `main.dart`) |
| `Material` | Permukaan Material dengan warna dan sudut membulat untuk `ItemCard` |
| `InkWell` | Membuat area dapat ditekan, dengan efek riak (ripple) dan callback `onTap` |
| `Icon` | Menampilkan ikon pada tombol dan SnackBar |
| `TweenAnimationBuilder` | Menjalankan animasi nilai 0 ke 1 untuk efek fade-in |
| `Opacity` | Mengatur transparansi child sesuai nilai animasi |
| `SnackBar` | Pesan singkat di bagian bawah layar saat tombol ditekan |
| `ClipRRect` | Memotong child (foto) dengan sudut membulat |
| `Image.asset` | Menampilkan foto profil dari aset lokal, dengan `errorBuilder` sebagai cadangan |
| `Expanded` | Membuat kolom teks mengisi sisa lebar pada `Row` agar teks turun baris otomatis |
| `Wrap` | Menyusun `Chip` skill dan memindahkannya ke baris baru bila tidak muat |
| `Chip` | Label kecil untuk setiap skill |

Widget dan class buatan sendiri

| Nama | Fungsi |
|---|---|
| `MyApp` | `StatelessWidget` root yang membangun `MaterialApp` |
| `MyHomePage` | `StatelessWidget` halaman utama yang menyusun seluruh tampilan |
| `InfoCard` | Kartu informasi dengan `title` dan `content` (NPM, Name, Class) |
| `AboutCard` | Kartu profil dengan foto, nama, bio, dan daftar skill |
| `ItemCard` | Kartu tombol aksi yang menampilkan ikon, nama, dan memunculkan SnackBar saat ditekan |
| `ItemHomepage` | Bukan widget, melainkan class data yang menyimpan `name`, `icon`, dan `color` untuk setiap tombol |

Selain itu, `ScaffoldMessenger` dipakai (lewat `ScaffoldMessenger.of(context)`) untuk menampilkan dan menyembunyikan SnackBar, serta `Theme`, `ThemeData`, `ColorScheme`, `BoxDecoration`, dan `LinearGradient` untuk tema dan gradasi.

3. Fungsi `MaterialApp` dan alasan dipakai sebagai root
`MaterialApp` adalah widget yang membungkus aplikasi dengan semua hal dasar yang dibutuhkan aplikasi bergaya Material Design. Fungsinya antara lain:
- Tema (`theme`): mengatur warna, tipografi, dan gaya komponen untuk seluruh aplikasi. Pada proyek ini memakai `ColorScheme.fromSeed`.
- Halaman awal (`home`) dan navigasi (`routes`, `Navigator`): menentukan halaman pertama dan mengelola perpindahan antar halaman.
- Judul aplikasi (`title`), lokalisasi, dan pengaturan seperti `debugShowCheckedModeBanner`.
- `builder`: membungkus semua halaman dengan widget tambahan, yang saya pakai untuk memasang gradasi latar.
- Menyediakan widget pendukung seperti `Theme`, `Navigator`, `MediaQuery`, dan `ScaffoldMessenger` ke seluruh pohon di bawahnya, sehingga `Scaffold`, `AppBar`, `SnackBar`, `Card`, dan `Theme.of(context)` dapat bekerja.

`MaterialApp` umumnya dipakai sebagai root karena semua pengaturan global tersebut harus tersedia bagi semua widget di bawahnya. Dengan menempatkannya di paling atas, setiap halaman otomatis mewarisi tema dan navigasi yang sama tanpa perlu diatur ulang, sehingga tampilan aplikasi konsisten.

4. `StatelessWidget` vs `StatefulWidget`
`StatelessWidget` adalah widget yang tidak menyimpan state yang berubah. Tampilannya sepenuhnya ditentukan oleh properti yang diterima saat dibuat, dan hanya dibangun ulang bila parent memberikan data baru. Ia hanya punya satu class dengan method `build()`.

`StatefulWidget` adalah widget yang tampilannya dapat berubah selama aplikasi berjalan karena memiliki state. Ia terdiri dari dua class: class widget (yang bersifat immutable) dan class `State` yang menyimpan data yang berubah dan method `build()`. Ketika data berubah, kita memanggil `setState()` agar Flutter menjalankan `build()` ulang. Class `State` juga punya siklus hidup seperti `initState()` dan `dispose()`.

| | `StatelessWidget` | `StatefulWidget` |
|---|---|---|
| State internal | Tidak ada | Ada, disimpan di class `State` |
| Class | Satu | Dua (widget + `State`) |
| Pembaruan tampilan | Saat parent mengirim data baru | Lewat `setState()` |
| Contoh | Teks statis, ikon, kartu informasi | Counter, form, checkbox, animasi terkontrol |

Pilih `StatelessWidget` jika tampilan hanya bergantung pada data yang diterima dan tidak berubah oleh interaksi di dalam widget itu sendiri. Pilih `StatefulWidget` jika widget perlu mengingat dan mengubah data sendiri, misalnya nilai input form, status loading, nilai counter, atau `AnimationController`.

Pada proyek ini, semua widget adalah `StatelessWidget`, sesuai ketentuan tugas, karena halaman hanya menampilkan data tetap dan SnackBar dikelola oleh `ScaffoldMessenger`. Efek fade-in memakai `TweenAnimationBuilder` yang mengelola animasinya sendiri, sehingga saya tidak perlu `StatefulWidget`. Jika nanti ada fitur seperti form tambah proyek atau tombol dark mode, `StatefulWidget` baru akan diperlukan.

5. `BuildContext`
`BuildContext` adalah objek yang merepresentasikan **lokasi sebuah widget di dalam widget tree**. Setiap widget yang di-build memiliki context-nya sendiri, dan context itu "tahu" siapa parent dan ancestor-nya.

Pentingnya `BuildContext`:
- Mengakses data dari ancestor di atas pohon, seperti `Theme.of(context)`, `MediaQuery.of(context)`, `Navigator.of(context)`, dan `ScaffoldMessenger.of(context)`. Flutter mencari ke atas pohon dari context tersebut sampai menemukan widget yang dimaksud.
- Menentukan posisi widget, sehingga widget dapat bereaksi terhadap lingkungannya (tema, ukuran layar, navigasi).

Penggunaan di dalam `build(BuildContext context)` pada proyek ini:
- `Theme.of(context).colorScheme.primary` untuk mengambil warna utama dari tema yang diatur di `MaterialApp`, dipakai pada `AppBar` dan avatar cadangan.
- `MediaQuery.of(context).size.width / 3.5` di `InfoCard` untuk menyesuaikan lebar kartu dengan lebar layar.
- `ScaffoldMessenger.of(context)` di `ItemCard` untuk menampilkan SnackBar pada `Scaffold` terdekat.

Method `build` menerima context dari Flutter, dan context yang dipakai harus berada di bawah widget yang dicari. Misalnya, context yang dipakai untuk `ScaffoldMessenger.of(context)` harus berasal dari widget yang berada di dalam `MaterialApp`/`Scaffold`, bukan dari widget yang justru membuatnya.

6. Hot reload vs hot restart
Hot reload menyuntikkan kode yang sudah diubah ke Dart VM yang sedang berjalan, lalu membangun ulang widget tree, tanpa menghapus state aplikasi. Prosesnya sangat cepat (biasanya di bawah satu detik), sehingga cocok untuk mengubah tampilan seperti warna, teks, padding, atau tata letak dan langsung melihat hasilnya. Pada proyek ini, mengubah warna tombol atau memperbesar foto di `AboutCard` cukup dengan hot reload.

Hot restart memuat ulang seluruh kode dan menjalankan aplikasi dari awal, sehingga **semua state kembali ke kondisi awal** (misalnya counter kembali ke 0). Ia lebih lambat dari hot reload, tetapi lebih cepat dari menjalankan ulang aplikasi sepenuhnya.

Full restart adalah menghentikan aplikasi lalu menjalankannya lagi (`flutter run`), yang membangun ulang aplikasi dari awal.

| | Hot reload | Hot restart | Full restart |
|---|---|---|---|
| Kode diperbarui | Ya | Ya | Ya |
| State dipertahankan | Ya | Tidak | Tidak |
| Kecepatan | Paling cepat | Sedang | Paling lambat |

Kapan kita tidak bisa mengandalkan hot reload saja:
- Mengubah fungsi `main()` atau kode inisialisasi di dalamnya, karena hanya dijalankan sekali di awal. Perlu hot restart.
- Mengubah nilai awal state (field di class `State`, variabel global, atau field `static`), karena nilai yang sudah ada tidak dihitung ulang. Perlu hot restart.
- Mengubah `initState()` atau mengubah tipe widget, misalnya dari `StatelessWidget` ke `StatefulWidget`, serta mengubah enum atau tipe generik. Umumnya perlu hot restart.
- Menambah atau mengubah aset dan dependensi di `pubspec.yaml` (gambar, font, package). Perlu `flutter pub get` dan full restart. Contohnya `assets/profile.jpg` pada proyek ini yang tidak muncul sebelum aplikasi dijalankan ulang sepenuhnya.
- Mengubah kode native (folder `android/`, `ios/`, `web/`) atau konfigurasi Gradle, karena harus dikompilasi ulang. Perlu full restart.

## Jawaban Pertanyaan Refleksi Tugas 8

1. Navigator.push(), Navigator.pushReplacement(), dan Navigator.pop()

Navigator mengelola halaman sebagai tumpukan (stack) route. Ketiga method berbeda dalam cara mengubah tumpukan tersebut:

Navigator.push() menambahkan halaman baru di atas halaman yang sedang tampil. Halaman lama tetap ada di bawahnya, sehingga pengguna dapat kembali dengan tombol Back (tombol panah AppBar, tombol sistem, atau tombol Back browser).
Navigator.pushReplacement() mengganti halaman yang sedang tampil dengan halaman baru. Halaman lama dikeluarkan dari tumpukan, sehingga tidak ada tujuan untuk kembali ke halaman tersebut.
Navigator.pop() mengeluarkan halaman paling atas dari tumpukan dan menampilkan halaman di bawahnya. Method ini dipakai untuk menutup dialog maupun halaman lewat kode, dan dapat membawa nilai balikan (misalnya true atau false pada dialog konfirmasi).

Untuk membuka formulir dari kartu aksi, saya memakai Navigator.push(). Pada ItemCard, setelah SnackBar ditampilkan, nama kartu diperiksa lalu Navigator.push(context, MaterialPageRoute(builder: (context) => const ExperienceFormPage())) dipanggil (atau ProjectFormPage untuk kartu Tambah Proyek). Dengan push, formulir berada di atas halaman utama, sehingga pengguna dapat kembali dengan tombol Back bawaan.

Opsi Home di drawer memanggil Navigator.pushReplacement() ke MyHomePage(). Halaman yang sedang tampil (misalnya formulir) beserta drawer-nya diganti oleh halaman utama yang baru, sehingga pengguna langsung melihat halaman utama. Opsi Add Project dan Add Experience di drawer memakai pola yang sama, sehingga berpindah lewat drawer tidak menumpuk halaman. Ada satu catatan: jika formulir dibuka dari kartu (memakai push) lalu pengguna memilih Home, halaman utama yang lama masih ada di bawah halaman utama yang baru. Tombol Back pada halaman utama yang baru akan menuju halaman utama yang lama, tetapi tujuan Home tetap tercapai.

2. Scaffold, AppBar, dan Drawer untuk struktur yang konsisten

Scaffold menyediakan kerangka dasar halaman dengan posisi yang sudah ditentukan: appBar di atas, body di tengah, dan drawer di sisi kiri, serta tempat tampil untuk SnackBar. Karena setiap halaman (utama, Tambah Proyek, Tambah Pengalaman) memakai susunan yang sama, pengguna selalu menemukan judul halaman di tempat yang sama dan dapat membuka menu dari tombol hamburger yang sama. AppBar memberi identitas halaman dan, ketika ada drawer, otomatis menampilkan ikon menu serta tombol kembali bila halaman dibuka lewat push.

LeftDrawer ditulis sebagai satu widget lalu dipasang pada ketiga halaman (drawer: const LeftDrawer()). Dengan begitu, opsi navigasi selalu sama dan perubahan menu cukup dilakukan di satu file.

Contoh penggunaan warna tema: warna indigo dipakai di lebih dari satu halaman. Tema aplikasi dibuat dari ColorScheme.fromSeed(seedColor: Colors.indigo) sehingga AppBar halaman utama memakai colorScheme.primary. AppBar kedua formulir memakai Colors.indigo dengan foregroundColor putih, tombol Simpan di kedua formulir memakai Colors.indigo, dan DrawerHeader pada LeftDrawer juga memakai Colors.indigo. Hasilnya, semua halaman terasa satu aplikasi yang sama.

3. Alasan tata letak formulir dan peran widget jarak serta penggulir

Formulir disusun dalam satu kolom vertikal (Column dengan crossAxisAlignment: CrossAxisAlignment.start), dengan satu input per baris dan tombol Simpan di akhir. Tata letak ini dipilih karena layar ponsel sempit, sehingga input yang berdampingan akan terlalu kecil untuk diketik dan disentuh. Urutan dari atas ke bawah juga mengikuti alur pengisian yang wajar dan membuat pesan kesalahan muncul tepat di bawah kolom terkait.

Padding (EdgeInsets.all(8.0)) pada setiap input memberi jarak antar kolom dan dari tepi layar, sehingga kolom tidak saling menempel, mudah disentuh dengan jari, dan teks kesalahan tetap terbaca.
SingleChildScrollView membungkus Column agar isi formulir dapat digulir. Tanpa widget ini, formulir yang lebih tinggi daripada layar, terutama saat papan ketik tampil dan mengecilkan area yang tersedia, akan menyebabkan overflow dan tombol Simpan tidak dapat dijangkau. Dengan penggulir, semua input dan tombol Simpan tetap bisa dicapai pada layar sempit.
Scaffold secara bawaan menyesuaikan tinggi body ketika papan ketik muncul, dan penggulir memungkinkan pengguna menggulir ke kolom yang tertutup.
Isi dialog ringkasan juga dibungkus SingleChildScrollView agar deskripsi yang panjang tetap dapat dibaca.
Kolom deskripsi memakai maxLines: 5 agar teks panjang punya ruang yang cukup, dan kolom tanggal dibuat sebagai TextFormField read-only yang membuka showDatePicker() sehingga pesan validasinya tampil seperti kolom lainnya.

4. Peran GlobalKey<FormState>, validator, dan validate()
GlobalKey<FormState> (_formKey) dipasang pada widget Form sebagai penanda. Key ini memberi akses ke FormState dari luar pohon widget form, misalnya dari onPressed tombol Simpan, sehingga kode dapat memanggil validate() dan reset() pada form tersebut.
validator adalah fungsi pada setiap TextFormField (atau field lain) yang menerima nilai saat ini dan mengembalikan String?. Jika mengembalikan teks, teks itu menjadi pesan kesalahan; jika mengembalikan null, isian dianggap valid.
validate() menjalankan seluruh validator pada field di dalam form, menampilkan pesan kesalahan pada kolom yang bermasalah, dan mengembalikan true hanya jika semua validator mengembalikan null.

Saat tombol Simpan ditekan, onPressed memanggil _formKey.currentState!.validate(). Jika hasilnya false, pesan kesalahan muncul di kolom terkait dan dialog tidak ditampilkan. Jika true, showDialog() menampilkan ringkasan isian.

Contoh nilai yang ditolak: pada kolom Peran, isian berupa tiga spasi ("   ") ditolak dengan pesan "Peran tidak boleh kosong!" karena validator memeriksa value.trim().isEmpty. Contoh lain, tanggal selesai 1 Januari 2024 dengan tanggal mulai 1 Juni 2024 ditolak dengan pesan "Tanggal selesai tidak boleh sebelum tanggal mulai!".

Memilih jenis input atau papan ketik saja belum cukup karena jenis papan ketik hanya memengaruhi tampilan tombol yang disarankan, bukan isi yang dapat masuk. Pengguna masih dapat menempel (paste) teks, memakai papan ketik fisik atau browser di Chrome, atau mengetik spasi saja. Selain itu, jenis input tidak dapat memeriksa aturan antar-kolom seperti urutan tanggal mulai dan selesai, atau batas panjang teks. Pemilih tanggal memang memastikan format tanggal benar, tetapi tidak mencegah urutan tanggal yang terbalik, sehingga validasi tetap diperlukan.

## AI Disclosure
Saya menggunakan AI terutama untuk dua hal: brainstorming dan memperbaiki bug. Saat saya bingung mengenai apa yang harus ditambahkan agar situs web lebih menarik, saya meminta ide dari chatbot AI seperti Gemini milik Google dan Claude. Salah satu contohnya adalah pada fitur tambahan. Saya awalnya ingin menambahkan form baru untuk edit atau delete. Claude memberi ide untuk membuat sebuh pop up yang muncul saat pencet tombol back setelah mengisi form sebagai warning jika tidak ingin menyimpan isian form tersebut.
Berikut adalah prompt yang saya gunakan:
"What should the extra feature be? Should I make a form for deleting or editing projects/experiences?"
Selain untuk bertukar pikiran, saya menggunakan AI saat mengalami kendala dengan bug, untuk merapikan kode yang berantakan, serta menambahkan komentar agar kode lebih mudah dipahami. Meskipun menggunakan AI, saya selalu memeriksa ulang kodenya dan tidak sekadar copy paste, melainkan juga melakukan penyesuaian dan perubahan sendiri. Hal ini karena AI umumnya tidak memahami cara membuat tampilan visual yang menarik bagi manusia. Jadi, saya menggunakan kode dari AI sebagai kerangka dasar yang kemudian saya modifikasi sendiri, biasanya terkait warna, ukuran, dan tingkat kecerahan.

## Author
**Nuno Mikael Nugroho**
NPM: 2506624865
Class: PBP D
S1 Ilmu Komputer, Fakultas Ilmu Komputer, Universitas Indonesia

## License
This project is created for academic purposes as part of coursework at Universitas Indonesia.