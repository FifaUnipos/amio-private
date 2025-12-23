import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Uncomment if using SVGs

class BantuanPageMobile extends StatelessWidget {
  const BantuanPageMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPageMobile(token: checkToken),
            ),
          ),
        ),
        title: Text(
          'Bantuan',
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          // Illustration Area
          Center(
            child: Container(
              height: 200,
              width: 300,
              // placeholder for the illustration in Image 2
              decoration: BoxDecoration(
                color: primary200.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  PhosphorIcons.lifebuoy,
                  size: 80,
                  color: primary500,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text("Versi 1.0", style: heading3(FontWeight.w400, bnw500, 'Outfit')),
          SizedBox(height: 32),

          // Menu Options
          _buildMenuItem(
            context,
            icon: PhosphorIcons.question,
            text: "Pertanyaan yang sering ditanyakan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQPageMobile()),
              );
            },
          ),
          Divider(height: 1, color: bnw200),
          _buildMenuItem(
            context,
            icon: PhosphorIcons.headset,
            text: "Butuh Bantuan",
            onTap: () {
              _showButuhBantuanModal(context);
            },
          ),
          Divider(height: 1, color: bnw200),
          _buildMenuItem(
            context,
            icon: PhosphorIcons.info,
            text: "Info Aplikasi",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoAplikasiPage()),
              );
            },
          ),
          Divider(height: 1, color: bnw200),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: bnw900),
              child: Icon(icon, color: bnw100, size: 16),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: bnw500),
          ],
        ),
      ),
    );
  }

  void _showButuhBantuanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: bnw100,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bnw300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Butuh Bantuan?",
                style: heading1(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 24),
              // Illustration
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: primary200.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.question,
                  size: 80,
                  color: primary500,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Silahkan Hubungi Customer Service untuk mengatasi permasalahan anda.",
                textAlign: TextAlign.center,
                style: heading3(FontWeight.w400, bnw600, 'Outfit'),
              ),
              SizedBox(height: 32),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: primary500),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Gak Jadi",
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Implement Whatsapp/Chat logic here
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.whatsapp_logo, color: bnw100),
                      SizedBox(width: 8),
                      Text(
                        "Chat Customer Service",
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// --- FAQ Page Mobile ---

class FAQPageMobile extends StatefulWidget {
  const FAQPageMobile({Key? key}) : super(key: key);

  @override
  State<FAQPageMobile> createState() => _FAQPageMobileState();
}

class _FAQPageMobileState extends State<FAQPageMobile> {
  String selectedCategory = "Semua";
  final List<String> categories = [
    "Semua",
    "Toko",
    "Produk",
    "Akun",
    "Transaksi",
    "Keuangan",
  ];

  // Updated listStructure to include categories
  final List<Map<String, dynamic>> questions = [
    {
      "category": "Toko",
      "question": "Apakah bisa menambahkan toko sekaligus",
      "answer":
          "Ya, anda bisa menambahkan toko sekaligus melalui menu pengaturan toko.",
    },
    {
      "category": "Toko",
      "question": "Bagaimana cara mengubah alamat toko?",
      "answer": "Masuk ke menu profil toko, lalu klik ubah alamat.",
    },
    {
      "category": "Produk",
      "question": "Berapa maksimal produk yang bisa diupload?",
      "answer": "Tidak ada batasan jumlah produk untuk akun premium.",
    },
    {
      "category": "Akun",
      "question": "Cara mengganti password akun?",
      "answer": "Masuk ke pengaturan akun -> Keamanan -> Ganti Password.",
    },
    {
      "category": "Toko",
      "question": "Apakah bisa menambahkan toko sekaligus",
      "answer":
          "Ya, anda bisa menambahkan toko sekaligus melalui menu pengaturan toko.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter questions based on selection
    List<Map<String, dynamic>> filteredQuestions = selectedCategory == "Semua"
        ? questions
        : questions.where((q) => q['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pertanyaan dan Jawaban',
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bnw200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(PhosphorIcons.magnifying_glass, color: bnw500),
                  hintText: "Cari Pertanyaan atau Jawaban",
                  hintStyle: heading4(FontWeight.w400, bnw500, 'Outfit'),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Categories
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kategori",
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: categories.map((cat) {
                      bool isSelected = selectedCategory == cat;
                      IconData? catIcon;
                      if (cat == "Semua")
                        catIcon = PhosphorIcons.article; // Placeholder icon
                      if (cat == "Toko") catIcon = PhosphorIcons.storefront;
                      if (cat == "Produk") catIcon = PhosphorIcons.package;
                      if (cat == "Akun") catIcon = PhosphorIcons.user;
                      if (cat == "Transaksi")
                        catIcon = PhosphorIcons.shopping_cart;
                      if (cat == "Keuangan") catIcon = PhosphorIcons.wallet;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 12),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            // color: isSelected ? primary200 : bnw100,
                            // border: Border.all(color: isSelected ? primary500 : bnw300),
                            // UI in Image 4 shows icons in squares then text below
                            color: Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? primary200 : bnw100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: bnw200),
                                ),
                                child: Icon(
                                  catIcon ?? PhosphorIcons.star,
                                  color: isSelected ? primary500 : bnw900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                cat,
                                style: heading4(
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  isSelected ? primary500 : bnw900,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Question List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pertanyaan",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredQuestions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: bnw200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                filteredQuestions[index]['question'],
                                style: heading3(
                                  FontWeight.w500,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Text(
                                    filteredQuestions[index]['answer'],
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw600,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for Info Aplikasi
class InfoAplikasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        title: Text(
          "Info Aplikasi",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Halaman Info Aplikasi (Kebijakan Privasi dll)"),
      ),
    );
  }
}
