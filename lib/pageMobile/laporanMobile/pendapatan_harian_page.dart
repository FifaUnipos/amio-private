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
import 'package:url_launcher/url_launcher.dart';
import 'package:unipos_app_335/models/tokomodel.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart'; // To reuse identifier and getLaporanDaily if needed

class PendapatanHarianPage extends StatefulWidget {
  final String token;
  final String merchantId;

  PendapatanHarianPage({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<PendapatanHarianPage> createState() => _PendapatanHarianPageState();
}

class _PendapatanHarianPageState extends State<PendapatanHarianPage> {
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

    // If it's custom, the keyword might need to be the range string or handled differently.
    // Based on user provided API body, it uses "keyword".
    String keyword = _selectedKeyword;
    if (keyword == "custom" && _startDate != null && _endDate != null) {
      keyword =
          "${DateFormat('yyyy-MM-dd').format(_startDate!)} s/d ${DateFormat('yyyy-MM-dd').format(_endDate!)}";
    }

    try {
      final data = await getLaporanDaily(
        context,
        widget.token,
        _selectedSortValue,
        keyword,
        _selectedMerchants,
        "false", // export
      );

      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Error handled in getLaporanDaily usually show snackbar
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return "Rp 0";
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(
      value is num ? value : (num.tryParse(value.toString()) ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pendapatan Harian',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.share_network, color: primary500),
            onPressed: () {
              // Share logic
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildReportList(),
          ),

          // Bottom Summary Bar
          if (!_isLoading && _reportData != null) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: bnw300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
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
      padding: EdgeInsets.all(16),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return InkWell(
          onTap: () => _showDetailFullModal(detail['tanggal']),
          child: _buildDailyCard(detail),
        );
      },
    );
  }

  Widget _buildDailyCard(Map<String, dynamic> detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
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
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  PhosphorIcons.file_text,
                  color: primary500,
                  size: 18,
                ),
              ),
              SizedBox(width: 8),
              Text(
                detail['tanggal'] ?? '',
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            "Jumlah Transaksi",
            "${detail['totalTransaksi'] ?? 0}",
          ),
          SizedBox(height: 8),
          _buildDetailRow(
            "Nilai Transaksi",
            _formatCurrency(detail['nilaiTransaksi']),
          ),
          SizedBox(height: 8),
          _buildDetailRow("PPN", _formatCurrency(detail['totalPPN'])),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: heading3(FontWeight.w600, bnw900, 'Outfit')),
              Text(
                _formatCurrency(detail['total']),
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
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

  Widget _buildSummaryDailyRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: heading4(
            isBold ? FontWeight.w600 : FontWeight.w400,
            bnw900,
            'Outfit',
          ),
        ),
        Text(
          value,
          style: heading4(
            isBold ? FontWeight.w600 : FontWeight.w400,
            bnw900,
            'Outfit',
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  void _showDetailFullModal(String? date) async {
    if (date == null) return;

    final result = await getLaporanDailyFull(
      context,
      widget.token,
      date,
      _selectedSortValue,
      _selectedMerchants,
      "",
    );

    if (result != null && result['rc'] == "00") {
      final data = result['data'];
      final header = data['header'];
      final List details = data['detail'] ?? [];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.all(24),
            child: Column(
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
                Text(
                  "Informasi Pendapatan $date",
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                SizedBox(height: 20),
                _buildSummaryDailyRow(
                  "Jumlah Transaksi",
                  "${header['count'] ?? 0}",
                ),
                SizedBox(height: 8),
                _buildSummaryDailyRow(
                  "Nilai Transaksi",
                  _formatCurrency(header['nilaiTransaksi']),
                ),
                SizedBox(height: 8),
                _buildSummaryDailyRow(
                  "Total PPN",
                  _formatCurrency(header['totalPPN']),
                ),
                SizedBox(height: 8),
                _buildSummaryDailyRow(
                  "Total Diskon",
                  _formatCurrency(header['totalDiscount']),
                ),
                SizedBox(height: 8),
                _buildSummaryDailyRow(
                  "Total Keseluruhan",
                  _formatCurrency(header['total']),
                  isBold: true,
                ),
                SizedBox(height: 24),
                Text(
                  "Rincian Per Toko",
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final store = details[index];
                      final storeDetail = (store['detail'] is Map)
                          ? store['detail']
                          : {};
                      final List products = (storeDetail['product'] is List)
                          ? storeDetail['product']
                          : [];
                      final Map<String, dynamic> payments =
                          (storeDetail['paymentMethod'] is Map)
                          ? Map<String, dynamic>.from(
                              storeDetail['paymentMethod'],
                            )
                          : {};

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['nameToko'] ?? '',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 12),
                          _buildSummaryDailyRow(
                            "Jumlah Transaksi",
                            "${store['totalTransaksi'] ?? 0}",
                          ),
                          SizedBox(height: 8),
                          _buildSummaryDailyRow(
                            "Nilai Transaksi",
                            _formatCurrency(store['nilaiTransaksi']),
                          ),
                          SizedBox(height: 8),
                          _buildSummaryDailyRow(
                            "Total PPN",
                            _formatCurrency(store['totalPPN']),
                          ),
                          SizedBox(height: 8),
                          _buildSummaryDailyRow(
                            "Total Diskon",
                            _formatCurrency(store['totalDiscount']),
                          ),
                          SizedBox(height: 8),
                          _buildSummaryDailyRow(
                            "Total Keseluruhan",
                            _formatCurrency(store['total']),
                            isBold: true,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Metode Pembayaran",
                            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 8),
                          ...payments.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: _buildSummaryDailyRow(
                                e.key,
                                _formatCurrency(e.value),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Rincian Produk",
                            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 8),
                          ...products.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        p['nameProduk'] ?? '',
                                        style: heading4(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        "Total Produk",
                                        style: heading4(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCurrency(p['total']),
                                        style: heading4(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 32),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _exportReport(date, "pdf"),
                        icon: Icon(PhosphorIcons.file_pdf, size: 18),
                        label: Text(
                          "PDF",
                          style: heading3(
                            FontWeight.w600,
                            primary500,
                            'Outfit',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _exportReport(date, "excel"),
                        icon: Icon(PhosphorIcons.file_xls, size: 18),
                        label: Text(
                          "Excel",
                          style: heading3(
                            FontWeight.w600,
                            primary500,
                            'Outfit',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
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
  }

  void _exportReport(String date, String type) async {
    final result = await getLaporanDailyFull(
      context,
      widget.token,
      date,
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

  // Modals
  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempOrder = _selectedSortValue;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
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
                  SizedBox(height: 20),
                  Text(
                    "Urutkan",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    "Pilih Urutan yang ingin ditampilkan",
                    style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                  ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary500.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? primary500 : bnw300,
                            ),
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
                          _selectedSortLabel =
                              _pilihUrutan[_pendapatanText.indexOf(tempOrder)];
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Tampilkan",
                        style: heading3(
                          FontWeight.w600,
                          Colors.white,
                          'Outfit',
                        ),
                      ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
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
                  SizedBox(height: 20),
                  Text(
                    "Rentang Waktu",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    "Pilih rentang data yang ingin ditampilkan",
                    style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                  ),
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
                              if (picked != null) {
                                setModalState(() => _startDate = picked);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: bnw300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _startDate == null
                                    ? "Dari Tanggal"
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(_startDate!),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("-"),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => _endDate = picked);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: bnw300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _endDate == null
                                    ? "Sampai Tanggal"
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(_endDate!),
                              ),
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
                          if (_selectedKeyword == "custom") {
                            _dateRangeLabel = "Kustom Hari";
                          } else {
                            _dateRangeLabel =
                                {
                                  "1B": "30 Hari Terakhir",
                                  "3B": "3 Bulan Terakhir",
                                  "6B": "6 Bulan Terakhir",
                                  "1Y": "1 Tahun Terakhir",
                                }[_selectedKeyword] ??
                                "30 Hari Terakhir";
                          }
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Tampilkan",
                        style: heading3(
                          FontWeight.w600,
                          Colors.white,
                          'Outfit',
                        ),
                      ),
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

  Widget _buildDateOption(
    String label,
    String value,
    StateSetter setModalState,
  ) {
    bool isSelected = _selectedKeyword == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: heading3(
          FontWeight.w500,
          isSelected ? primary500 : bnw900,
          'Outfit',
        ),
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedKeyword,
        activeColor: primary500,
        onChanged: (val) {
          setModalState(() {
            _selectedKeyword = val!;
          });
        },
      ),
      onTap: () {
        setModalState(() {
          _selectedKeyword = value;
        });
      },
    );
  }

  void _showStoreModal() async {
    final stores = await getAllToko(context, widget.token, '', 'asc');
    if (stores == null || stores.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
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
                  SizedBox(height: 20),
                  Text(
                    "Daftar Toko",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    "Pilih data toko yang ingin ditampilkan",
                    style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        final isSelected = _selectedMerchants.contains(
                          store.merchantid,
                        );

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: bnw300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            activeColor: primary500,
                            title: Text(
                              store.name ?? '',
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            subtitle: Text(
                              store.address ?? '',
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                            secondary: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: bnw200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.store, color: bnw600),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  _selectedMerchants.add(store.merchantid!);
                                } else {
                                  _selectedMerchants.remove(store.merchantid);
                                }
                              });
                            },
                          ),
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
                          if (_selectedMerchants.length == stores.length) {
                            _storeFilterLabel = "Semua toko";
                          } else if (_selectedMerchants.isEmpty) {
                            _storeFilterLabel = "Pilih toko";
                          } else {
                            _storeFilterLabel =
                                "${_selectedMerchants.length} toko dipilih";
                          }
                        });
                        _fetchData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Selesai",
                        style: heading3(
                          FontWeight.w600,
                          Colors.white,
                          'Outfit',
                        ),
                      ),
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

  void _showSummaryModal() {
    final header = _reportData?['data']?['header'];
    if (header == null) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
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
              Text(
                "Total Laporan",
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 24),
              _buildSummaryDailyRow(
                "Total Jumlah Transaksi",
                "${header['count'] ?? 0}",
              ),
              SizedBox(height: 12),
              _buildSummaryDailyRow(
                "Total Nilai Transaksi",
                _formatCurrency(header['nilaiTransaksi']),
              ),
              SizedBox(height: 12),
              _buildSummaryDailyRow(
                "Total PPN",
                _formatCurrency(header['totalPPN']),
              ),
              Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    _formatCurrency(header['total']),
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Tutup",
                    style: heading3(FontWeight.w600, Colors.white, 'Outfit'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
