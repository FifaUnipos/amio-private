import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/models/tokomodel.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:url_launcher/url_launcher.dart';

class PendapatanPerTokoPage extends StatefulWidget {
  final String token;
  final String merchantId;

   PendapatanPerTokoPage({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<PendapatanPerTokoPage> createState() => _PendapatanPerTokoPageState();
}

class _PendapatanPerTokoPageState extends State<PendapatanPerTokoPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;

  // Filters
  String _selectedSortLabel = "Transaksi Tertinggi";
  String _selectedSortValue = "transaksiTertinggi";
  String _selectedKeyword = "1B";
  String _dateRangeLabel = "30 Hari Terakhir";
  List<String> _selectedMerchants = [];
  String _storeFilterLabel = "Semua toko";

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _pilihUrutan = [
    // "Tanggal Terkini",
    // "Tanggal Terlama",
    "Transaksi Tertinggi",
    "Transaksi Terendah",
    "PPN Tertinggi",
    "PPN Terendah",
    "Total Tertinggi",
    "Total Terendah",
  ];

  final List<String> _pendapatanText = [
    // "tanggalTerkini",
    // "tanggalTerlama",
    "transaksiTertinggi",
    "transaksiTerendah",
    "ppnTertinggi",
    "ppnTerendah",
    "totalTertinggi",
    "totalTerendah",
  ];

  @override
  void initState() {
    super.initState();
    _selectedMerchants = [widget.merchantId];
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    String keyword = _selectedKeyword;
    if (keyword == "custom" && _startDate != null && _endDate != null) {
      keyword = "${DateFormat('yyyy-MM-dd').format(_startDate!)} s/d ${DateFormat('yyyy-MM-dd').format(_endDate!)}";
    }

    try {
      final data = await getLaporanMerchant(
        context,
        widget.token,
        keyword,
        _selectedSortValue,
        _selectedMerchants,
        "", // export
      );

      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return "Rp 0";
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value is num ? value : (num.tryParse(value.toString()) ?? 0));
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  void _exportReport(String type) async {
    String keyword = _selectedKeyword;
    if (keyword == "custom" && _startDate != null && _endDate != null) {
      keyword = "${DateFormat('yyyy-MM-dd').format(_startDate!)} s/d ${DateFormat('yyyy-MM-dd').format(_endDate!)}";
    }

    final result = await getLaporanMerchant(
      context,
      widget.token,
      keyword,
      _selectedSortValue,
      _selectedMerchants,
      type,
    );

    if (result != null && result['rc'] == "00") {
      final String? downloadUrl = result['data'];
      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        _launchURL(downloadUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pendapatan Per Toko',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
        actions: [
          IconButton(
            icon:  Icon(PhosphorIcons.share_network, color: primary500),
            onPressed: _showShareModal,
          ),
           SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(_selectedSortLabel, _showSortModal),
                   SizedBox(width: 8),
                  _buildFilterChip(_dateRangeLabel, _showDateRangeModal),
                   SizedBox(width: 8),
                  _buildFilterChip(_storeFilterLabel, _showStoreModal),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ?  Center(child: CircularProgressIndicator())
                : _buildReportList(),
          ),
          if (!_isLoading && _reportData != null) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: bnw300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: heading4(FontWeight.w500, bnw900, 'Outfit'),
            ),
             SizedBox(width: 4),
             Icon(Icons.arrow_drop_down, size: 20, color: bnw900),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    final List<dynamic> details = _reportData?['data']?['detail'] ?? [];
    if (details.isEmpty) {
      return Center(
        child: Text(
          "Tidak ada data laporan",
          style: heading3(FontWeight.w400, bnw500, 'Outfit'),
        ),
      );
    }

    return ListView.builder(
      padding:  EdgeInsets.all(16),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildMerchantCard(detail);
      },
    );
  }

  Widget _buildMerchantCard(Map<String, dynamic> detail) {
    return Container(
      margin:  EdgeInsets.only(bottom: 16),
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bnw300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bnw200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Icon(PhosphorIcons.storefront, color: bnw600, size: 20),
              ),
               SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail['namerToko'] ?? 'Nama Toko',
                      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
           SizedBox(height: 16),
          _buildDetailRow("Jumlah Transaksi", "${detail['totalTransaksi'] ?? 0}"),
           SizedBox(height: 8),
          _buildDetailRow("Nilai Transaksi", _formatCurrency(detail['nilaiTransaksi'])),
           SizedBox(height: 8),
          _buildDetailRow("PPN", _formatCurrency(detail['totalPPN'])),
           Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: heading3(FontWeight.w600, bnw900, 'Outfit')),
              Text(_formatCurrency(detail['total']), style: heading3(FontWeight.w600, bnw900, 'Outfit')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: heading4(FontWeight.w400, bnw700, 'Outfit')),
        Text(value, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
      ],
    );
  }

  Widget _buildBottomBar() {
    final header = _reportData?['data']?['header'];
    final total = header?['total'] ?? 0;

    return GestureDetector(
      onTap: _showSummaryModal,
      child: Container(
        padding:  EdgeInsets.all(16),
        decoration:  BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: heading3(FontWeight.w600, Colors.white, 'Outfit'),
            ),
            Row(
              children: [
                Text(
                  _formatCurrency(total),
                  style: heading3(FontWeight.w600, Colors.white, 'Outfit'),
                ),
                 SizedBox(width: 8),
                 Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareModal() {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding:  EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
               SizedBox(height: 24),
              Text("Bagikan Laporan", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
              Text("Pilih format untuk dibagikan", style: heading4(FontWeight.w400, bnw500, 'Outfit')),
               SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _exportReport("pdf");
                      },
                      style: OutlinedButton.styleFrom(
                        padding:  EdgeInsets.symmetric(vertical: 16),
                        side:  BorderSide(color: primary500),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon:  Icon(PhosphorIcons.file_pdf, color: primary500),
                      label: Text("PDF", style: heading3(FontWeight.w600, primary500, 'Outfit')),
                    ),
                  ),
                   SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _exportReport("excel");
                      },
                      style: OutlinedButton.styleFrom(
                        padding:  EdgeInsets.symmetric(vertical: 16),
                        side:  BorderSide(color: primary500),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon:  Icon(PhosphorIcons.file_xls, color: primary500),
                      label: Text("Excel", style: heading3(FontWeight.w600, primary500, 'Outfit')),
                    ),
                  ),
                ],
              ),
               SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempOrder = _selectedSortValue;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding:  EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                   SizedBox(height: 20),
                  Text("Urutkan", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
                  Text("Pilih Urutan yang ingin ditampilkan", style: heading4(FontWeight.w400, bnw500, 'Outfit')),
                   SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(_pilihUrutan.length, (index) {
                      final label = _pilihUrutan[index];
                      final value = _pendapatanText[index];
                      final isSelected = tempOrder == value;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            tempOrder = value;
                          });
                        },
                        child: Container(
                          padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? primary500.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? primary500 : bnw300),
                          ),
                          child: Text(
                            label,
                            style: heading4(
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                              isSelected ? primary500 : bnw900,
                              'Outfit',
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                   SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSortValue = tempOrder;
                          _selectedSortLabel = _pilihUrutan[_pendapatanText.indexOf(tempOrder)];
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding:  EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("Tampilkan", style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDateRangeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding:  EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                   SizedBox(height: 20),
                  Text("Rentang Waktu", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
                   SizedBox(height: 20),
                  _buildDateOption("30 Hari Terakhir", "1B", setModalState),
                  _buildDateOption("3 Bulan Terakhir", "3B", setModalState),
                  _buildDateOption("6 Bulan Terakhir", "6B", setModalState),
                  _buildDateOption("1 Tahun Terakhir", "1Y", setModalState),
                  _buildDateOption("Kustom Hari", "custom", setModalState),
                  if (_selectedKeyword == "custom") ...[
                     SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setModalState(() => _startDate = picked);
                            },
                            child: Container(
                              padding:  EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(border: Border.all(color: bnw300), borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              child: Text(_startDate == null ? "Dari Tanggal" : DateFormat('dd-MM-yyyy').format(_startDate!)),
                            ),
                          ),
                        ),
                         Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("-")),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setModalState(() => _endDate = picked);
                            },
                            child: Container(
                              padding:  EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(border: Border.all(color: bnw300), borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              child: Text(_endDate == null ? "Sampai Tanggal" : DateFormat('dd-MM-yyyy').format(_endDate!)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                   SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dateRangeLabel = _selectedKeyword == "custom" 
                              ? "Kustom Hari" 
                              : {"1B": "30 Hari Terakhir", "3B": "3 Bulan Terakhir", "6B": "6 Bulan Terakhir", "1Y": "1 Tahun Terakhir"}[_selectedKeyword] ?? "30 Hari Terakhir";
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding:  EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("Tampilkan", style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDateOption(String label, String value, StateSetter setModalState) {
    bool isSelected = _selectedKeyword == value;
    return ListTile(
      title: Text(label, style: heading3(FontWeight.w500, isSelected ? primary500 : bnw900, 'Outfit')),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedKeyword,
        activeColor: primary500,
        onChanged: (val) => setModalState(() => _selectedKeyword = val!),
      ),
      onTap: () => setModalState(() => _selectedKeyword = value),
    );
  }

  void _showStoreModal() async {
    final stores = await getAllToko(context, widget.token, '', 'asc');
    if (stores == null || stores.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding:  EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ),
                   SizedBox(height: 20),
                  Text("Daftar Toko", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
                   SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        final isSelected = _selectedMerchants.contains(store.merchantid);
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: primary500,
                          title: Text(store.name ?? '', style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) _selectedMerchants.add(store.merchantid!);
                              else _selectedMerchants.remove(store.merchantid);
                            });
                          },
                        );
                      },
                    ),
                  ),
                   SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedMerchants.length == stores.length) _storeFilterLabel = "Semua toko";
                          else if (_selectedMerchants.isEmpty) _storeFilterLabel = "Pilih toko";
                          else _storeFilterLabel = "${_selectedMerchants.length} toko dipilih";
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding:  EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("Selesai", style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showSummaryModal() {
    final header = _reportData?['data']?['header'];
    if (header == null) return;
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding:  EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total Laporan", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
               SizedBox(height: 24),
              _buildSummaryRow("Total Jumlah Transaksi", "${header['count'] ?? 0}"),
               SizedBox(height: 12),
              _buildSummaryRow("Total Nilai Transaksi", _formatCurrency(header['nilaiTransaksi'])),
               SizedBox(height: 12),
              _buildSummaryRow("Total PPN", _formatCurrency(header['totalPPN'])),
               Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
                  Text(_formatCurrency(header['total']), style: heading2(FontWeight.w700, bnw900, 'Outfit')),
                ],
              ),
               SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: primary500, padding:  EdgeInsets.symmetric(vertical: 16)),
                  child: Text("Tutup", style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: heading4(FontWeight.w400, bnw700, 'Outfit')),
        Text(value, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
      ],
    );
  }
}
