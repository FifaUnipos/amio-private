import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/main.dart'; // For identifier

class BillListPage extends StatefulWidget {
  final String token;
  final String merchantId;
  final String baseUrl;

  const BillListPage({
    Key? key,
    required this.token,
    required this.merchantId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<BillListPage> createState() => _BillListPageState();
}

class _BillListPageState extends State<BillListPage> {
  List<dynamic> _billList = [];
  bool _isLoading = true;

  Color _getStatusColor(String? code) {
    if (code == '1') return Colors.green;
    if (code == '3') return Colors.orange;
    return Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    try {
      final url = Uri.parse(getTransaksiRiwayatUrl);
      final response = await http.post(
        url,
        headers: {
          'token': widget.token,
          'DEVICE-ID': identifier!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "condition": "0", // 0 for Unpaid/Saved bills
          "order_by": "upDownCreate",
          "merchant_id": widget.merchantId,
        }),
      );

      print('Bill List response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          setState(() {
            _billList = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching bills: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Tagihan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Divider(height: 1, color: bnw300),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Cari',
                      icon: Icon(Icons.search, color: bnw900),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Sort and Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: bnw300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Urutkan", style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink),
                      ),
                      child: Text(
                        'Belum Bayar : ${_billList.length}',
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Pilih Sekaligus',
                      style: TextStyle(
                        color: primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _billList.isEmpty
                    ? const Center(child: Text("Tidak ada tagihan tersimpan"))
                    : ListView.separated(
                        itemCount: _billList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _billList[index];
                          final amount =
                              double.tryParse(item['amount'].toString()) ?? 0;
                          return ListTile(
                            onTap: () => _showDetail(item['transaction_id']),
                            title: Text(
                              item['customer'] ?? 'Pelanggan',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp. ',
                                decimalDigits: 0,
                              ).format(amount),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                   item['entry_date'] != null
                                       ? DateFormat('dd MMM yy').format(DateTime.parse(item['entry_date']))
                                       : '',
                                   style: const TextStyle(
                                     color: Colors.black,
                                     fontSize: 12,
                                   ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item['status_color']?.toString()).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: _getStatusColor(item['status_color']?.toString())),
                                  ),
                                  child: Text(
                                    item['status_transactions'] ?? '-',
                                    style: TextStyle(
                                      color: _getStatusColor(item['status_color']?.toString()),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetail(String transactionId) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BillDetailModal(
        token: widget.token,
        merchantId: widget.merchantId,
        transactionId: transactionId,
        baseUrl: widget.baseUrl,
      ),
    );

    print('Bill detail modal closed with result: $result');
    
    if (result != null) {
      // Check if result is a String first (for 'refresh')
      if (result == 'refresh') {
        print('Refreshing bill list...');
        await _fetchBills();
        print('Bill list refreshed');
      } else if (result is Map && (result['action'] == 'pay' || result['action'] == 'edit')) {
        // Handle pay/edit actions
        Navigator.pop(context, result);
      }
    }
  }
}

// -----------------------------------------------------
// Bill Detail Modal
// -----------------------------------------------------

class BillDetailModal extends StatefulWidget {
  final String token;
  final String merchantId;
  final String transactionId;
  final String baseUrl;

  const BillDetailModal({
    Key? key,
    required this.token,
    required this.merchantId,
    required this.transactionId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<BillDetailModal> createState() => _BillDetailModalState();
}

class _BillDetailModalState extends State<BillDetailModal> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;

  Color _getStatusColor(String? code) {
    if (code == '1') return Colors.green;
    if (code == '3') return Colors.orange;
    return Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final url = Uri.parse(getTransaksiSingleRiwayatUrl);
      final response = await http.post(
        url,
        headers: {
          'token': widget.token,
          'DEVICE-ID': identifier!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "transaction_id": widget.transactionId,
          "merchantid": widget.merchantId,
        }),
      );

      print('Bill Detail response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          setState(() {
            _detailData = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching bill detail: $e');
      setState(() => _isLoading = false);
    }
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ... existing code ...

  List<dynamic> _deleteReasons = [];
  bool _isLoadingReasons = false;

  Future<void> _fetchReasons() async {
    setState(() => _isLoadingReasons = true);
    try {
      final url = Uri.parse(getKategoriUrl); // Ensure this is imported/available
      final response = await http.post(
        url,
        headers: {
          'token': widget.token,
          'DEVICE-ID': identifier!, // Ensure identifier is imported
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "deviceid": identifier,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          setState(() {
            _deleteReasons = (data['data'] as List)
                .where((item) => item['typekategori'] == 'hapus')
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching reasons: $e');
    } finally {
      setState(() => _isLoadingReasons = false);
    }
  }

  void _showDeleteDialog() async {
    await _fetchReasons();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _DeleteReasonDialog(
        reasons: _deleteReasons,
        onConfirm: (reasonId, notes) => _processDelete(reasonId, notes),
      ),
    );
  }

  Future<void> _processDelete(String reasonId, String notes) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse(deleteTagihanUrl);
      final response = await http.post(
        url,
        headers: {
          'token': widget.token,
          'DEVICE-ID': identifier!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "deviceid": identifier,
          "transactionid": widget.transactionId,
          "idkategori": reasonId,
          "detail_alasan": notes,
        }),
      );
      
      if (!mounted) return;
      
      // Pop loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Delete response: ${response.body}');
        if (data['rc'] == '00') {
          // Success - close detail modal and signal refresh
          print('Delete successful, popping with refresh signal');
          if (!mounted) return;
          Navigator.pop(context, 'refresh');
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Gagal menghapus')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Terjadi kesalahan sistem')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detail Tagihan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detailData == null
                ? const Center(child: Text("Gagal memuat detail"))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Tagihan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Nomor Transaksi',
                          '#${_detailData!['transactionid'] ?? '-'}',
                        ),
                        // Status Row
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status', style: TextStyle(color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_detailData!['status_color']?.toString()).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _getStatusColor(_detailData!['status_color']?.toString())),
                                ),
                                child: Text(
                                  _detailData!['status_transactions'] ?? '-',
                                  style: TextStyle(
                                    color: _getStatusColor(_detailData!['status_color']?.toString()),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildInfoRow(
                          'Nama Pembeli',
                          _detailData!['customer'] ?? 'Walking Customer',
                        ),
                        _buildInfoRow('Kasir', _detailData!['pic'] ?? '-'),
          
                        const SizedBox(height: 24),
                        const Text(
                          'Rincian Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        if (_detailData!['detail'] != null)
                          ...(_detailData!['detail'] as List).map((item) {
                            return _buildProductItem(item);
                          }).toList(),
          
                        const SizedBox(height: 24),
                        const Text(
                          'Rincian Biaya Tagihan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Sub Total',
                          _detailData!['total_before_dsc_tax'],
                          isCurrency: true,
                        ),
                        if (_parseAmount(_detailData!['ppn']) > 0)
                          _buildSummaryRow(
                            'PPN',
                            _detailData!['ppn'],
                            isCurrency: true,
                          ),
                         const Divider(
                          height: 24,
                          thickness: 1,
                        ),
                        _buildSummaryRow(
                          'Total', // As per image
                          _detailData!['amount'],
                          isCurrency: true,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
          ),
          
          const SizedBox(height: 20),
          // Actions: Hapus, Ubah, Bayar
          Row(
            children: [
              // Hapus Button (Icon)
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                    onPressed: _showDeleteDialog,
                    icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              
              // Ubah Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                     Navigator.pop(context, {'action': 'edit', 'data': _detailData});
                  },
                  icon:  Icon(Icons.edit, size: 16, color: primary500),
                  label: Text(
                    'Ubah',
                    style: TextStyle(color: primary500),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:  BorderSide(color: primary500),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Bayar Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.pop(context, {'action': 'pay', 'data': _detailData});
                  },
                  icon: const Icon(Icons.wallet, size: 16, color: Colors.white),
                   label: const Text(
                    'Bayar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... (existing helper methods _buildInfoRow, _buildSummaryRow, _buildProductItem) ...
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    dynamic value, {
    bool isCurrency = false,
    bool isBlue = false,
    bool isBold = false,
  }) {
    String displayValue = value.toString();
    if (isCurrency) {
      displayValue = NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits: 0,
      ).format(_parseAmount(value));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: isBlue ? primary500 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    final variants = item['variants'] as List? ?? [];
    List<String> variantTexts = [];

    for (var v in variants) {
      if (v['variant_products'] != null) {
        for (var vp in (v['variant_products'] as List)) {
          variantTexts.add(vp['variant_product_name']);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration:  BoxDecoration(
        border: Border(bottom: BorderSide(color: bnw300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'x${item['quantity']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: item['product_image'] != null && item['product_image'] != ''
                ? Image.network(
                    item['product_image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  )
                : const Icon(Icons.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp. ',
                    decimalDigits: 0,
                  ).format(_parseAmount(item['price'])),
                  style: const TextStyle(fontSize: 12),
                ),
                if (variantTexts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Catatan : ${variantTexts.join(', ')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                 if (item['note'] != null && item['note'] != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                     child: Text(
                      'Catatan : ${item['note']}',
                       style: const TextStyle(fontSize: 12, color: Colors.grey),
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

class _DeleteReasonDialog extends StatefulWidget {
  final List<dynamic> reasons;
  final Function(String, String) onConfirm;

  const _DeleteReasonDialog({
    Key? key,
    required this.reasons,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_DeleteReasonDialog> createState() => _DeleteReasonDialogState();
}

class _DeleteReasonDialogState extends State<_DeleteReasonDialog> {
  String? _selectedReasonId;
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Hapus Tagihan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: const TextSpan(
                text: 'Alasan Hapus Tagihan ',
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.reasons.map((reason) {
                bool isSelected = _selectedReasonId == reason['idkategori'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReasonId = reason['idkategori'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reason['namakategori'] ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            RichText(
              text: const TextSpan(
                text: 'Detail Alasan ',
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Cth : Kurang 2 pesanan dan catatan 1 sendok gula',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReasonId == null || _notesController.text.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context); // Pop dialog first
                        widget.onConfirm(_selectedReasonId!, _notesController.text);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63), // Pink/Red color
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Hapus Tagihan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
