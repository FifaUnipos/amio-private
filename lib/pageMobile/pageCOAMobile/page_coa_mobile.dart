import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/models/coaModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'form_coa_mobile.dart';

class PageCoaMobile extends StatefulWidget {
  final String token;
  const PageCoaMobile({Key? key, required this.token}) : super(key: key);

  @override
  State<PageCoaMobile> createState() => _PageCoaMobileState();
}

class _PageCoaMobileState extends State<PageCoaMobile> {
  bool _isLoading = true;
  List<CoaModel> _coaList = [];
  String _selectedOrder = "upDownNama"; // Default sort
  String _selectedCategory = ""; // Default filter (empty = all)

  // Categories for filter - Hardcoded based on request "Credit, Debit, EWallet, Other"
  final List<String> _categories = ["", "Credit", "Debit", "EWallet", "Other"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // API call
      // "buatkan filter berdasarkan category juga ya, kalau kosong semuanya tampil"
      final data = await getCoaList(
        context,
        widget.token,
        _selectedCategory,
        _selectedOrder,
      );
      setState(() {
        _coaList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading COA: $e");
    }
  }

  void _onFilterChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedOrder = newValue;
      });
      _loadData();
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormCoaMobile(token: widget.token),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToUpdate(CoaModel item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormCoaMobile(token: widget.token, coaItem: item),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _deleteItem(CoaModel item) {
    // Show dialog bottom as requested: "pilihan ubah dan delete showdialogbottom"
    // Wait, the request says "ketika klik logo pensil, terdapat pilihan ubah dan delete showdialogbottom"
    // So pencil icon triggers a bottom sheet with Update and Delete options.

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(PhosphorIcons.pencil_simple, color: bnw900),
              title: Text(
                "Ubah",
                style: body1(FontWeight.w600, bnw900, 'Outfit'),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToUpdate(item);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(PhosphorIcons.trash, color: Colors.red),
              title: Text(
                "Hapus",
                style: body1(FontWeight.w600, Colors.red, 'Outfit'),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CoaModel item) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hapus COA",
              style: heading3(FontWeight.w700, bnw900, 'Outfit'),
            ),
            SizedBox(height: 8),
            Text(
              "Apakah anda yakin ingin menghapus akun ini?",
              style: body1(FontWeight.w400, bnw900, 'Outfit'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: bnw300),
                    ),
                    child: Text(
                      "Batal",
                      style: body1(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (item.idpaymentmethode != null) {
                        await deleteCoa(
                          context,
                          widget.token,
                          item.idpaymentmethode,
                        );
                        _loadData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Hapus",
                      style: body1(FontWeight.w600, Colors.white, 'Outfit'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("COA", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: _navigateToCreate,
                  icon: Icon(PhosphorIcons.plus, size: 16, color: Colors.white),
                  label: Text(
                    "COA",
                    style: body2(FontWeight.w600, Colors.white, 'Outfit'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Dropdown: "Urutkan coa"
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 12),
          //     decoration: BoxDecoration(
          //       border: Border.all(color: bnw300),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: DropdownButtonHideUnderline(
          //       child: DropdownButton<String>(
          //         value: _selectedOrder,
          //         isExpanded: false, // Don't take full width like in image 1
          //         icon: Icon(PhosphorIcons.caret_up, size: 16, color: bnw500),
          //         items: [
          //           DropdownMenuItem(
          //             value: "upDownNama",
          //             child: Text(
          //               "Urutkan coa",
          //               style: body1(FontWeight.w600, bnw900, 'Outfit'),
          //             ),
          //           ),
          //           DropdownMenuItem(
          //             value: "downUpNama",
          //             child: Text(
          //               "Z-A",
          //               style: body1(FontWeight.w600, bnw900, 'Outfit'),
          //             ),
          //           ),
          //         ],
          //         onChanged: _onFilterChanged,
          //       ),
          //     ),
          //   ),
          // ),

          // Using a tab bar or chips for category filter?
          // User said "buatkan filter berdasarkan category juga ya, kalau kosong semuanya tampil"
          // Image doesn't show category filter explicitly, but user asked for it.
          // I'll add a horizontal SingleChildScrollView of chips below "Urutkan coa" or inline?
          // I'll put it below.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final label = cat.isEmpty ? "Semua" : cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      label,
                      style: body2(
                        FontWeight.w600,
                        isSelected ? Colors.white : bnw900,
                        'Outfit',
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: bnw300),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      _loadData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _coaList.isEmpty
                ? Center(
                    child: Text(
                      "Data kosong",
                      style: body1(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  )
                : ListView.separated(
                    itemCount: _coaList.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: bnw200),
                    itemBuilder: (context, index) {
                      final item = _coaList[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Akun",
                                    style: body2(
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    item.paymentMethod ?? "-",
                                    style: body1(
                                      FontWeight.w700,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nomor Akun",
                                    style: body2(
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    item.accountNumber ?? "-",
                                    style: body1(
                                      FontWeight.w700,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.pencil_simple,
                                size: 20,
                                color: bnw900,
                              ),
                              onPressed: () =>
                                  _deleteItem(item), // Opens bottomsheet
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
