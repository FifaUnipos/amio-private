import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/models/coaModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class FormCoaMobile extends StatefulWidget {
  final String token;
  final CoaModel? coaItem; // If not null, it's Update mode

  const FormCoaMobile({Key? key, required this.token, this.coaItem})
    : super(key: key);

  @override
  State<FormCoaMobile> createState() => _FormCoaMobileState();
}

class _FormCoaMobileState extends State<FormCoaMobile> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  PaymentReferenceModel? _selectedReference;
  bool _isLoading = false;

  // For selecting references
  List<PaymentReferenceModel> _references = [];
  bool _isLoadingReferences = false;

  @override
  void initState() {
    super.initState();
    if (widget.coaItem != null) {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      // User requested get single for update
      final detail = await getSingleCoa(
        context,
        widget.token,
        widget.coaItem!.idpaymentmethode,
      );
      if (detail != null) {
        _accountNumberController.text = detail.accountNumber ?? "";
        // Map reference id.
        // We know paymentMethodReferenceId e.g. "9999".
        // We can create a temporary model or try to fetch references to find match.
        // For UI display, we assume we just need the ID and maybe name if provided in detail.
        // detail has paymentMethod (name) and payment_method_reference_id.

        setState(() {
          _selectedReference = PaymentReferenceModel(
            paymentReferenceId: detail.paymentMethodReferenceId,
            paymentReferenceName:
                detail.paymentMethod, // Or category? "payment_method": "Other"
            // Image? detail doesn't have image.
          );
        });
      }
    } catch (e) {
      print("Error loading detail: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showReferenceSheet() async {
    // Show modal bottom sheet with search and filter
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _ReferenceSheetContent(
          token: widget.token,
          onSelect: (item) {
            setState(() {
              _selectedReference = item;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _save(bool addNew) async {
    if (_selectedReference == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pilih Akun terlebih dahulu")));
      return;
    }
    if (_accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Isi Nomor Akun")));
      return;
    }

    try {
      String? rc;
      if (widget.coaItem == null) {
        // Create
        rc = await createCoa(
          context,
          widget.token,
          _selectedReference!.paymentReferenceId,
          _accountNumberController.text,
        );
      } else {
        // Update
        // "api/type/payment/update" body: idPaymentMethod, paymentMethod, accountNumber
        // paymentMethod here likely refers to reference ID?
        // User request example: "paymentMethod": "0012" (which is GoPay ID).
        rc = await updateCoa(
          context,
          widget.token,
          widget.coaItem!.idpaymentmethode,
          _selectedReference!.paymentReferenceId,
          _accountNumberController.text,
        );
      }

      if (rc == '00') {
        if (addNew && widget.coaItem == null) {
          // Reset form
          _accountNumberController.clear();
          setState(() {
            _selectedReference = null;
          });
          // Show message done by api helper
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdate = widget.coaItem != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isUpdate ? "Ubah COA" : "Tambah COA",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Akun
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Akun",
                                style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              TextSpan(
                                text: " *",
                                style: body1(
                                  FontWeight.w400,
                                  Colors.red,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showReferenceSheet,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: bnw300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedReference?.paymentReferenceName ??
                                        "Pilih Akun",
                                    style: body1(
                                      FontWeight.w600,
                                      _selectedReference != null
                                          ? bnw900
                                          : bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                Icon(
                                  PhosphorIcons.caret_up,
                                  size: 16,
                                  color: bnw500,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Nomor Akun
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Nomor Akun",
                                style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              TextSpan(
                                text: " *",
                                style: body1(
                                  FontWeight.w400,
                                  Colors.red,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _accountNumberController,
                          decoration: InputDecoration(
                            hintText: "Masukan Nomor Akun",
                            hintStyle: body1(FontWeight.w400, bnw300, 'Outfit'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: bnw300),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!isUpdate) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _save(true),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Save & Add New",
                              style: body1(
                                FontWeight.w600,
                                primaryColor,
                                'Outfit',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _save(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isUpdate ? "Simpan" : "Create",
                            style: body1(
                              FontWeight.w600,
                              Colors.white,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReferenceSheetContent extends StatefulWidget {
  final String token;
  final Function(PaymentReferenceModel) onSelect;

  const _ReferenceSheetContent({
    Key? key,
    required this.token,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<_ReferenceSheetContent> createState() => _ReferenceSheetContentState();
}

class _ReferenceSheetContentState extends State<_ReferenceSheetContent> {
  final List<String> _categories = ["", "Credit", "Debit", "EWallet", "Other"];
  String _selectedCategory = "";
  String _searchQuery = "";
  List<PaymentReferenceModel> _allReferences = [];
  List<PaymentReferenceModel> _filteredReferences = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  Future<void> _fetchReferences() async {
    setState(() => _isLoading = true);
    try {
      _allReferences = await getCoaReferences(
        context,
        widget.token,
        _selectedCategory,
      );
      _applySearch();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredReferences = List.from(_allReferences);
    } else {
      _filteredReferences = _allReferences.where((item) {
        final name = item.paymentReferenceName?.toLowerCase() ?? "";
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchReferences();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Pilih Akun",
                style: heading3(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _applySearch();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari bank...",
                  prefixIcon: Icon(
                    PhosphorIcons.magnifying_glass,
                    color: bnw500,
                  ),
                  filled: true,
                  fillColor: bnw100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),
            ),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final label = cat.isEmpty ? "Semua" : cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
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
                        side: BorderSide(
                          color: isSelected ? primaryColor : bnw300,
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (val) => _onCategoryChanged(cat),
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredReferences.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada data",
                        style: body1(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: _filteredReferences.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: bnw200),
                      itemBuilder: (context, index) {
                        final item = _filteredReferences[index];
                        return ListTile(
                          leading: item.paymntReferenceImage != null
                              ? Image.network(
                                  item.paymntReferenceImage!,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (_, __, ___) => Icon(
                                    PhosphorIcons.bank,
                                    size: 32,
                                    color: bnw500,
                                  ),
                                )
                              : Icon(
                                  PhosphorIcons.bank,
                                  size: 32,
                                  color: bnw500,
                                ),
                          title: Text(
                            item.paymentReferenceName ?? "-",
                            style: body1(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          onTap: () => widget.onSelect(item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
