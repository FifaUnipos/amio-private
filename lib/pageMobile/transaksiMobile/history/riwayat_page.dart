import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button_option.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button_status.dart';
import 'package:unipos_app_335/components/atoms/fields/unipos_text_field.dart';
import 'package:unipos_app_335/components/atoms/unipos_detail_row.dart';
import 'package:unipos_app_335/components/atoms/unipos_information.dart';
import 'package:unipos_app_335/components/moleculs/unipos_modal.dart';
import 'package:unipos_app_335/pageMobile/transaksiMobile/history/modal_delete.dart';
import 'package:unipos_app_335/pageMobile/transaksiMobile/history/modal_view_deleted_history.dart';
import 'package:unipos_app_335/data/model/transaction/history/view_deleted_history_response.dart';
import 'package:unipos_app_335/data/static/transaction/history/delete_reasons_state.dart';
import 'package:unipos_app_335/data/static/transaction/history/view_deleted_history_state.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_list_reasons_provider.dart';
import 'dart:convert';
import 'package:skeletons_forked/skeletons_forked.dart';
import 'package:unipos_app_335/providers/transactions/history/view_deleted_history_provider.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/main.dart'; // For identifier
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';
import 'package:unipos_app_335/utils/status_transaction.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class HistoryTab extends StatefulWidget {
  final String token;
  final String merchantId;
  final String baseUrl;

  const HistoryTab({
    Key? key,
    required this.token,
    required this.merchantId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<dynamic> _historyList = [];
  bool _isLoading = true;
  // Sorting State
  String _selectedSortText = "Riwayat Terbaru";
  String _selectedSortTag = "upDownCreate";

  List<String> orderByRiwayatText = [
    "Riwayat Terbaru",
    "Riwayat Terlama",
    "Nama Pembeli A ke Z",
    "Nama Pembeli Z ke A",
    "Total Tertinggi",
    "Total Terendah",
  ];

  List<String> orderByRiwayatTagihan = [
    "upDownCreate",
    "downUpCreate",
    "upDownNama",
    "downUpNama",
    "downUpAmount",
    "upDownAmount",
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
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
          "condition": "1",
          "order_by": _selectedSortTag,
          "merchant_id": widget.merchantId,
        }),
      );

      print('History response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          setState(() {
            _historyList = data['data'];

            // Pastikan raw diambil dengan benar dan diformat
            for (var item in _historyList) {
              if (item['raw'] != null) {
                String rawData = item['raw'];

                // Menghilangkan spasi berlebihan tanpa menghapus \n
                rawData = rawData.replaceAll(
                  RegExp(r'\s{2,}'),
                  ' ',
                ); // Ganti spasi berlebihan menjadi satu spasi

                // Simpan raw yang sudah diformat
                item['raw'] = rawData
                    .trim(); // Trim untuk menghapus spasi di awal/akhir
              }
            }

            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching history: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSortRiwayatModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Urutkan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih urutan yang ingin ditampilkan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(orderByRiwayatText.length, (index) {
                  final label = orderByRiwayatText[index];
                  final tag = orderByRiwayatTagihan[index];
                  bool isSelected = _selectedSortTag == tag;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSortTag = tag;
                        _selectedSortText = label;
                      });
                      Navigator.pop(context);
                      _fetchHistory();
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
                        border: Border.all(
                          color: isSelected ? primary500 : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? primary500 : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: bnw300),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: bnw200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bnw300),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari',
                    icon: Icon(Icons.search, color: bnw900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showSortRiwayatModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: bnw300),
                        borderRadius: BorderRadius.circular(8),
                        color: bnw100,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedSortText,
                            style: TextStyle(fontSize: 12, color: bnw900),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 16, color: bnw900),
                        ],
                      ),
                    ),
                  ),
                  _outlineBtn('Total : ${_historyList.length}'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _historyList.isEmpty
              ? const Center(child: Text("Belum ada riwayat transaksi"))
              : ListView.separated(
                  itemCount: _historyList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    final amount =
                        double.tryParse(item['amount'].toString()) ?? 0;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showDetail(item['transaction_id']),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['customer'] ?? 'Pelanggan',
                                  style: const TextStyle(fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp. ',
                                    decimalDigits: 0,
                                  ).format(amount),
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
                                  item['entry_date'] != null
                                      ? (item['entry_date'] as String)
                                            .split(' ')
                                            .last
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
                                        item['isPaid'],
                                      )
                                      ? UniposInformationVariant.danger
                                      : statusTransactionProcessCancel.contains(
                                          item['isPaid'],
                                        )
                                      ? UniposInformationVariant.warning
                                      : UniposInformationVariant.success,
                                  text: '${item['status_transactions'] ?? '-'}',
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
    );
  }

  void _showDetail(String transactionId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(
        token: widget.token,
        merchantId: widget.merchantId,
        transactionId: transactionId,
        baseUrl: widget.baseUrl,
      ),
    );

    if (result == true) {
      _fetchHistory();
    }
  }

  Widget _outlineBtn(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: bnw900),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

// -----------------------------------------------------
// Transaction Detail Modal
// -----------------------------------------------------

class TransactionDetailModal extends StatefulWidget {
  final String token;
  final String merchantId;
  final String transactionId;
  final String baseUrl;

  const TransactionDetailModal({
    Key? key,
    required this.token,
    required this.merchantId,
    required this.transactionId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;
  bool isDropdownOpen = false;

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
          "merchant_id": widget.merchantId,
        }),
      );

      debugPrint('Detail response: ${response.body}');
      final dataku = jsonDecode(response.body);
      print('Detail data: $dataku');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['rc'] == '00' && data['data'] != null) {
          setState(() {
            // Menyimpan data di _detailData
            _detailData = data['data'];

            // Pastikan 'raw' ada dan ambil isinya
            if (_detailData != null && _detailData!.containsKey('raw')) {
              String rawData = _detailData!['raw']; // Ambil nilai raw

              // Membersihkan hanya spasi berlebihan tanpa menghapus \n
              rawData = rawData.replaceAll(
                RegExp(r'\s{2,}'),
                ' ',
              ); // Ganti spasi berlebihan menjadi satu spasi

              // Masukkan kembali raw yang sudah dibersihkan ke _detailData
              _detailData!['raw'] = rawData.trim();

              // Debugging: Cek raw data setelah dibersihkan
              print("Cleaned raw data: ${_detailData!['raw']}");
            } else {
              print("Raw data tidak ditemukan dalam _detailData");
            }

            // Update loading state
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching detail: $e');
      setState(() => _isLoading = false);
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
                'Detail Riwayat Transaksi',
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detailData == null
                ? const Center(child: Text("Gagal memuat detail"))
                : SingleChildScrollView(
                    child: Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: UniposInformation(
                                isFullWidth: true,
                                variant:
                                    statusTransactionCancel.contains(
                                      _detailData!['isPaid'],
                                    )
                                    ? UniposInformationVariant.danger
                                    : statusTransactionProcessCancel.contains(
                                        _detailData!['isPaid'],
                                      )
                                    ? UniposInformationVariant.warning
                                    : UniposInformationVariant.success,
                                text:
                                    '${_detailData!['status_transactions'] ?? '-'}',
                              ),
                            ),
                            if (statusTransactionCancel.contains(
                                  _detailData!['isPaid'],
                                ) ||
                                statusTransactionProcessCancel.contains(
                                  _detailData!['isPaid'],
                                ))
                              UniposButton(
                                text: 'Lihat Riwayat',
                                variant: UniposButtonVariant.tertiary,
                                onTap: () {
                                  if (_detailData == null ||
                                      _detailData!['transactionid'] == null) {
                                    showSnackbar(context, {
                                      'rc': '99',
                                      'message': 'ID Transaksi belum dimuat',
                                    });
                                    return;
                                  }
                                  context
                                      .read<
                                        TransactionViewDeletedHistoryProvider
                                      >()
                                      .fetchViewDeletedHistory(
                                        widget.token,
                                        _detailData!['transactionid']
                                            .toString(),
                                        widget.merchantId,
                                      );

                                  ModalTransactionViewDeletedHistory.show(
                                    context,
                                    _detailData,
                                  );
                                },
                              ),
                          ],
                        ),
                        const Text(
                          'Informasi Transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        _buildInfoRow(
                          'Nomor Transaksi',
                          '#${_detailData!['transactionid'] ?? '-'}',
                        ),
                        _buildInfoRow(
                          'Nama Pembeli',
                          _detailData!['customer'] ?? 'Walking Customer',
                        ),
                        _buildInfoRow('Kasir', _detailData!['pic'] ?? '-'),
                        const Text(
                          'Rincian Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(height: 1),
                        if (_detailData!['detail'] != null)
                          ...(_detailData!['detail'] as List).map((item) {
                            return _buildProductItem(item);
                          }).toList(),
                        const Text(
                          'Rincian Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Metode Pembayaran',
                          _detailData!['payment_name'] ?? '-',
                        ),
                        _buildSummaryRow(
                          'Sub Total',
                          _detailData!['total_before_dsc_tax'],
                          isCurrency: true,
                        ),
                        if (_parseAmount(_detailData!['discount']) > 0)
                          _buildSummaryRow(
                            'Diskon',
                            '- ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(_parseAmount(_detailData!['discount']))}',
                            isCurrency: false,
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
                        ), // dashed mimic skipped for simplicity
                        _buildSummaryRow(
                          'Uang Tunai',
                          _detailData!['money_paid'],
                          isCurrency: true,
                        ),
                        _buildSummaryRow(
                          'Kembalian',
                          _detailData!['change_money'],
                          isCurrency: true,
                          isBlue: true,
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Total Bayar',
                          _detailData!['amount'],
                          isCurrency: true,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
          ),
          if (_detailData != null) ...[
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final raw = _detailData?['raw']?.toString() ?? "";
                      print('Raw data to share : ${_detailData!['raw']}');
                      if (raw.isNotEmpty) {
                        _shareToWhatsApp(raw);
                      }
                    },
                    icon: Icon(
                      PhosphorIcons.whatsapp_logo_fill,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Bagikan ke WhatsApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [
                    if (statusTransactionSuccess.contains(
                      _detailData!['isPaid'],
                    ))
                      UniposButtonStatus(
                        variant: UniposButtonStatusVariant.danger,
                        hierarchy: UniposButtonStatusHierarchy.secondary,
                        icon: PhosphorIcons.trash_simple_fill,
                        textShow: false,
                        onTap: () {
                          if (_detailData == null ||
                              _detailData!['transactionid'] == null) {
                            showSnackbar(context, {
                              'rc': '99',
                              'message': 'ID Transaksi belum dimuat',
                            });
                            return;
                          }
                          context
                              .read<TransactionHistoryDeleteReasonsProvider>()
                              .fetchDeleteListReasons(
                                _detailData!['transactionid'].toString(),
                                widget.token,
                              );
                          ModalTransactionDelete.show(
                            context,
                            _detailData,
                            widget.token,
                          ).then((success) {
                            if (success == true) {
                              Navigator.pop(context, true); // Menutup detail modal, teruskan true ke hal utama!
                            }
                          });
                        },
                      ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {}, // Print Logic
                        icon: Icon(Icons.print, color: primary500),
                        label: Text(
                          'Cetak Struk',
                          style: TextStyle(
                            color: primary500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary500),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _shareToWhatsApp(String text) async {
    final uri = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback to web link if app not installed
      final webUri = Uri.parse(
        "https://wa.me/?text=${Uri.encodeComponent(text)}",
      );
      // print('Launching web WhatsApp URL: $webUri');
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
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
    print('Product item: $item');
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
      decoration: BoxDecoration(
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
                Row(
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp. ',
                        decimalDigits: 0,
                      ).format(
                        _parseAmount(item['price_after'] ?? item['price']),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item['discount_type'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(_parseAmount(item['price'])),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                if (variantTexts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Catatan : ${variantTexts.join(', ')}',
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
