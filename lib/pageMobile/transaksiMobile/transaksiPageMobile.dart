import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// Import komponen-komponen Anda
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
// Import model dan API
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/models/tokoModel/riwayatTransaksiTokoModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';

// =========================================================================
// == WIDGET UTAMA (Dengan TabBarController) ==
// =========================================================================
class TransaksiMobilePage extends StatefulWidget {
  final String token;
  const TransaksiMobilePage({Key? key, required this.token}) : super(key: key);

  @override
  State<TransaksiMobilePage> createState() => _TransaksiMobilePageState();
}

class _TransaksiMobilePageState extends State<TransaksiMobilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        // Menghilangkan judul default
        titleSpacing: 0,
        // Judul diganti dengan TabBar
        title: TabBar(
          controller: _tabController,
          indicatorColor: primary500,
          labelColor: primary500,
          unselectedLabelColor: bnw500,
          labelStyle: body1(FontWeight.w600, primary500, 'Outfit'),
          unselectedLabelStyle: body1(FontWeight.w500, bnw500, 'Outfit'),
          tabs: const [
            Tab(text: 'Kasir'),
            // Tab(text: 'Riwayat'),
            // Tab(text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Halaman KASIR (Screenshot baru: image_65c9b9.png)
          _KasirTabPage(token: widget.token),

          // // 2. Halaman RIWAYAT (Screenshot lama: image_65be7b.png)
          // _RiwayatTabPage(token: widget.token),

          // 3. Halaman PENGATURAN (Placeholder)
          // _PengaturanTabPage(),
        ],
      ),
    );
  }
}

// =========================================================================
// == TAB 1: KASIR (Sesuai image_65c9b9.png) ==
// =========================================================================

class _KasirTabPage extends StatefulWidget {
  final String token;
  const _KasirTabPage({Key? key, required this.token}) : super(key: key);

  @override
  State<_KasirTabPage> createState() => _KasirTabPageState();
}

class _KasirTabPageState extends State<_KasirTabPage> {
  List<ModelDataProduk> listProduk = [];
  bool isLoading = true;
  String search = '';
  String orderby = 'asc';

  // --- DUMMY DATA UNTUK KERANJANG ---
  final List<Map<String, dynamic>> _cartItems = [
    {'nama': 'Matcha Latte', 'harga': 12000, 'qty': 1},
    {'nama': 'Kopi Susu Gula Aren', 'harga': 12000, 'qty': 1},
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final data = await getProduct(context, widget.token, search, [''], orderby);
    setState(() {
      listProduk = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = size20; // 16

    const double minSheetSize = 0.15; // Ukuran saat terkulai (15%)
    const double maxSheetSize = 0.9; // Ukuran saat full (90%)

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                size16,
                horizontalPadding,
                size16,
              ),
              child: Column(
                children: [
                  // --- SEARCH BAR ---
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Cari Produk',
                      hintStyle: body1(FontWeight.w500, bnw500, 'Outfit'),
                      prefixIcon: Icon(Icons.search, color: bnw500),
                      filled: true,
                      fillColor: bnw200,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: size12,
                        horizontal: size16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => search = value,
                    // onSubmitted: (_) => loadData(), // Dihapus di kode Anda
                  ),
                  SizedBox(height: size16),

                  // --- FILTER ROW ---
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            orderby = orderby == 'asc' ? 'desc' : 'asc';
                          });
                          loadData();
                        },
                        icon: Icon(
                          PhosphorIcons.sort_ascending,
                          color: bnw900,
                          size: 20,
                        ),
                        label: Text(
                          'Urutkan',
                          style: body2(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: bnw300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(size8),
                          ),
                        ),
                      ),
                      SizedBox(width: size12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Tampilkan modal filter tipe
                        },
                        icon: Icon(
                          PhosphorIcons.funnel,
                          color: bnw900,
                          size: 20,
                        ),
                        label: Text(
                          'Semua Tipe',
                          style: body2(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: bnw300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(size8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 0.5, color: bnw300),

            // --- GRIDVIEW PRODUK (2 KOLOM) ---
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: primary500))
                  : GridView.builder(
                      padding: EdgeInsets.all(horizontalPadding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // ===============================================
                        // == PERBAIKAN: crossAxisCount: 1 -> 2 ==
                        // ===============================================
                        crossAxisCount: 1, // 2 kolom
                        crossAxisSpacing: size16, // Jarak horizontal
                        mainAxisSpacing: size16, // Jarak vertikal
                        childAspectRatio:
                            3.5, // Rasio kartu (buat lebih tinggi)
                      ),
                      itemCount: listProduk.length,
                      itemBuilder: (context, index) {
                        final product = listProduk[index];
                        return _ProductCardKasir(
                          namaProduk: product.name ?? '',
                          harga: int.tryParse(product.price.toString()) ?? 0,
                          imageUrl: product.productImage ?? '',
                          kategori: product.typeproducts ?? 'Lainnya',
                          onTap: () {
                            // TODO: Tambahkan produk ke keranjang
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        DraggableScrollableSheet(
          initialChildSize: minSheetSize,
          minChildSize: minSheetSize,
          maxChildSize: maxSheetSize,
          snap: true,
          snapSizes: [minSheetSize, 0.5, maxSheetSize], // biar snap rapi
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  // rebuild saat tinggi berubah biar bisa toggle UI
                  setState(() {});
                  return false;
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isExpanded = constraints.maxHeight > 200;

                    return CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // --- Grip Handle ---
                        SliverToBoxAdapter(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragUpdate: (_) {}, // biar bisa digeser
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: bnw300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // --- Konten Keranjang ---
                        if (isExpanded)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: _buildExpandedCartContent(context),
                            ),
                          ),

                        // --- Footer (Selalu terlihat di bawah) ---
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _buildCartFooter(
                              itemCount: _cartItems.length,
                              totalPrice: 100,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartItem({
    required String image,
    required String name,
    required int price,
    required String note,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Rp. ${price.toString()}",
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Catatan : $note",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // tombol hapus dan qty
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              Container(
                width: 20,
                alignment: Alignment.center,
                child: const Text("1"),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_rounded, color: Colors.blue),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget untuk Konten Keranjang (Saat Terbuka) ---
  // --- Widget untuk Konten Keranjang (Saat Terbuka) ---
  Widget _buildExpandedCartContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keranjang', style: heading2(FontWeight.w600, bnw900, 'Outfit')),
        SizedBox(height: size16),

        // --- List Item Keranjang ---
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cartItems.length,
          itemBuilder: (context, index) {
            final item = _cartItems[index];
            return Padding(
              padding: EdgeInsets.only(bottom: size20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Row Produk ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar produk (dummy dulu)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(size8),
                        child: Image.network(
                          'https://img.freepik.com/free-photo/coffee-latte-art_74190-5871.jpg?w=200',
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: size12),

                      // Nama & harga
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'],
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              'Rp. ${item['harga']}',
                              style: body2(FontWeight.w500, bnw700, 'Outfit'),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Catatan : tambah es batu 5',
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                          ],
                        ),
                      ),

                      // Tombol hapus dan +/-
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              PhosphorIcons.trash,
                              color: danger500,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _cartItems.removeAt(index);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (item['qty'] > 1) {
                                      item['qty']--;
                                    } else {
                                      _cartItems.removeAt(index);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bnw200,
                                    borderRadius: BorderRadius.circular(size4),
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    PhosphorIcons.minus,
                                    size: 14,
                                    color: bnw700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${item['qty']}',
                                style: body1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    item['qty']++;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primary500,
                                    borderRadius: BorderRadius.circular(size4),
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    PhosphorIcons.plus,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size12),
                  Divider(color: bnw300, height: 1),
                ],
              ),
            );
          },
        ),

        SizedBox(height: size12),

        // --- TOTAL ITEM & SUBTOTAL ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Item: ${_cartItems.fold<int>(0, (sum, e) => sum + e['qty'] as int)}',
              style: body1(FontWeight.w600, bnw900, 'Outfit'),
            ),
            Text(
              'Sub Total: Rp. ${_cartItems.fold<int>(0, (sum, e) => sum + (e['harga'] * e['qty']) as int)}',
              style: body1(FontWeight.w700, bnw900, 'Outfit'),
            ),
          ],
        ),
        SizedBox(height: size16),

        // --- Nama Pelanggan ---
        Container(
          padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
          decoration: BoxDecoration(
            border: Border.all(color: primary500, width: 1),
            borderRadius: BorderRadius.circular(size8),
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.users, color: primary500, size: 20),
              SizedBox(width: size12),
              Expanded(
                child: Text(
                  'Bayu Setiawan',
                  style: body1(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
              Icon(PhosphorIcons.x_circle, color: primary500, size: 18),
            ],
          ),
        ),
        SizedBox(height: size16),

        // --- Tombol Simpan Tagihan & Bayar ---
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: aksi simpan tagihan
                },
                icon: Icon(PhosphorIcons.notepad, color: primary500, size: 20),
                label: Text(
                  'Simpan Tagihan',
                  style: body1(FontWeight.w600, primary500, 'Outfit'),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primary500, width: 1),
                  padding: EdgeInsets.symmetric(vertical: size12),
                ),
              ),
            ),
            SizedBox(width: size12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: aksi bayar
                },
                icon: Icon(PhosphorIcons.wallet, color: Colors.white, size: 20),
                label: Text(
                  'Bayar',
                  style: body1(FontWeight.w600, Colors.white, 'Outfit'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary500,
                  padding: EdgeInsets.symmetric(vertical: size12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size8),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size20),
      ],
    );
  }

  // --- Widget untuk Footer Keranjang (Terkulai / di Bawah) ---
  Widget _buildCartFooter({required int itemCount, required int totalPrice}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        size20,
        size12,
        size20,
        size24,
      ), // Padding bawah lebih besar
      decoration: BoxDecoration(
        color: bnw100,
        border: Border(top: BorderSide(color: bnw300, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.shopping_cart_simple, color: primary500, size: 28),
          SizedBox(width: size12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$itemCount Item',
                style: body2(FontWeight.w500, bnw500, 'Outfit'),
              ),
              Text(
                'Rp $totalPrice',
                style: heading3(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ],
          ),
          Spacer(),
          // Tombol Selanjutnya
          ElevatedButton(
            onPressed: () {
              // TODO: Pindah ke halaman pembayaran
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size24,
                vertical: size12,
              ),
            ),
            child: Text(
              'Selanjutnya',
              style: body1(FontWeight.w600, bnw100, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// == PERBAIKAN: Komponen _ProductCardKasir (Layout COLUMN/Grid) ==
// ====================================================================
class _ProductCardKasir extends StatelessWidget {
  final String namaProduk;
  final int harga;
  final String imageUrl;
  final String kategori;
  final VoidCallback onTap;

  const _ProductCardKasir({
    required this.namaProduk,
    required this.harga,
    required this.imageUrl,
    required this.kategori,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan Card untuk layout Grid
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size12), // size12 = 8
        side: BorderSide(color: bnw300, width: 0.5),
      ),
      color: bnw100,
      clipBehavior: Clip.antiAlias, // Penting untuk gambar
      child: InkWell(
        onTap: onTap,
        // MENGGUNAKAN COLUMN (Gambar di Atas, Teks di Bawah)
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  color: bnw200,
                  child: Icon(PhosphorIcons.package, color: bnw500, size: 48),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GAMBAR (Persegi, di atas)

                // NAMA & HARGA (Padding di dalam)
                Padding(
                  padding: EdgeInsets.all(size12), // size12 = 8
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaProduk,
                        style: heading2(
                          FontWeight.w600,
                          bnw900,
                          'Outfit',
                        ), // Style Anda
                        maxLines: 2, // Max 2 baris
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp $harga', // TODO: Format harga jika perlu
                        style: heading3(
                          FontWeight.w400,
                          bnw900,
                          'Outfit',
                        ), // Style Anda
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kategori, // Menggunakan data kategori
                        style: heading3(
                          FontWeight.w400,
                          bnw500,
                          'Outfit',
                        ), // Style Anda
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// == TAB 2: RIWAYAT (Sesuai image_65be7b.png) ==
// =========================================================================
// class _RiwayatTabPage extends StatefulWidget {
//   final String token;
//   const _RiwayatTabPage({Key? key, required this.token}) : super(key: key);

//   @override
//   State<_RiwayatTabPage> createState() => _RiwayatTabPageState();
// }

// class _RiwayatTabPageState extends State<_RiwayatTabPage> {
//   List<RiwayatTransaksiTokoModel> listRiwayat = [];
//   bool isLoading = true;
//   String search = '';

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   Future<void> loadData() async {
//     setState(() => isLoading = true);
//     final data = await getRiwayatTransaksi(context, widget.token);
//     setState(() {
//       listRiwayat = data;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double horizontalPadding = size20; // 16

//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             size16,
//             horizontalPadding,
//             size16,
//           ),
//           child: TextFormField(
//             decoration: InputDecoration(
//               hintText: 'Cari Transaksi',
//               hintStyle: body1(FontWeight.w500, bnw500, 'Outfit'),
//               prefixIcon: Icon(Icons.search, color: bnw500),
//               filled: true,
//               fillColor: bnw200,
//               contentPadding: EdgeInsets.symmetric(
//                 vertical: size12,
//                 horizontal: size16,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(size8),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//             onChanged: (value) => search = value,
//             // onSubmitted: (_) => loadData(),
//           ),
//         ),
//         Divider(height: 1, thickness: 0.5, color: bnw300),
//         Expanded(
//           child: isLoading
//               ? Center(child: CircularProgressIndicator(color: primary500))
//               : ListView.separated(
//                   itemCount: listRiwayat.length,
//                   padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                   itemBuilder: (context, index) {
//                     final item = listRiwayat[index];
//                     return _TransactionListItem(
//                       idTransaksi: item.idTransaksi ?? 'TRX-000',
//                       tanggal: item.tanggal ?? '01/01/2023',
//                       jam: item.jam ?? '00:00',
//                       status: item.status ?? 'Selesai',
//                       total: item.total ?? 0,
//                       onTap: () {
//                         // TODO: Arahkan ke detail riwayat
//                       },
//                     );
//                   },
//                   separatorBuilder: (context, index) =>
//                       Divider(height: 1, thickness: 0.5, color: bnw300),
//                 ),
//         ),
//       ],
//     );
//   }
// }

// --- Komponen Item Riwayat (Sesuai image_65be7b.png) ---
class _TransactionListItem extends StatelessWidget {
  final String idTransaksi;
  final String tanggal;
  final String jam;
  final String status;
  final int total;
  final VoidCallback onTap;

  const _TransactionListItem({
    required this.idTransaksi,
    required this.tanggal,
    required this.jam,
    required this.status,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'selesai':
        statusColor = succes500;
        statusBgColor = succes100;
        statusIcon = PhosphorIcons.check_circle_fill;
        break;
      case 'dibatalkan':
        statusColor = danger500;
        statusBgColor = danger100;
        statusIcon = PhosphorIcons.x_circle_fill;
        break;
      default:
        statusColor = waring500;
        statusBgColor = waring100;
        statusIcon = PhosphorIcons.clock_fill;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    idTransaksi,
                    style: body1(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp $total',
                    style: body1(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: body3(FontWeight.w600, statusColor, 'Outfit'),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(tanggal, style: body3(FontWeight.w500, bnw500, 'Outfit')),
                SizedBox(height: 4),
                Text(jam, style: body3(FontWeight.w500, bnw500, 'Outfit')),
              ],
            ),
            const SizedBox(width: 8),
            Icon(PhosphorIcons.caret_right, color: bnw500, size: 20),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// == TAB 3: PENGATURAN (Placeholder) ==
// =========================================================================
class _PengaturanTabPage extends StatelessWidget {
  const _PengaturanTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman Pengaturan',
        style: heading3(FontWeight.w500, bnw500, 'Outfit'),
      ),
    );
  }
}
