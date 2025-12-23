import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/tokomodel.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/pageMobile/pageTokoMobile/pageUbahTokoMobile.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class TokoPageMobile extends StatefulWidget {
  final String token;
  TokoPageMobile({super.key, required this.token});

  @override
  State<TokoPageMobile> createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPageMobile> {
  List<ModelDataToko> listToko = [];
  bool isLoading = true;
  String search = '';
  // Default sort updated to user preference
  String orderby = 'downUpToko'; // Default sorting

  // Selection Mode State
  bool isSelectionMode = false;
  List<String> selectedMerchantIds = [];

  bool get isGroupAdmin =>
      merchantType == 'Group_Merchant' && roleProfile == 'admin';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    // Passing search to both name and address as per requirement "Cari nama atau alamat"
    final data = await getAllToko(context, checkToken, search, orderby);
    if (!mounted) return;
    setState(() {
      listToko = data ?? [];
      isLoading = false;
      selectedMerchantIds.clear(); // Clear selection on reload
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      selectedMerchantIds.clear();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedMerchantIds.length == listToko.length) {
        selectedMerchantIds.clear();
      } else {
        selectedMerchantIds = listToko
            .map((e) => e.merchantid ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
      }
    });
  }

  void _showDeleteConfirmation({String? id}) {
    final idsToDelete = id != null ? [id] : selectedMerchantIds;
    if (idsToDelete.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: bnw300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Icon(PhosphorIcons.trash, color: danger500, size: 48),
              SizedBox(height: 16),
              Text(
                "Hapus Toko",
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 8),
              Text(
                id != null
                    ? "Apakah Anda yakin ingin menghapus toko ini?"
                    : "Apakah Anda yakin ingin menghapus ${idsToDelete.length} toko terpilih?",
                textAlign: TextAlign.center,
                style: body1(FontWeight.w400, bnw600, 'Outfit'),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: bnw300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(modalContext),
                      child: Text(
                        "Batal",
                        style: body2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: danger500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        // Close bottomSheet first
                        Navigator.pop(modalContext);

                        // Use the page's context (this.context) but verify it's still mounted
                        if (!mounted) return;

                        await deleteMerchant(context, checkToken, idsToDelete);

                        if (mounted) {
                          loadData(); // Success reload
                        }
                      },
                      child: Text(
                        "Hapus",
                        style: body2(FontWeight.w600, Colors.white, 'Outfit'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Remove old confirm methods
  // _confirmBulkDelete and _confirmDeleteSingle should be replaced by calls to _showDeleteConfirmation

  // Helper for human-readable sort labels
  String _getSortLabel() {
    switch (orderby) {
      case 'upDownNama':
        return 'Nama A-Z';
      case 'downUpNama':
        return 'Nama Z-A';
      case 'upDownToko':
        return 'Toko A-Z';
      case 'downUpToko':
        return 'Toko Z-A';
      default:
        return 'Urutkan toko';
    }
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Urutkan Berdasarkan",
                style: heading3(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 16),
              _buildSortOption("Nama (A-Z)", "upDownNama"),
              _buildSortOption("Nama (Z-A)", "downUpNama"),
              _buildSortOption("Toko (A-Z)", "upDownToko"),
              _buildSortOption("Toko (Z-A)", "downUpToko"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: orderby == value ? Icon(Icons.check, color: primary500) : null,
      onTap: () {
        setState(() => orderby = value);
        Navigator.pop(context);
        loadData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Toko", style: heading1(FontWeight.w700, bnw900, 'Outfit')),
        centerTitle: false,
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPageMobile(token: checkToken),
            ),
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: size16,
          vertical: size8,
        ),
        actions: [
          // "Tambah" button only for Group Admins - Blue Button Style
          if (isGroupAdmin && !isSelectionMode)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary500, // Blue background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UbahTokoPageMobile(token: checkToken),
                    ),
                  );
                  loadData(); // REFRESH ALWAYS ON BACK
                },
                child: Text(
                  "Tambah",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: bnw100,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(size16),
              child: Column(
                children: [
                  // 🔍 Search field
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Cari nama atau alamat",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: bnw300, width: 1),
                      ),
                    ),
                    onChanged: (value) => search = value,
                    onSubmitted: (_) => loadData(),
                  ),
                  SizedBox(height: size12),

                  // 🔹 Control Row (Pilih Toko -- Urutkan)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: "Pilih Toko" Button (For Admins)
                      if (isGroupAdmin)
                        GestureDetector(
                          onTap: _toggleSelectionMode,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelectionMode ? primary100 : bnw100,
                              border: Border.all(
                                color: isSelectionMode ? primary500 : bnw300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isSelectionMode ? "Batal Pilih" : "Pilih Toko",
                              style: TextStyle(
                                color: isSelectionMode ? primary500 : bnw900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      Spacer(),

                      // Right: Sort Button OR Select All actions
                      if (isSelectionMode && isGroupAdmin)
                        // Selection Actions
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleSelectAll,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: bnw100,
                                  border: Border.all(color: bnw300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Pilih Semua",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: bnw900,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showDeleteConfirmation,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: danger500,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  PhosphorIcons.trash,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // Sort Button - Styled like "Urutkan toko" with icon
                        GestureDetector(
                          onTap: _showSortModal,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: bnw100,
                              border: Border.all(color: bnw300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _getSortLabel(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: bnw900,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.unfold_more,
                                  size: 18,
                                  color: bnw500,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // 📋 Daftar Toko List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadData,
                      child: ListView.builder(
                        itemCount: listToko.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final toko = listToko[index];
                          final id = toko.merchantid ?? '';
                          final isSelected = selectedMerchantIds.contains(id);

                          return GestureDetector(
                            onTap: isSelectionMode
                                ? () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedMerchantIds.remove(id);
                                      } else {
                                        selectedMerchantIds.add(id);
                                      }
                                    });
                                  }
                                : null,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: bnw100,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: bnw300.withOpacity(0.5),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSelectionMode && isSelected
                                      ? primary500
                                      : bnw300.withOpacity(0.5),
                                  width: isSelectionMode && isSelected ? 2 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Row 1: Logo + Info + Checkbox(if selection)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            toko.logomerchant_url ?? '',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, _, __) =>
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.storefront,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                toko.name ?? '',
                                                style: heading2(
                                                  FontWeight.w700,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                toko.address ?? '',
                                                style: body2(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelectionMode)
                                          Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_box
                                                  : Icons
                                                        .check_box_outline_blank,
                                              color: isSelected
                                                  ? primary500
                                                  : bnw300,
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Row 2: Actions (Edit | Delete) - Only if NOT selection mode
                                    // (Actually image shows Red Delete button on the right)
                                    // Let's implement the Edit bar and Delete button side-by-side
                                    if (!isSelectionMode) ...[
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: bnw300,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                onPressed: () async {
                                                  // Hit loadData() regardless of return value to ensure fresh data
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          UbahTokoPageMobile(
                                                            token: checkToken,
                                                            merchantId:
                                                                toko.merchantid,
                                                          ),
                                                    ),
                                                  );
                                                  loadData(); // REFRESH ALWAYS ON BACK
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      PhosphorIcons
                                                          .pencil_simple,
                                                      size: 18,
                                                      color: bnw900,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: bnw900,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Delete Button for Group Admin
                                          if (isGroupAdmin) ...[
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () =>
                                                  _showDeleteConfirmation(
                                                    id: id,
                                                  ),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: danger500,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  PhosphorIcons.trash,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
