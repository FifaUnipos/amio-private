import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/atoms/unipos_information.dart';
import 'package:unipos_app_335/providers/transactions/history/view_deleted_history_provider.dart';
import 'package:unipos_app_335/providers/transactions/transaction_provider.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/status_transaction.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/services/config/apimethod.dart';
import 'package:unipos_app_335/pageMobile/transaksiMobile/history/modal_view_deleted_history.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_list_reasons_provider.dart';
import 'package:unipos_app_335/pageMobile/transaksiMobile/history/modal_delete.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button_status.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/utilities.dart';

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
  // Sorting State
  String _selectedSortText = "Riwayat Terbaru";
  String _selectedSortTag = "upDownCreate";

  final sortOptions = [
    {"label": "Riwayat Terbaru", "tag": "upDownCreate"},
    {"label": "Riwayat Terlama", "tag": "downUpCreate"},
    {"label": "Nama Pembeli A ke Z", "tag": "upDownName"},
    {"label": "Nama Pembeli Z ke A", "tag": "downUpName"},
    {"label": "Total Tertinggi", "tag": "downUpAmount"},
    {"label": "Total Terendah", "tag": "upDownAmount"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  void _fetchHistory() {
    context.read<TransactionProvider>().fetchHistory(
      token: widget.token,
      merchantId: widget.merchantId,
      orderBy: _selectedSortTag,
    );
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
                children: List.generate(sortOptions.length, (index) {
                  final label = sortOptions[index]["label"]!;
                  final tag = sortOptions[index]["tag"]!;
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
    final transactionProvider = context.watch<TransactionProvider>();
    final historyList = transactionProvider.historyList;
    final isLoading = transactionProvider.isLoadingHistory;

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
                  _outlineBtn('Total : ${historyList.length}'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading && historyList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : historyList.isEmpty
              ? const Center(child: Text("Belum ada riwayat transaksi"))
              : ListView.separated(
                  itemCount: historyList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showDetail(item.transactionId),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      : statusTransactionProcessCancel.contains(
                                          item.isPaid,
                                        )
                                      ? UniposInformationVariant.warning
                                      : UniposInformationVariant.success,
                                  text: '${item.statusTransactions ?? '-'}',
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
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  String _pickStr(
    Map<String, dynamic> m,
    List<String> keys, {
    String fallback = '-',
  }) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return fallback;
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final s = value.toString().replaceAll(',', '').trim();
    return double.tryParse(s) ?? 0.0;
  }

  double _pickAmount(Map<String, dynamic> m, List<String> keys) {
    final s = _pickStr(m, keys, fallback: '0');
    return _parseAmount(s);
  }

  bool _isZeroDate(String s) => s.trim().isEmpty || s == '0000-00-00 00:00:00';

  void _fetchDetail() {
    context.read<TransactionProvider>().fetchTransactionDetail(
      token: widget.token,
      merchantId: widget.merchantId,
      transactionId: widget.transactionId,
    );
  }

  Future<dynamic> _showBottomRiwayatPerubahan(Map<String, dynamic> data) {
    return showModalBottomSheet(
      // constraints: const BoxConstraints(maxWidth: double.infinity),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: FutureBuilder(
            future: transaksiViewReference(
              context,
              widget.token,
              _pickStr(data, [
                'transactionid',
                'transaction_id',
              ], fallback: widget.transactionId),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final dataPerubahan = snapshot.data['data'];
                final detail = dataPerubahan['detail'] ?? [];

                bool isDropdownOpen = false;
                bool isApproving = false;

                return StatefulBuilder(
                  builder: (context, setStateModal) => Container(
                    margin: EdgeInsets.only(top: size32),
                    padding: EdgeInsets.fromLTRB(
                      size32,
                      size16,
                      size32,
                      size32,
                    ),
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size12),
                        topLeft: Radius.circular(size12),
                      ),
                    ),
                    child: Column(
                      children: [
                        dividerShowdialog(),
                        SizedBox(height: size16),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat Perubahan',
                                style: heading1(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              Text(
                                'Rincian riwayat perubahan transaksi',
                                style: heading4(
                                  FontWeight.w400,
                                  bnw500,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size32),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setStateModal(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: size16),
                            padding: EdgeInsets.symmetric(
                              vertical: size12,
                              horizontal: size16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size16),
                              border: Border.all(color: bnw300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: size8,
                                          horizontal: size12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            size8,
                                          ),
                                          color: danger100,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Pengisian Terakhir',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: size16),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size12,
                                                vertical: size8,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      size8,
                                                    ),
                                                color: danger500,
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  dataPerubahan['estimate'] ??
                                                      '-',
                                                  style: heading3(
                                                    FontWeight.w400,
                                                    bnw100,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: size12),
                                    Icon(
                                      PhosphorIcons.caret_down,
                                      color: bnw900,
                                      size: size24,
                                    ),
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(
                                    top: isDropdownOpen ? size16 : 0,
                                  ),
                                  child: isDropdownOpen
                                      ? Column(
                                          children: [
                                            Container(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height /
                                                  2,
                                              width: double.infinity,
                                              padding: EdgeInsets.all(size16),
                                              decoration: BoxDecoration(
                                                color: bnw200,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      size16,
                                                    ),
                                              ),
                                              child: ListView(
                                                padding: EdgeInsets.zero,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                children: [
                                                  Text(
                                                    'Status Transaksi',
                                                    style: heading3(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size12),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child:
                                                        buttonStatusTransaksi(
                                                          data,
                                                        ),
                                                  ),
                                                  SizedBox(height: size16),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Informasi Transaksi',
                                                        style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Waktu Tagihan',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                'Nomor Tagihan',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                'Kasir',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                'Alasan Batal',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                dataPerubahan['entrydate'] ??
                                                                    '-',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                dataPerubahan['transactionid'] ??
                                                                    '-',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                dataPerubahan['pic'] ??
                                                                    '-',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                dataPerubahan['reference']['alasan_reference'] ??
                                                                    '-',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: size16),
                                                      Text(
                                                        'Detail Alasan',
                                                        style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Wrap(
                                                        children: [
                                                          for (final paragraph
                                                              in (dataPerubahan['reference']['detail_alasan_reference'] ??
                                                                      '')
                                                                  .split('\n'))
                                                            Text(
                                                              paragraph,
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      SizedBox(height: size16),
                                                      Text(
                                                        'Rincian Produk',
                                                        style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              detail.length,
                                                          itemBuilder: (context, index) {
                                                            return SizedBox(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'x${detail[index]['quantity']}',
                                                                        style: heading3(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw900,
                                                                          'Outfit',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            size8,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            size48,
                                                                        width:
                                                                            size48,
                                                                        child: AspectRatio(
                                                                          aspectRatio:
                                                                              1,
                                                                          child: Container(
                                                                            child: Image.network(
                                                                              detail[index]['product_image'],
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder:
                                                                                  (
                                                                                    context,
                                                                                    error,
                                                                                    stackTrace,
                                                                                  ) => SvgPicture.asset(
                                                                                    'assets/logoProduct.svg',
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            size8,
                                                                      ),
                                                                      Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            detail[index]['name'] ??
                                                                                '-',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              bnw900,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            FormatCurrency.convertToIdr(
                                                                              detail[index]['amount'] ??
                                                                                  '-',
                                                                            ).toString(),
                                                                            style: body1(
                                                                              FontWeight.w400,
                                                                              bnw900,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Catatan : ${detail[index]['description']}',
                                                                            style: body1(
                                                                              FontWeight.w400,
                                                                              bnw900,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Divider(),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            dataPerubahan['isApprove'] ==
                                                    'false'
                                                ? Column(
                                                    children: [
                                                      SizedBox(height: size16),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: GestureDetector(
                                                              onTap: () async {
                                                                if (isApproving)
                                                                  return;
                                                                setStateModal(
                                                                  () =>
                                                                      isApproving =
                                                                          true,
                                                                );
                                                                try {
                                                                  await approveReference(
                                                                    context,
                                                                    widget
                                                                        .token,
                                                                    data['transactionid'],
                                                                    'true',
                                                                  );
                                                                  if (!mounted)
                                                                    return;
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        'Pembatalan disetujui',
                                                                      ),
                                                                    ),
                                                                  );
                                                                  setStateModal(() {
                                                                    dataPerubahan['isApprove'] =
                                                                        'true';
                                                                    data['status_transactions'] =
                                                                        'Pembatalan Tagihan Disetujui';
                                                                    data['is_color'] =
                                                                        '1';
                                                                  });
                                                                } catch (e) {
                                                                  if (!mounted)
                                                                    return;
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                        'Gagal approve: $e',
                                                                      ),
                                                                    ),
                                                                  );
                                                                } finally {
                                                                  if (mounted) {
                                                                    setStateModal(
                                                                      () => isApproving =
                                                                          false,
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                              child: isApproving
                                                                  ? SizedBox(
                                                                      height:
                                                                          size48,
                                                                      child: Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      ),
                                                                    )
                                                                  : buttonXL(
                                                                      Center(
                                                                        child: Text(
                                                                          'Setuju',
                                                                          style: heading2(
                                                                            FontWeight.w600,
                                                                            bnw100,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      double
                                                                          .infinity,
                                                                    ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size16,
                                                          ),
                                                          Expanded(
                                                            child: GestureDetector(
                                                              onTap: () async {
                                                                if (isApproving)
                                                                  return;
                                                                setStateModal(
                                                                  () =>
                                                                      isApproving =
                                                                          true,
                                                                );
                                                                try {
                                                                  approveReference(
                                                                    context,
                                                                    widget
                                                                        .token,
                                                                    data['transactionid'],
                                                                    'false',
                                                                  );
                                                                  if (!mounted)
                                                                    return;
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        'Pembatalan tidak disetujui',
                                                                      ),
                                                                    ),
                                                                  );
                                                                  setStateModal(() {
                                                                    dataPerubahan['isApprove'] =
                                                                        'true';
                                                                    data['status_transactions'] =
                                                                        'Pembatalan Tagihan Tidak Disetujui';
                                                                    data['is_color'] =
                                                                        '2';
                                                                  });
                                                                } catch (e) {
                                                                  if (!mounted)
                                                                    return;
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                        'Gagal approve: $e',
                                                                      ),
                                                                    ),
                                                                  );
                                                                } finally {
                                                                  if (mounted)
                                                                    setStateModal(
                                                                      () => isApproving =
                                                                          false,
                                                                    );
                                                                }
                                                              },
                                                              child: isApproving
                                                                  ? SizedBox(
                                                                      height:
                                                                          size48,
                                                                      child: Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      ),
                                                                    )
                                                                  : buttonXLoutline(
                                                                      Center(
                                                                        child: Text(
                                                                          'Tidak Setuju',
                                                                          style: heading2(
                                                                            FontWeight.w600,
                                                                            danger500,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      double
                                                                          .infinity,
                                                                      danger500,
                                                                    ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        )
                                      : SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        );
      },
    );
  }

  Widget buttonStatusTransaksi(Map<String, dynamic> data) {
    final colorCode = _pickStr(data, [
      'status_color',
      'is_color',
    ], fallback: '3');
    final statusText = _pickStr(data, [
      'status_transactions',
      'status_transaction',
      'status',
    ], fallback: '-');

    Color bg;
    Color fg;

    if (colorCode == '1') {
      bg = succes100;
      fg = succes500;
    } else if (colorCode == '2') {
      bg = danger100;
      fg = danger500;
    } else {
      bg = waring100;
      fg = waring500;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              statusText,
              overflow: TextOverflow.ellipsis,
              style: body1(FontWeight.w400, fg, 'Outfit'),
            ),
          ),
          Icon(PhosphorIcons.info_fill, color: fg, size: size24),
        ],
      ),
    );
  }

  @override
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
            child: isLoading && detail == null
                ? const Center(child: CircularProgressIndicator())
                : detail == null
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
                                    variant: statusTransactionCancel.contains(
                                      detail.isPaid,
                                    )
                                    ? UniposInformationVariant.danger
                                    : statusTransactionProcessCancel.contains(
                                        detail.isPaid,
                                      )
                                    ? UniposInformationVariant.warning
                                    : UniposInformationVariant.success,
                                    text: '${detail.statusTransactions ?? '-'}',
                                  ),
                                ),
                                if (statusTransactionCancel.contains(
                                      detail.isPaid,
                                    ) ||
                                    statusTransactionProcessCancel.contains(
                                      detail.isPaid,
                                    ))
                                  UniposButton(
                                    text: 'Lihat Riwayat',
                                    variant: UniposButtonVariant.tertiary,
                                    onTap: () {
                                      context
                                          .read<TransactionViewDeletedHistoryProvider>()
                                          .fetchViewDeletedHistory(
                                            widget.token,
                                            detail.transactionId,
                                            widget.merchantId,
                                          );

                                      ModalTransactionViewDeletedHistory.show(
                                        context,
                                        detail.fullData,
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
                            _buildInfoRow('Nomor Transaksi', '#${detail.transactionId}'),
                            _buildInfoRow('Nama Pembeli', detail.customer ?? 'Walking Customer'),
                            _buildInfoRow('Kasir', detail.pic ?? '-'),
                            const Text(
                              'Rincian Pesanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(height: 1),
                            if (detail.detailProducts != null)
                              ...detail.detailProducts!.map((item) {
                                return _buildProductItem(item.toJson());
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
                              detail.paymentName ?? '-',
                            ),
                            _buildSummaryRow(
                              'Sub Total',
                              detail.totalBeforeDscTax,
                              isCurrency: true,
                            ),
                            if (detail.discount > 0)
                              _buildSummaryRow(
                                'Diskon',
                                '- ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(detail.discount)}',
                                isCurrency: false,
                              ),
                            if (detail.ppn > 0)
                              _buildSummaryRow(
                                'PPN',
                                detail.ppn,
                                isCurrency: true,
                              ),
                            const Divider(
                              height: 24,
                              thickness: 1,
                            ),
                            _buildSummaryRow(
                              'Uang Tunai',
                              detail.moneyPaid,
                              isCurrency: true,
                            ),
                            _buildSummaryRow(
                              'Kembalian',
                              detail.changeMoney,
                              isCurrency: true,
                              isBlue: true,
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              'Total Bayar',
                              detail.amount,
                              isCurrency: true,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final raw = detail.raw ?? "";
                      print('Raw data to share : $raw');
                      if (raw.isNotEmpty) {
                        // _shareToWhatsApp(raw);
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
                      detail.isPaid,
                    ))
                      UniposButtonStatus(
                        variant: UniposButtonStatusVariant.danger,
                        hierarchy: UniposButtonStatusHierarchy.secondary,
                        icon: PhosphorIcons.trash_simple_fill,
                        textShow: false,
                        onTap: () {
                          context
                              .read<TransactionHistoryDeleteReasonsProvider>()
                              .fetchDeleteListReasons(
                                detail.transactionId,
                                widget.token,
                              );
                          ModalTransactionDelete.show(
                            context,
                            detail.fullData,
                            widget.token,
                          ).then((success) {
                            if (success == true) {
                              Navigator.pop(context, true);
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

  // double _parseAmount(dynamic value) {
  //   if (value == null) return 0.0;
  //   return double.tryParse(value.toString()) ?? 0.0;
  // }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
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
    final qty = _pickStr(item, ['quantity'], fallback: '1');
    final name = _pickStr(item, ['name'], fallback: '-');
    final image = _pickStr(item, ['product_image'], fallback: '');
    final note = _pickStr(item, ['description'], fallback: '').trim();

    final price = _parseAmount(item['price'] ?? item['price_after'] ?? 0);

    final variants = item['variants'] as List? ?? [];
    final List<String> variantTexts = [];
    for (final v in variants) {
      if (v is Map && v['variant_products'] is List) {
        for (final vp in (v['variant_products'] as List)) {
          if (vp is Map) {
            final vn = vp['variant_product_name']?.toString();
            if (vn != null && vn.isNotEmpty) variantTexts.add(vn);
          }
          // variantTexts.add(vp['variant_product_name']);
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
          Text('x$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  name,
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
                  ).format(price),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (variantTexts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Varian: ${variantTexts.join(',')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                if (note.isEmpty && note != '-')
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Catatan: $note',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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

                // if (variantTexts.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 4.0),
                //     child: Text(
                //       'Catatan : ${variantTexts.join(', ')}',
                //       style: const TextStyle(fontSize: 12, color: Colors.grey),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
