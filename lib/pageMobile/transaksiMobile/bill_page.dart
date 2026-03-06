import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/atoms/unipos_information.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_list_reasons_provider.dart';
import 'package:unipos_app_335/pageMobile/transaksiMobile/history/modal_delete.dart';
import 'package:unipos_app_335/providers/transactions/transaction_provider.dart';
import 'package:unipos_app_335/models/transactionModel.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/status_transaction.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/services/config/app_endpoints.dart';
import 'package:unipos_app_335/main.dart';

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
  String _orderBy = "upDownCreate";
  String _orderLabel = "Terbaru";

  final List<Map<String, String>> _sortOptions = [
    {"label": "Terbaru", "value": "upDownCreate"},
    {"label": "Terlama", "value": "downUpCreate"},
    {"label": "Nama(A-Z)", "value": "upDownNama"},
    {"label": "Nama(Z-A)", "value": "downUpNama"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBills();
    });
  }

  void _fetchBills() {
    context.read<TransactionProvider>().fetchBills(
      token: widget.token,
      merchantId: widget.merchantId,
      orderBy: _orderBy,
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Urutkan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._sortOptions.map((opt) {
                final selected = _orderBy == opt["value"];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt["label"]!),
                  trailing: selected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _orderBy = opt["value"]!;
                      _orderLabel = opt["label"]!;
                    });
                    Navigator.pop(context);
                    _fetchBills();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final billList = transactionProvider.billList;
    final isLoading = transactionProvider.isLoadingBills;

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showSortModal,
                      child: Container(
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
                          children: [
                            Text(
                              "Urutkan : $_orderLabel",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink),
                      ),
                      child: Text(
                        'Belum Bayar : ${billList.length}',
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading && billList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : billList.isEmpty
                    ? const Center(child: Text("Tidak ada tagihan tersimpan"))
                    : ListView.separated(
                        itemCount: billList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = billList[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _showDetail(item.transactionId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.customer ?? 'Pelanggan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp. ',
                                          decimalDigits: 0,
                                        ).format(item.amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        item.entryDate != null
                                            ? item.entryDate!.split(' ').last
                                            : '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      UniposInformation(
                                        size: UniposInformationSize.extraSmall,
                                        variant:
                                            statusTransactionCancel.contains(
                                              item.isPaid,
                                            )
                                            ? UniposInformationVariant.danger
                                            : statusTransactionProcessCancel
                                                .contains(item.isPaid)
                                            ? UniposInformationVariant.warning
                                            : UniposInformationVariant.success,
                                        text:
                                            '${item.statusTransactions ?? '-'}',
                                        showIcon: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

    if (result == true || result == 'refresh') {
      _fetchBills();
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetail();
    });
  }

  void _fetchDetail() {
    context.read<TransactionProvider>().fetchTransactionDetail(
      token: widget.token,
      merchantId: widget.merchantId,
      transactionId: widget.transactionId,
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  void _showDeleteDialog() async {
    final detail = context.read<TransactionProvider>().transactionDetail;
    if (detail == null) return;

    // Convert TransactionDetailModel to the Map format expected by ModalTransactionDelete
    final Map<String, dynamic> dataDetail = {
      'transactionid': detail.transactionId,
      // Add other fields if needed by the modal
    };

    // Fetch reasons first as per user's example
    context.read<TransactionHistoryDeleteReasonsProvider>().fetchDeleteListReasons(
          detail.transactionId,
          widget.token,
        );

    final success = await ModalTransactionDelete.show(
      context,
      dataDetail,
      widget.token,
    );

    if (success == true) {
      if (mounted) {
        Navigator.pop(context, 'refresh');
      }
    }
  }


  Color _getStatusColor(String? code) {
    if (code == '1') return Colors.green;
    if (code == '3') return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final isLoading = transactionProvider.isLoadingDetail;
    final detail = transactionProvider.transactionDetail;

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
          Expanded(
            child: isLoading && detail == null
                ? const Center(child: CircularProgressIndicator())
                : detail == null
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
                            _buildInfoRow('Nomor Transaksi', '#${detail.transactionId}'),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Status', style: TextStyle(color: Colors.grey)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(detail.statusColor?.toString()).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: _getStatusColor(detail.statusColor?.toString())),
                                    ),
                                    child: Text(
                                      detail.statusTransactions ?? '-',
                                      style: TextStyle(
                                        color: _getStatusColor(detail.statusColor?.toString()),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildInfoRow('Nama Pembeli', detail.customer ?? 'Walking Customer'),
                            _buildInfoRow('Kasir', detail.pic ?? '-'),
                            const SizedBox(height: 24),
                            const Text(
                              'Rincian Pesanan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            if (detail.detailProducts != null)
                              ...detail.detailProducts!.map((item) => _buildProductItem(item.toJson())).toList(),
                            const SizedBox(height: 24),
                            const Text(
                              'Rincian Biaya Tagihan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow('Sub Total', detail.totalBeforeDscTax, isCurrency: true),
                            if (detail.ppn > 0)
                              _buildSummaryRow('PPN', detail.ppn, isCurrency: true),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('Total', detail.amount, isCurrency: true, isBold: true),
                          ],
                        ),
                      ),
          ),
          const SizedBox(height: 20),
          if (detail != null && !statusTransactionCancel.contains(detail.isPaid))
            Row(
              children: [
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, {'action': 'edit', 'data': detail.toJson()}),
                    icon: Icon(Icons.edit, size: 16, color: primary500),
                    label: Text('Ubah', style: TextStyle(color: primary500)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary500),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, {'action': 'pay', 'data': detail.toJson()}),
                    icon: const Icon(Icons.wallet, size: 16, color: Colors.white),
                    label: const Text('Bayar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary500,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

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

  Widget _buildSummaryRow(String label, dynamic value, {bool isCurrency = false, bool isBlue = false, bool isBold = false}) {
    String displayValue = value.toString();
    if (isCurrency) {
      displayValue = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(_parseAmount(value));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(displayValue, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 16 : 14, color: isBlue ? primary500 : Colors.black)),
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
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: bnw300))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('x${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: item['product_image'] != null && item['product_image'] != ''
                ? Image.network(item['product_image'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                : const Icon(Icons.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(_parseAmount(item['price'])), style: const TextStyle(fontSize: 12)),
                if (variantTexts.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Varian : ${variantTexts.join(', ')}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                if (item['note'] != null && item['note'] != '')
                  Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Catatan : ${item['note']}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
