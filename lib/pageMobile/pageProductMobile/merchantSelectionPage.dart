import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
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
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    setState(() => _isLoading = true);
    try {
      // Reusing getAllToko from apimethod.dart
      final data = await getAllToko(context, widget.token, "", "upDownNama");
      if (data != null) {
        setState(() {
          _merchants = data;
          _filteredMerchants = data;
        });
      }
    } catch (e) {
      debugPrint("Error loading merchants: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterMerchants(String query) {
    setState(() {
      _searchQuery = query;
      _filteredMerchants = _merchants.where((m) {
        final name = m.name?.toLowerCase() ?? "";
        final address = m.address?.toLowerCase() ?? "";
        return name.contains(query.toLowerCase()) || address.contains(query.toLowerCase());
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pilih Toko",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar (Gambar 1 style)
          Padding(
            padding: EdgeInsets.all(size16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMerchants,
              decoration: InputDecoration(
                hintText: "Cari nama atau alamat",
                prefixIcon: Icon(PhosphorIcons.magnifying_glass, color: bnw500),
                filled: true,
                fillColor: bnw200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
              ),
            ),
          ),
          
          // Merchant List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredMerchants.isEmpty
                    ? Center(child: Text("Toko tidak ditemukan", style: body1(FontWeight.w400, bnw500, 'Outfit')))
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: size16),
                        itemCount: _filteredMerchants.length,
                        separatorBuilder: (context, index) => Divider(height: 24, thickness: 1, color: bnw200),
                        itemBuilder: (context, index) {
                          final merchant = _filteredMerchants[index];
                          return _buildMerchantCard(merchant);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(dynamic merchant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Image/Logo Placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bnw200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(PhosphorIcons.storefront, color: bnw500),
        ),
        SizedBox(width: size16),
        
        // Store Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                merchant.name ?? "Tanpa Nama",
                style: heading3(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 4),
              Text(
                merchant.address ?? "Tanpa Alamat",
                style: body2(FontWeight.w400, bnw500, 'Outfit'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              
              // Action Button (Gambar 1 style: "Lihat [Fitur]")
              InkWell(
                onTap: () {
                  // print("Navigating to ${widget.featureTitle} for merchant ID: ${merchant.merchantid}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.featureBuilder(merchant.merchantid),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: bnw900),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIcons.eye, size: 16, color: bnw900),
                      SizedBox(width: 8),
                      Text(
                        "Lihat ${widget.featureTitle}",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
