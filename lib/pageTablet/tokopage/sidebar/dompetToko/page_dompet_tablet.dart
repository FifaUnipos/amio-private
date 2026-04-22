import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/dompetToko/tarik_saldo_tablet.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:flutter/services.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  STATUS STYLE (shared)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SS {
  final Color bg, fg;
  final String label;
  const _SS(this.bg, this.fg, this.label);
}

_SS _ss(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'completed':
    case 'selesai':
      return _SS(const Color(0xFFDCFCE7), const Color(0xFF16A34A), 'Selesai');
    case 'pending':
    case 'menunggu':
      return _SS(const Color(0xFFFEF9C3), const Color(0xFFD97706), 'Menunggu');
    case 'approved':
    case 'disetujui':
      return _SS(const Color(0xFFDBEAFE), const Color(0xFF2563EB), 'Disetujui');
    case 'failed':
    case 'gagal':
      return _SS(const Color(0xFFFEE2E2), const Color(0xFFDC2626), 'Gagal');
    case 'rejected':
    case 'ditolak':
      return _SS(const Color(0xFFFEE2E2), const Color(0xFFDC2626), 'Ditolak');
    default:
      return _SS(bnw200, bnw600, s ?? '-');
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  PAGE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class PageDompetTablet extends StatefulWidget {
  final String token;
  const PageDompetTablet({Key? key, required this.token}) : super(key: key);

  @override
  State<PageDompetTablet> createState() => _PageDompetTabletState();
}

class _PageDompetTabletState extends State<PageDompetTablet> {
  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _isLoading = true;
  Map<String, dynamic>? _walletData;
  bool _showTarikSaldo = false;

  bool _merchantExpanded = true;
  bool _riwayatExpanded = true;

  final _merchantSearchCtrl = TextEditingController();
  final _riwayatSearchCtrl = TextEditingController();
  String _merchantQ = '';
  String _riwayatQ = '';
  String _selectedStatus = 'Semua Status';

  // Withdrawal list + pagination
  bool _riwayatLoading = false;
  List<dynamic> _withdrawals = [];
  int _currentPage = 1;
  static const int _pageSize = 8;

  static const List<String> _statusOptions = [
    'Semua Status',
    'Menunggu',
    'Disetujui',
    'Selesai',
    'Ditolak',
    'Gagal',
  ];
  static const Map<String, String?> _statusKey = {
    'Semua Status': null,
    'Menunggu': 'pending',
    'Disetujui': 'approved',
    'Selesai': 'completed',
    'Ditolak': 'rejected',
    'Gagal': 'failed',
  };

  final _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp\u00A0',
    decimalDigits: 0,
  );
  final _dateFmt = DateFormat('dd MMM yyyy', 'id_ID');

  // â”€â”€ URLs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String get _walletUrl => '$url/api/wallet';
  String get _walletSingleUrl => '$url/api/wallet/single';
  String get _withdrawUrl => '$url/api/wallet/withdraw';
  String get _withdrawSingleUrl => '$url/api/wallet/withdraw/single';

  // â”€â”€ Lifecycle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  void initState() {
    super.initState();
    _fetchWallet();
    _fetchWithdrawals();
  }

  @override
  void dispose() {
    _merchantSearchCtrl.dispose();
    _riwayatSearchCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ API â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _fetchWallet() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse(_walletUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({'search': '', 'order_by': ''}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['rc'] == '00') {
        setState(() => _walletData = json['data']);
      }
    } catch (e) {
      debugPrint('fetchWallet error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchWithdrawals() async {
    setState(() => _riwayatLoading = true);
    try {
      final res = await http.post(
        Uri.parse(_withdrawUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({'search': _riwayatQ, 'order_by': 'upDownCreate'}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['rc'] == '00') {
        setState(() {
          _withdrawals = (json['data'] as List<dynamic>?) ?? [];
          _currentPage = 1;
        });
      } else {
        setState(() => _withdrawals = []);
      }
    } catch (e) {
      debugPrint('fetchWithdrawals error: $e');
      setState(() => _withdrawals = []);
    } finally {
      setState(() => _riwayatLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchWalletSingle(String merchantId) async {
    try {
      final res = await http.post(
        Uri.parse(_walletSingleUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({'merchant_id': merchantId}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['rc'] == '00') return json['data'];
    } catch (e) {
      debugPrint('fetchWalletSingle error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchWithdrawSingle(
    String payoutBatchId,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(_withdrawSingleUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({'payout_batch_id': payoutBatchId}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['rc'] == '00') return json['data'];
    } catch (e) {
      debugPrint('fetchWithdrawSingle error: $e');
    }
    return null;
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _c(dynamic v) {
    final n = double.tryParse(v?.toString() ?? '0') ?? 0;
    return _fmt.format(n);
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      return _dateFmt.format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  List<dynamic> get _filteredWallets {
    final w = (_walletData?['wallets'] as List<dynamic>?) ?? [];
    if (_merchantQ.isEmpty) return w;
    return w
        .where(
          (e) => (e['merchant_name'] ?? '').toString().toLowerCase().contains(
            _merchantQ.toLowerCase(),
          ),
        )
        .toList();
  }

  List<dynamic> get _filteredWithdrawals {
    var raw = _withdrawals;
    if (_selectedStatus != 'Semua Status') {
      raw = raw
          .where(
            (e) => _ss(e['payout_status']?.toString()).label == _selectedStatus,
          )
          .toList();
    }
    if (_riwayatQ.isNotEmpty) {
      raw = raw
          .where(
            (e) => (e['payout_batch_id'] ?? '')
                .toString()
                .toLowerCase()
                .contains(_riwayatQ.toLowerCase()),
          )
          .toList();
    }
    return raw;
  }

  List<dynamic> get _pagedWithdrawals {
    final list = _filteredWithdrawals;
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, list.length);
    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  int get _totalPages =>
      ((_filteredWithdrawals.length) / _pageSize).ceil().clamp(1, 999);

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  MODALS  (reuse same modal structure)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _showMerchantDetail(Map<String, dynamic> wallet) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              height: double.infinity,
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: _MerchantDetailDialog(
                token: widget.token,
                wallet: wallet,
                fetchSingle: _fetchWalletSingle,
                formatCurrency: _c,
                formatDate: _fmtDate,
                statusStyle: _ss,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  void _showWithdrawDetail(Map<String, dynamic> item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              height: double.infinity,
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: _WithdrawDetailDialog(
                token: widget.token,
                item: item,
                fetchSingle: _fetchWithdrawSingle,
                formatCurrency: _c,
                formatDate: _fmtDate,
                statusStyle: _ss,
                onCancelSuccess: () {
                  _fetchWallet();
                  _fetchWithdrawals();
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  void _showStatusModal() {
    showBottomPilihan(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter Status',
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: bnw900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._statusOptions.map((s) {
            final isSelected = _selectedStatus == s;
            return InkWell(
              onTap: () {
                setState(() => _selectedStatus = s);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s,
                        style: body1(
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                          isSelected ? primary500 : bnw900,
                          'Outfit',
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: primary500, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  BUILD
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_showTarikSaldo) {
      final wallets = (_walletData?['wallets'] as List<dynamic>?) ?? [];
      final avail =
          double.tryParse(
            _walletData?['total_available_balance']?.toString() ?? '0',
          ) ??
          0;
      content = ClipRRect(
        borderRadius: BorderRadius.circular(size16),
        child: TarikSaldoTabletPage(
          token: widget.token,
          isGroupMerchant: wallets.length > 1,
          wallets: wallets,
          totalAvailable: avail,
          onSuccess: () {
            _fetchWallet();
            _fetchWithdrawals();
          },
          onBack: () => setState(() => _showTarikSaldo = false),
        ),
      );
    } else {
      content = _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ClipRRect(
              borderRadius: BorderRadius.circular(size16),
              child: Container(
                color: bnw200,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchWallet();
                    await _fetchWithdrawals();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                      SliverToBoxAdapter(
                        child: Container(
                          color: bnw100,
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dompet',
                                      style: heading1(
                                        FontWeight.w700,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      'Kelola saldo dan penarikan semua merchant',
                                      style: body1(
                                        FontWeight.w400,
                                        bnw500,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _showTarikSaldo = true);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Tarik Saldo',
                                  style: body1(
                                    FontWeight.w600,
                                    Colors.white,
                                    'Outfit',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary500,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // â”€â”€ 4 Summary Cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            children: [
                              _summaryCard(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2748C8),
                                    Color(0xFF4563E9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                icon: PhosphorIcons.wallet,
                                iconBg: Colors.white24,
                                iconFg: Colors.white,
                                title: 'Total Saldo',
                                value: _c(_walletData?['total_balance']),
                                titleColor: Colors.white70,
                                valueColor: Colors.white,
                                subtitle: "",
                              ),
                              const SizedBox(width: 12),
                              _summaryCard(
                                icon: PhosphorIcons.currency_circle_dollar,
                                iconBg: const Color(0xFFDCFCE7),
                                iconFg: const Color(0xFF16A34A),
                                title: 'Saldo Tersedia',
                                value: _c(
                                  _walletData?['total_available_balance'],
                                ),
                                subtitle: "",
                              ),
                              const SizedBox(width: 12),
                              _summaryCard(
                                icon: PhosphorIcons.clock,
                                iconBg: const Color(0xFFFFF7ED),
                                iconFg: const Color(0xFFD97706),
                                title: 'Penarikan Tertunda',
                                value: _c(
                                  _walletData?['total_pending_withdrawal'],
                                ),
                                subtitle:
                                    '${_walletData?['total_pending_count'] ?? 0} transaksi menunggu',
                              ),
                              const SizedBox(width: 12),
                              _summaryCard(
                                icon: PhosphorIcons.check_circle,
                                iconBg: const Color(0xFFEFF6FF),
                                iconFg: primary500,
                                title: 'Total Cair',
                                value: _c(
                                  _walletData?['total_withdraw_completed'],
                                ),
                                subtitle: 'Bulan ini',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // â”€â”€ Merchant Table Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                      SliverToBoxAdapter(child: _merchantTableSection()),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // â”€â”€ Withdrawal Table Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                      SliverToBoxAdapter(child: _riwayatTableSection()),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              ),
            );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size16),
            color: bnw100,
          ),
          child: content,
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ WIDGETS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _summaryCard({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String value,
    String? subtitle,
    Gradient? gradient,
    Color titleColor = const Color(0xFF6B7280),
    Color valueColor = const Color(0xFF111827),
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: gradient == null ? bnw100 : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: gradient == null ? Border.all(color: bnw200) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconFg, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: body2(FontWeight.w500, titleColor, 'Outfit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: heading3(FontWeight.w700, valueColor, 'Outfit')),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: body2(FontWeight.w400, titleColor, 'Outfit'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // â”€â”€ Merchant Table Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _merchantTableSection() {
    final wallets = _filteredWallets;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.storefront,
                    color: primary500,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dompet Merchant',
                        style: body1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Mengelola ${wallets.length} merchant',
                        style: body2(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${wallets.length} merchant',
                    style: body2(FontWeight.w600, primary500, 'Outfit'),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () =>
                      setState(() => _merchantExpanded = !_merchantExpanded),
                  child: Icon(
                    _merchantExpanded
                        ? PhosphorIcons.caret_up
                        : PhosphorIcons.caret_down,
                    color: bnw500,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          if (_merchantExpanded) ...[
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _searchField(
                _merchantSearchCtrl,
                'Cari nama merchant...',
                (v) => setState(() => _merchantQ = v),
              ),
            ),
            const SizedBox(height: 12),

            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: bnw200,
                border: Border.symmetric(horizontal: BorderSide(color: bnw300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'MERCHANT',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'SALDO',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'PENARIKAN TERTUNDA',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'SALDO TERSEDIA',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'AKTIVITAS TERAKHIR',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                ],
              ),
            ),

            if (wallets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Tidak ada data merchant',
                    style: body1(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                ),
              )
            else
              ...wallets.map((w) => _merchantTableRow(w)).toList(),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _merchantTableRow(Map<String, dynamic> w) {
    final img = w['merchant_image'];
    final name = (w['merchant_name'] ?? '-').toString();
    final id = (w['merchant_id'] ?? '').toString();
    final shortId = id.length > 24 ? '${id.substring(0, 24)}...' : id;

    return InkWell(
      onTap: () => _showMerchantDetail(w),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: bnw200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Merchant info
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: img != null && img.toString().isNotEmpty
                        ? Image.network(
                            img.toString(),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _avatar(name, size: 36),
                          )
                        : _avatar(name, size: 36),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: body1(FontWeight.w600, bnw900, 'Outfit'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: $shortId',
                          style: body2(FontWeight.w400, bnw400, 'Outfit'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _c(w['balance']),
                style: body1(FontWeight.w600, bnw900, 'Outfit'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                double.tryParse(w['pending_withdrawal']?.toString() ?? '0') == 0
                    ? '-'
                    : _c(w['pending_withdrawal']),
                style: body1(
                  FontWeight.w600,
                  const Color(0xFFD97706),
                  'Outfit',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _c(w['available_balance']),
                style: body1(
                  FontWeight.w600,
                  const Color(0xFF16A34A),
                  'Outfit',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _fmtDate(w['last_activity']?.toString()),
                style: body2(FontWeight.w400, bnw500, 'Outfit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Riwayat Table Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _riwayatTableSection() {
    final list = _pagedWithdrawals;
    final total = _filteredWithdrawals.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    PhosphorIcons.clock_counter_clockwise,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Penarikan',
                        style: body1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        '${_withdrawals.length} total penarikan',
                        style: body2(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_withdrawals.length} data',
                    style: body2(
                      FontWeight.w600,
                      const Color(0xFFD97706),
                      'Outfit',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () =>
                      setState(() => _riwayatExpanded = !_riwayatExpanded),
                  child: Icon(
                    _riwayatExpanded
                        ? PhosphorIcons.caret_up
                        : PhosphorIcons.caret_down,
                    color: bnw500,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          if (_riwayatExpanded) ...[
            // Search + filter row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _searchField(
                      _riwayatSearchCtrl,
                      'Cari ID penarikan...',
                      (v) => setState(() {
                        _riwayatQ = v;
                        _currentPage = 1;
                      }),
                      onSubmit: (_) => _fetchWithdrawals(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _showStatusModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: bnw300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedStatus,
                            style: body1(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: bnw600,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: bnw200,
                border: Border.symmetric(horizontal: BorderSide(color: bnw300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ID PENARIKAN',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'JUMLAH',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'BIAYA',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'JUMLAH BERSIH',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'PERMINTAAN',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  SizedBox(width: size12),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TANGGAL',
                      style: body2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                ],
              ),
            ),

            if (_riwayatLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Tidak ada riwayat penarikan',
                    style: body1(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                ),
              )
            else
              ...list
                  .map((item) => _riwayatTableRow(item as Map<String, dynamic>))
                  .toList(),

            // Pagination footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Menampilkan ${(_currentPage - 1) * _pageSize + 1} - ${((_currentPage - 1) * _pageSize + list.length)} dari $total penarikan',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  ),
                  Row(
                    children: [
                      _pgButton(
                        'Sebelumnya',
                        _currentPage > 1,
                        () => setState(() => _currentPage--),
                        isText: true,
                      ),
                      const SizedBox(width: 4),
                      ...List.generate(_totalPages.clamp(0, 5), (i) {
                        final page = i + 1;
                        final isActive = page == _currentPage;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _pgButton(
                            '$page',
                            true,
                            () => setState(() => _currentPage = page),
                            isActive: isActive,
                          ),
                        );
                      }),
                      if (_totalPages > 5) ...[
                        Text(
                          '...',
                          style: body2(FontWeight.w400, bnw500, 'Outfit'),
                        ),
                        const SizedBox(width: 4),
                      ],
                      _pgButton(
                        'Selanjutnya',
                        _currentPage < _totalPages,
                        () => setState(() => _currentPage++),
                        isText: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _riwayatTableRow(Map<String, dynamic> item) {
    final statusStyle = _ss(item['payout_status']);
    final id = (item['payout_batch_id'] ?? '').toString();
    final shortId = id.length > 18 ? '#${id.substring(0, 16)}...' : '#$id';
    final amount =
        double.tryParse(item['payout_total_amount']?.toString() ?? '0') ?? 0;
    final fee =
        double.tryParse(item['payout_total_fee']?.toString() ?? '0') ?? 0;
    final net = amount - fee;
    final requests = (item['payout_total_requests'].toString());

    return InkWell(
      onTap: () => _showWithdrawDetail(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: bnw200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                shortId,
                style: body2(FontWeight.w600, primary500, 'Outfit'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _c(amount),
                style: body1(FontWeight.w600, bnw900, 'Outfit'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _c(fee),
                style: body1(FontWeight.w400, bnw600, 'Outfit'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _c(net),
                style: body1(
                  FontWeight.w700,
                  const Color(0xFF16A34A),
                  'Outfit',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$requests req',
                  style: body2(FontWeight.w500, bnw700, 'Outfit'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: size12),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusStyle.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusStyle.fg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusStyle.label,
                      style: body2(FontWeight.w600, statusStyle.fg, 'Outfit'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size12),
            Expanded(
              flex: 2,
              child: Text(
                _fmtDate(item['payout_requested_at']?.toString()),
                style: body2(FontWeight.w400, bnw500, 'Outfit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Shared widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _avatar(String name, {double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary500.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'M',
          style: body1(FontWeight.w700, primary500, 'Outfit'),
        ),
      ),
    );
  }

  Widget _searchField(
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged, {
    ValueChanged<String>? onSubmit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bnw200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bnw300),
      ),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        onSubmitted: onSubmit,
        style: body1(FontWeight.w400, bnw900, 'Outfit'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: body1(FontWeight.w400, bnw400, 'Outfit'),
          prefixIcon: Icon(Icons.search, color: bnw400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _pgButton(
    String label,
    bool enabled,
    VoidCallback onTap, {
    bool isText = false,
    bool isActive = false,
  }) {
    if (isText) {
      return TextButton(
        onPressed: enabled ? onTap : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: bnw300),
          ),
          foregroundColor: enabled ? bnw900 : bnw400,
        ),
        child: Text(
          label,
          style: body2(FontWeight.w500, enabled ? bnw700 : bnw400, 'Outfit'),
        ),
      );
    }
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? primary500 : bnw100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? primary500 : bnw300),
        ),
        child: Text(
          label,
          style: body2(
            FontWeight.w600,
            isActive ? Colors.white : bnw700,
            'Outfit',
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  MERCHANT DETAIL DIALOG (Tablet uses Dialog instead of BottomSheet)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MerchantDetailDialog extends StatefulWidget {
  final String token;
  final Map<String, dynamic> wallet;
  final Future<Map<String, dynamic>?> Function(String) fetchSingle;
  final String Function(dynamic) formatCurrency;
  final String Function(String?) formatDate;
  final _SS Function(String?) statusStyle;

  const _MerchantDetailDialog({
    required this.token,
    required this.wallet,
    required this.fetchSingle,
    required this.formatCurrency,
    required this.formatDate,
    required this.statusStyle,
  });

  @override
  State<_MerchantDetailDialog> createState() => _MerchantDetailDialogState();
}

class _MerchantDetailDialogState extends State<_MerchantDetailDialog> {
  bool _loading = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await widget.fetchSingle(widget.wallet['merchant_id'] ?? '');
    if (mounted)
      setState(() {
        _detail = d;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.wallet['merchant_name'] ?? '-';
    final img = widget.wallet['merchant_image'];

    return SafeArea(
      child: Column(
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: bnw200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Dompet',
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: bnw600),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _detail == null
                ? Center(
                    child: Text(
                      'Gagal memuat data',
                      style: body1(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: img != null && img.toString().isNotEmpty
                                ? Image.network(
                                    img.toString(),
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _av(name),
                                  )
                                : _av(name),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: heading3(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  'ID: ${_detail!['merchant_id'] ?? '-'}',
                                  style: body2(FontWeight.w400, bnw500, 'Outfit'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2748C8), Color(0xFF4563E9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Saldo',
                                    style: body2(
                                      FontWeight.w500,
                                      Colors.white,
                                      'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.formatCurrency(_detail!['balance']),
                                    style: heading3(
                                      FontWeight.w700,
                                      Colors.white,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tersedia',
                                    style: body2(
                                      FontWeight.w500,
                                      const Color(0xFF16A34A),
                                      'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.formatCurrency(
                                      _detail!['available_balance'],
                                    ),
                                    style: heading3(
                                      FontWeight.w700,
                                      const Color(0xFF16A34A),
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((double.tryParse(
                                _detail!['pending_withdrawal']?.toString() ?? '0',
                              ) ??
                              0) >
                          0) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  PhosphorIcons.clock,
                                  color: Color(0xFFD97706),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saldo Tertunda',
                                      style: body2(
                                        FontWeight.w500,
                                        const Color(0xFFD97706),
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      widget.formatCurrency(
                                        _detail!['pending_withdrawal'],
                                      ),
                                      style: heading3(
                                        FontWeight.w700,
                                        const Color(0xFFD97706),
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Riwayat Transaksi',
                        style: heading3(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      const SizedBox(height: 12),
                      ...((_detail!['history'] as List<dynamic>?) ?? [])
                          .map((h) => _historyTile(h))
                          .toList(),
                      ...((_detail!['last_activity']) ?? '').isNotEmpty
                          ? [
                              SizedBox(height: size12),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIcons.clock,
                                    size: size24,
                                    color: bnw500,
                                  ),
                                  SizedBox(width: size12),
                                  Text(
                                    'Aktivitas terakhir: ${(_detail!['last_activity'])}',
                                    style: body2(
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          : [],
                      if (((_detail!['history'] as List<dynamic>?) ?? []).isEmpty)
                        Center(
                          child: Text(
                            'Belum ada riwayat',
                            style: body1(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _av(String name) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      color: primary500.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'M',
        style: heading2(FontWeight.w700, primary500, 'Outfit'),
      ),
    ),
  );

  Widget _historyTile(Map<String, dynamic> h) {
    final amount = h['amount'] ?? h['change'] ?? 0;
    final isPos = (double.tryParse(amount.toString()) ?? 0) >= 0;
    final amountStr = (isPos ? '+' : '') + widget.formatCurrency(amount);
    final type = h['type'] ?? h['activity_type'] ?? 'Update Saldo';
    final desc = h['description'] ?? h['note'] ?? '-';
    final date = h['created_at']?.toString() ?? h['date']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPos ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPos ? Icons.arrow_downward : Icons.arrow_upward,
              size: 14,
              color: isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.toString(),
                  style: body1(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(
                  desc.toString(),
                  style: body2(FontWeight.w400, bnw500, 'Outfit'),
                ),
                Text(
                  date ?? '',
                  style: body2(FontWeight.w400, bnw400, 'Outfit'),
                ),
              ],
            ),
          ),
          Text(
            amountStr,
            style: body1(
              FontWeight.w700,
              isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  WITHDRAW DETAIL DIALOG
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _WithdrawDetailDialog extends StatefulWidget {
  final String token;
  final Map<String, dynamic> item;
  final Future<Map<String, dynamic>?> Function(String) fetchSingle;
  final String Function(dynamic) formatCurrency;
  final String Function(String?) formatDate;
  final _SS Function(String?) statusStyle;
  final VoidCallback onCancelSuccess;

  const _WithdrawDetailDialog({
    required this.token,
    required this.item,
    required this.fetchSingle,
    required this.formatCurrency,
    required this.formatDate,
    required this.statusStyle,
    required this.onCancelSuccess,
  });

  @override
  State<_WithdrawDetailDialog> createState() => _WithdrawDetailDialogState();
}

class _WithdrawDetailDialogState extends State<_WithdrawDetailDialog> {
  bool _loading = true;
  bool _isCanceling = false;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await widget.fetchSingle(
      widget.item['payout_batch_id']?.toString() ?? '',
    );
    if (mounted)
      setState(() {
        _detail = d;
        _loading = false;
      });
  }

  Future<void> _cancelWithdrawal() async {
    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: bnw300,
                      borderRadius: BorderRadius.circular(size16),
                    ),
                  ),
                ),
                SizedBox(height: size16),
                Text(
                  'Batalkan Penarikan?',
                  style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                ),
                SizedBox(height: size8),
                Text(
                  'Apakah Anda yakin ingin membatalkan permintaan penarikan ini?',
                  style: heading2(FontWeight.w400, bnw900, 'Outfit'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, false),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            border: Border.all(color: bnw400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Batal',
                            style: heading3(FontWeight.w600, bnw500, 'Outfit'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: primary500,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Ya, Batalkan',
                            style: heading3(
                              FontWeight.w600,
                              Colors.white,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isCanceling = true);
    try {
      final res = await http.post(
        // Assuming 'url' is available via apimethod.dart
        Uri.parse('$url/api/wallet/withdraw/delete'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({'payout_batch_id': widget.item['payout_batch_id']}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['rc'] == '00') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Penarikan berhasil dibatalkan.',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
          ),
        );
        final onCancel = widget.onCancelSuccess;
        if (mounted) {
          Navigator.pop(context); // Menutup sidebar form
        }
        onCancel(); // Langsung trigger refresh tanpa delay
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json['message'] ?? 'Gagal membatalkan penarikan.',
              style: const TextStyle(fontFamily: 'Outfit'),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terjadi kesalahan.',
            style: TextStyle(fontFamily: 'Outfit'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: bnw200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Penarikan',
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: bnw600),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _detail == null
                ? Center(
                    child: Text(
                      'Gagal memuat data',
                      style: body1(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _detail!;
    final ss = widget.statusStyle(d['payout_status']);
    final requests = (d['payout_requests'] as List<dynamic>?) ?? [];
    final amount =
        double.tryParse(d['payout_total_amount']?.toString() ?? '0') ?? 0;
    final fee = double.tryParse(d['payout_total_fee']?.toString() ?? '0') ?? 0;
    final net = amount - fee;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                PhosphorIcons.receipt,
                color: Color(0xFFD97706),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${d['payout_batch_id'] ?? '-'}',
                    style: heading3(FontWeight.w700, bnw900, 'Outfit'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Detail Penarikan',
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ss.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: ss.fg,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ss.label,
                    style: body1(FontWeight.w600, ss.fg, 'Outfit'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Summary card
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2748C8), Color(0xFF4563E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Penarikan',
                      style: body1(FontWeight.w500, Colors.white, 'Outfit'),
                    ),
                    Text(
                      widget.formatCurrency(amount),
                      style: body1(FontWeight.w700, Colors.white, 'Outfit'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Biaya Admin',
                      style: body1(FontWeight.w500, Colors.white, 'Outfit'),
                    ),
                    Text(
                      '-${widget.formatCurrency(fee)}',
                      style: body1(
                        FontWeight.w700,
                        const Color(0xFFFF8080),
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.white.withAlpha(60)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Diterima',
                      style: body1(FontWeight.w700, Colors.white, 'Outfit'),
                    ),
                    Text(
                      widget.formatCurrency(net),
                      style: heading3(
                        FontWeight.w700,
                        const Color(0xFF86EFAC),
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Status Proses',
          style: heading3(FontWeight.w700, bnw900, 'Outfit'),
        ),
        const SizedBox(height: 12),
        _progressTimeline(d),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Permintaan',
              style: heading3(FontWeight.w700, bnw900, 'Outfit'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${requests.length} permintaan',
                style: body2(FontWeight.w600, primary500, 'Outfit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...requests.map((r) => _requestTile(r as Map<String, dynamic>)),

        if (d['payout_status']?.toString().toLowerCase() == 'pending') ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCanceling ? null : _cancelWithdrawal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2),
                foregroundColor: const Color(0xFFDC2626),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                // border: Border.all(color: const Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: const Color(0xFFFCA5A5)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isCanceling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFDC2626),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Batalkan Penarikan',
                      style: body1(
                        FontWeight.w700,
                        const Color(0xFFDC2626),
                        'Outfit',
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _progressTimeline(Map<String, dynamic> d) {
    final statusRaw = (d['payout_status'] ?? '').toString().toLowerCase();

    final isPending = statusRaw == 'pending';
    final isApproved = statusRaw == 'approved';
    final isCompleted = statusRaw == 'completed';
    final isRejected =
        statusRaw == 'rejected' ||
        statusRaw == 'failed' ||
        statusRaw == 'canceled';

    final colorSuccess = const Color(0xFF16A34A);
    final colorPending = bnw300;
    final colorFail = const Color(0xFFDC2626);

    List<Widget> nodes = [];

    // Node 1: Diajukan
    nodes.add(
      _timeNode('Diajukan', d['payout_requested_at'], true, colorSuccess),
    );

    if (isRejected) {
      // Node 2: Ditolak/Batal (Langsung merah jika gagal)
      nodes.add(
        _timeNode(
          'Dibatalkan / Ditolak',
          d['payout_canceled_at'] ?? d['payout_requested_at'],
          true,
          colorFail,
          isLast: true,
        ),
      );
    } else {
      // Node 2: Disetujui
      bool step2Done = isApproved || isCompleted;
      nodes.add(
        _timeNode(
          'Disetujui',
          d['payout_approved_at'],
          step2Done,
          step2Done ? colorSuccess : colorPending,
        ),
      );

      // Node 3: Selesai
      bool step3Done = isCompleted;
      nodes.add(
        _timeNode(
          'Selesai',
          d['payout_completed_at'],
          step3Done,
          step3Done ? colorSuccess : colorPending,
          isLast: true,
        ),
      );
    }

    return Column(children: nodes);
  }

  Widget _timeNode(
    String title,
    dynamic dateRaw,
    bool isActive,
    Color color, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: isActive ? color : bnw200,
                  shape: BoxShape.circle,
                  border: isActive ? null : Border.all(color: bnw300),
                ),
                child: isActive
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? color : bnw200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: body1(
                      isActive ? FontWeight.w700 : FontWeight.w500,
                      isActive ? bnw900 : bnw500,
                      'Outfit',
                    ),
                  ),
                  if (dateRaw != null)
                    Text(
                      widget.formatDate(dateRaw.toString()),
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestTile(Map<String, dynamic> r) {
    final ss = widget.statusStyle(r['status']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bnw200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['destination_name'] ?? '-',
                      style: body1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      '${r['destination_code'] ?? ''} - ${r['destination_number'] ?? ''}',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ss.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ss.label,
                  style: body2(FontWeight.w600, ss.fg, 'Outfit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.formatCurrency(r['amount']),
            style: heading3(FontWeight.w700, bnw900, 'Outfit'),
          ),
        ],
      ),
    );
  }
}
