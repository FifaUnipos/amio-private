import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/utilities.dart';

class MerchantSelectionPage extends StatefulWidget {
  final String token;
  final String featureTitle;
  final Widget Function(String merchantId) featureBuilder;

  const MerchantSelectionPage({
    Key? key,
    required this.token,
    required this.featureTitle,
    required this.featureBuilder,
  }) : super(key: key);

  @override
  State<MerchantSelectionPage> createState() => _MerchantSelectionPageState();
}

class _MerchantSelectionPageState extends State<MerchantSelectionPage> {
  bool _isLoading = true;
  List<dynamic> _merchants = [];
  List<dynamic> _filteredMerchants = [];
  String _selectedOrder = "upDownNama";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Reusing getAllToko from apimethod.dart
      final data = await getAllToko(context, widget.token, "", _selectedOrder);
      if (data != null) {
        setState(() {
          _merchants = data;
          _filteredMerchants = data;
        });
      }
    } catch (e) {
      debugPrint("Error loading merchants: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterMerchants(String query) {
    setState(() {
      _searchQuery = query;
      _filteredMerchants = _merchants.where((m) {
        final name = m.name?.toLowerCase() ?? "";
        final address = m.address?.toLowerCase() ?? "";
        return name.contains(query.toLowerCase()) ||
            address.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPageMobile(token: checkToken),
            ),
          ),
        ),
        title: Text(
          widget.featureTitle,
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar (Gambar 1 style)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMerchants,
              decoration: InputDecoration(
                hintText: "Cari nama atau alamat",
                hintStyle: body1(FontWeight.w400, bnw500, 'Outfit'),
                prefixIcon: Icon(
                  PhosphorIcons.magnifying_glass,
                  color: bnw500,
                  size: 20,
                ),
                filled: true,
                fillColor: bnw200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: size16,
                ),
              ),
            ),
          ),

          // Sort Dropdown (Gambar 1 style)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size16, vertical: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                border: Border.all(color: bnw300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedOrder,
                  icon: Icon(PhosphorIcons.caret_up, size: 16, color: bnw500),
                  items: [
                    DropdownMenuItem(
                      value: "upDownNama",
                      child: Text(
                        "Urutkan toko",
                        style: body2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "downUpNama",
                      child: Text(
                        "Nama (Z-A)",
                        style: body2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedOrder = value);
                      _loadMerchants();
                    }
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: 8),

          // Merchant List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredMerchants.isEmpty
                ? Center(
                    child: Text(
                      "Toko tidak ditemukan",
                      style: body1(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(size16),
                    itemCount: _filteredMerchants.length,
                    itemBuilder: (context, index) {
                      final merchant = _filteredMerchants[index];
                      // print('Merchant loaded: ${merchant.logomerchant_url}');

                      return Padding(
                        padding: EdgeInsets.only(bottom: size16),
                        child: _buildMerchantCard(merchant),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(dynamic merchant) {
    return Container(
      padding: EdgeInsets.all(size16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bnw200),
        boxShadow: [
          BoxShadow(
            color: bnw900.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // color: bnw900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child:
                      merchant.logomerchant_url != null &&
                          merchant.logomerchant_url.isNotEmpty
                      ? Image.network(
                          merchant.logomerchant_url,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              PhosphorIcons.storefront_fill,
                              color: bnw900,
                              size: 32,
                            );
                          },
                        )
                      : Icon(
                          PhosphorIcons.shopping_bag,
                          color: bnw900,
                          size: 32,
                        ),
                ),
              ),
              SizedBox(width: 12),

              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.name ?? "Tanpa Nama",
                      style: heading3(FontWeight.w700, bnw900, 'Outfit'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      merchant.address ?? "Tanpa Alamat",
                      style: body2(
                        FontWeight.w400,
                        bnw700,
                        'Outfit',
                      ), // Slightly darker/bolder address as per image
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action Button (Gambar 1 style: blue outline)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        widget.featureBuilder(merchant.merchantid),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "Lihat ${widget.featureTitle}",
                style: body1(FontWeight.w600, primaryColor, 'Outfit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
