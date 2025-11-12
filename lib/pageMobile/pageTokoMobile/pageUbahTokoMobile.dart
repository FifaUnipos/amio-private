import 'package:flutter/material.dart';
import 'package:unipos_app_335/models/modelDataRegion.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class UbahTokoPageMobile extends StatefulWidget {
  final String token;
  const UbahTokoPageMobile({super.key, required this.token});

  @override
  State<UbahTokoPageMobile> createState() => _UbahTokoPageState();
}

class _UbahTokoPageState extends State<UbahTokoPageMobile> {
  final namaTokoController = TextEditingController();
  final alamatController = TextEditingController();
  final kodePosController = TextEditingController();

  TipeUsahaModel? selectedTipeUsaha;
  WilayahModel? selectedProvinsi;
  WilayahModel? selectedKabupaten;
  WilayahModel? selectedKecamatan;
  WilayahModel? selectedKelurahan;

  List<TipeUsahaModel> tipeUsahaList = [];
  List<WilayahModel> provinsiList = [];
  List<WilayahModel> kabupatenList = [];
  List<WilayahModel> kecamatanList = [];
  List<WilayahModel> kelurahanList = [];

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    final tipeUsaha = await getTipeUsaha(widget.token);
    final provinsi = await getProvinsi(widget.token);
    setState(() {
      tipeUsahaList = tipeUsaha;
      provinsiList = provinsi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubah Toko',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInput('Nama Toko *', namaTokoController),
            const SizedBox(height: 16),
            buildModalSelector(
              label: 'Tipe Usaha *',
              value: selectedTipeUsaha?.nama,
              onTap: () => showListModal<TipeUsahaModel>(
                context,
                title: 'Tipe Usaha',
                items: tipeUsahaList,
                getName: (e) => e.nama,
                selected: selectedTipeUsaha,
                onSelected: (val) => setState(() => selectedTipeUsaha = val),
              ),
            ),
            const SizedBox(height: 16),
            buildInput('Alamat *', alamatController),
            const SizedBox(height: 16),

            // ==================== PROVINSI ====================
            buildModalSelector(
              label: 'Provinsi *',
              value: selectedProvinsi?.name,
              onTap: () async {
                final result = await showListModal<WilayahModel>(
                  context,
                  title: 'Provinsi',
                  items: provinsiList,
                  getName: (e) => e.name,
                  selected: selectedProvinsi,
                  onSelected: (val) async {
                    setState(() {
                      selectedProvinsi = val;
                      selectedKabupaten = null;
                      selectedKecamatan = null;
                      selectedKelurahan = null;
                      kabupatenList = [];
                      kecamatanList = [];
                      kelurahanList = [];
                    });
                    kabupatenList = await getKabupaten(
                      widget.token,
                      val!.id.toString(),
                    );
                    setState(() {});
                  },
                );
              },
            ),

            // ==================== KABUPATEN ====================
            buildModalSelector(
              label: 'Kabupaten *',
              value: selectedKabupaten?.name,
              onTap: selectedProvinsi == null
                  ? null
                  : () async {
                      final result = await showListModal<WilayahModel>(
                        context,
                        title: 'Kabupaten',
                        items: kabupatenList,
                        getName: (e) => e.name,
                        selected: selectedKabupaten,
                        onSelected: (val) async {
                          setState(() {
                            selectedKabupaten = val;
                            selectedKecamatan = null;
                            selectedKelurahan = null;
                            kecamatanList = [];
                            kelurahanList = [];
                          });
                          kecamatanList = await getKecamatan(
                            widget.token,
                            val!.id.toString(),
                          );
                          setState(() {});
                        },
                      );
                    },
            ),

            // ==================== KECAMATAN ====================
            buildModalSelector(
              label: 'Kecamatan *',
              value: selectedKecamatan?.name,
              onTap: selectedKabupaten == null
                  ? null
                  : () async {
                      final result = await showListModal<WilayahModel>(
                        context,
                        title: 'Kecamatan',
                        items: kecamatanList,
                        getName: (e) => e.name,
                        selected: selectedKecamatan,
                        onSelected: (val) async {
                          setState(() {
                            selectedKecamatan = val;
                            selectedKelurahan = null;
                            kelurahanList = [];
                          });
                          kelurahanList = await getKelurahan(
                            widget.token,
                            val!.id.toString(),
                          );
                          setState(() {});
                        },
                      );
                    },
            ),

            // ==================== KELURAHAN ====================
            buildModalSelector(
              label: 'Kelurahan *',
              value: selectedKelurahan?.name,
              onTap: selectedKecamatan == null
                  ? null
                  : () => showListModal<WilayahModel>(
                      context,
                      title: 'Kelurahan',
                      items: kelurahanList,
                      getName: (e) => e.name,
                      selected: selectedKelurahan,
                      onSelected: (val) =>
                          setState(() => selectedKelurahan = val),
                    ),
            ),

            SizedBox(height: size16),
            buildInput('Kode Pos *', kodePosController),
            SizedBox(height: size16),
            GestureDetector(
              onTap: () async {
                // ✅ Validasi form input
                if (namaTokoController.text.isEmpty ||
                    alamatController.text.isEmpty ||
                    kodePosController.text.isEmpty ||
                    selectedTipeUsaha == null ||
                    selectedProvinsi == null ||
                    selectedKabupaten == null ||
                    selectedKecamatan == null ||
                    selectedKelurahan == null) {
                  showSnackbar(context, {
                    "message": "Harap isi semua kolom wajib!",
                  });
                  return;
                }

                // ✅ Tampilkan loading
                whenLoading(context);

                // 🧩 Ambil semua data inputan
                final nameMerch = namaTokoController.text.trim();
                final address = alamatController.text.trim();
                final province = selectedProvinsi!.id;
                final regencies = selectedKabupaten!.id;
                final district = selectedKecamatan!.id;
                final village = selectedKelurahan!.id;
                final zipcode = kodePosController.text.trim();
                final type = selectedTipeUsaha!.id;
                final image = "";
                final merchid = merchantId;
                final PageController pageController = PageController();

                // ✅ Panggil API dari apimethod.dart
                final result = await updateMerch(
                  context,
                  widget.token,
                  merchid,
                  nameMerch,
                  address,
                  province,
                  regencies,
                  district,
                  village,
                  zipcode,
                  image,
                  pageController,
                  type,
                );

                // ✅ Setelah selesai, tutup loading
                closeLoading(context);

                // ✅ Jika sukses
                if (result == "00") {
                  showSnackbar(context, {
                    "message": "Berhasil memperbarui data toko",
                  });
                  Navigator.pop(context, true);
                } else {
                  showSnackbar(context, {
                    "message": "Gagal memperbarui data toko",
                  });
                }
              },
              child: SizedBox(
                width: double.infinity,
                child: buttonM(
                  Center(
                    child: Text(
                      'Simpan',
                      style: body1(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  primary500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // =============== Widget Helper Section ===============
  // =====================================================

  Widget buildInput(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    // Deteksi tanda bintang (*)
    final parts = label.split('*');
    final labelText = parts[0].trim();
    final hasStar = label.contains('*');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              labelText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (hasStar)
              Text(
                ' *',
                style: TextStyle(fontWeight: FontWeight.w600, color: danger500),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan ${labelText.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primary500, width: 2),
            ),
          ),
        ),
        // SizedBox(height: size12,)
      ],
    );
  }

  Widget buildModalSelector({
    required String label,
    String? value,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    // Deteksi tanda *
    final parts = label.split('*');
    final labelText = parts[0].trim();
    final hasStar = label.contains('*');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              labelText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (hasStar)
              Text(
                ' *',
                style: TextStyle(fontWeight: FontWeight.w600, color: danger500),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: isDisabled ? null : onTap,
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1,
            child: Container(
              margin: EdgeInsets.only(bottom: size12),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black54, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value ?? 'Pilih $labelText',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: value == null
                            ? Colors.grey[500]
                            : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<T?> showListModal<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) getName,
    required T? selected,
    required Function(T?) onSelected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        final FocusNode focusNode = FocusNode();
        List<T> filtered = List.from(items);

        return StatefulBuilder(
          builder: (context, setState) {
            return AnimatedPadding(
              // ⬅️ supaya naik otomatis saat keyboard muncul
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 🔹 Garis kecil di atas
                      Container(
                        height: 4,
                        width: 80,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // 🔹 Judul
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🔹 Search Bar
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) {
                          setState(() {
                            filtered = items
                                .where(
                                  (e) => getName(
                                    e,
                                  ).toLowerCase().contains(val.toLowerCase()),
                                )
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari $title...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🔹 List isi — bisa discroll
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final e = filtered[index];
                            final isSelected = selected == e;
                            return ListTile(
                              title: Text(getName(e)),
                              trailing: Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected ? Colors.blue : Colors.grey,
                              ),
                              onTap: () {
                                onSelected(e);
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context, e);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
