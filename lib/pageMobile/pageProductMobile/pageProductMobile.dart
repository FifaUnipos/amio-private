import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
// GANTI: Import model produk Anda
import 'package:unipos_app_335/models/produkmodel.dart';
// GANTI: Import halaman ubah produk Anda
// import 'package:unipos_app_335/pageMobile/pageProdukMobile/pageUbahProdukMobile.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class ProductMobilePage extends StatefulWidget {
  final String token;
  const ProductMobilePage({Key? key, required this.token}) : super(key: key);

  @override
  State<ProductMobilePage> createState() => _ProductMobilePageState();
}

class _ProductMobilePageState extends State<ProductMobilePage> {
  List<ModelDataProduk> listProduk = [];
  bool isLoading = true;
  String search = '';
  String orderby = 'asc';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // GANTI: Judul dari Toko -> Produk
        title: Text(
          "Produk",
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
        centerTitle: false,
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: size16,
          vertical: size8,
        ),
        // actions: [
        //   // Tombol Tambah dari layout "King Dragon Roll"
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: Container(
        //       decoration: const BoxDecoration(
        //         color: Color(0xFF2E6EFF), // TODO: Ganti dengan primary500
        //         shape: BoxShape.circle,
        //       ),
        //       child: IconButton(
        //         icon: const Icon(Icons.add, color: Colors.white),
        //         onPressed: () {
        //           // TODO: Arahkan ke halaman Tambah Produk
        //         },
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Produk',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200], // TODO: Ganti dengan bnw200
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => search = value,
                    onSubmitted: (_) => loadData(),
                  ),
                  const SizedBox(height: 10),

                  // 🔘 Urutkan & total produk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey[400]!,
                          ), // TODO: Ganti dengan bnw300
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            orderby = orderby == 'asc' ? 'desc' : 'asc';
                          });
                          loadData();
                        },
                        icon: const Icon(
                          Icons.sort,
                          color: Colors.black,
                        ), // TODO: Ganti dengan bnw900
                        label: const Text(
                          "Urutkan",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ), // TODO: Ganti dengan bnw900
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[400]!,
                          ), // TODO: Ganti dengan bnw300
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          "Total Produk : ${listProduk.length}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Pilih Produk", // GANTI: Teks
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Daftar produk
                  Expanded(
                    child: ListView.separated(
                      itemCount: listProduk.length,
                      separatorBuilder: (context, index) =>
                          const Divider(thickness: 1),
                      itemBuilder: (context, index) {
                        final item = listProduk[index];

                        // Konversi 1/0 ke true/false
                        final bool isPpn = item.isPPN == 1;
                        final bool isDisplayed = item.isActive == 1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.productImage ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, _, __) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Rp. ${(item.price ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        item.typeproducts ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // GANTI: Navigasi ke halaman Ubah
                                    print(item.productImage);
                                    // Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                    //   UbahProdukPageMobile(token: widget.token, produk: item)
                                    // ));
                                  },
                                  icon: const Icon(Icons.edit, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text(
                                        "PPN 11%",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      FlutterSwitch(
                                        value: isPpn,
                                        width: 44.0,
                                        height: 24.0,
                                        toggleSize: 20.0,
                                        padding: 2.0,
                                        activeColor: primary500,
                                        inactiveColor: Colors
                                            .grey[400]!, // TODO: Ganti dengan bnw300
                                        onToggle: (val) {
                                          setState(() {
                                            item.isPPN = val ? 1 : 0;
                                          });
                                          // TODO: Panggil API untuk update status PPN
                                          // updatePpnStatus(item.id, val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "Tampilkan dikasir",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      FlutterSwitch(
                                        value: isDisplayed,
                                        width: 44.0,
                                        height: 24.0,
                                        toggleSize: 20.0,
                                        padding: 2.0,
                                        activeColor: primary500,
                                        inactiveColor: Colors.grey[400]!,
                                        onToggle: (val) {
                                          setState(() {
                                            item.isActive = val ? 1 : 0;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
