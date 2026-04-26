import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:unipos_app_335/pageMobile/pageDompetMobile/tarik_saldo_page.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
class PageDompetMobile extends StatefulWidget {
  final String token;
  const PageDompetMobile({Key? key, required this.token}) : super(key: key);

  @override
  State<PageDompetMobile> createState() => _PageDompetMobileState();
}

class _PageDompetMobileState extends State<PageDompetMobile> {
  // ── state ────────────────────────────────────────────────────────────
  bool _isLoading = true;
  Map<String, dynamic>? _walletData;

  bool _merchantExpanded = true;
  bool _riwayatExpanded = true;

  final _merchantSearchCtrl = TextEditingController();
  final _riwayatSearchCtrl = TextEditingController();
  String _merchantQ = '';
  String _riwayatQ = '';
  String _selectedStatus = 'Semua Status';

  // riwayat penarikan data
  bool _riwayatLoading = false;
  List<dynamic> _withdrawals = [];

  static const List<String> _statusOptions = [
    'Semua Status',
    'Menunggu',
    'Disetujui',
    'Selesai',
    'Ditolak',
    'Gagal',
  ];

  // status key → API payout_status value
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
  final _dateFmt = DateFormat('dd MMM yyyy, HH.mm', 'id_ID');

  // ── URLs ─────────────────────────────────────────────────────────────
  String get _walletUrl => '$url/api/wallet';
  String get _walletSingleUrl => '$url/api/wallet/single';
  String get _withdrawUrl => '$url/api/wallet/withdraw';
  String get _withdrawSingleUrl => '$url/api/wallet/withdraw/single';

  // ── lifecycle ─────────────────────────────────────────────────────────
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

  // ── API calls ─────────────────────────────────────────────────────────
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
      final filterBy = _statusKey[_selectedStatus];
      final res = await http.post(
        Uri.parse(_withdrawUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'search': _riwayatQ,
          'order_by': 'upDownCreate',
          'filter_by': filterBy,
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['rc'] == '00') {
        setState(() => _withdrawals = (json['data'] as List<dynamic>?) ?? []);
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
      String payoutBatchId) async {
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

  // ── helpers ───────────────────────────────────────────────────────────
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

  // return a Color pair [bg, fg] for a status string
  _StatusStyle _ss(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'completed':
      case 'selesai':
        return _StatusStyle(
            const Color(0xFFDCFCE7), const Color(0xFF16A34A), 'Selesai');
      case 'pending':
      case 'menunggu':
        return _StatusStyle(
            const Color(0xFFFEF9C3), const Color(0xFFD97706), 'Menunggu');
      case 'approved':
      case 'disetujui':
        return _StatusStyle(
            const Color(0xFFDBEAFE), const Color(0xFF2563EB), 'Disetujui');
      case 'failed':
      case 'gagal':
        return _StatusStyle(
            const Color(0xFFFEE2E2), const Color(0xFFDC2626), 'Gagal');
      case 'rejected':
      case 'ditolak':
        return _StatusStyle(
            const Color(0xFFFEE2E2), const Color(0xFFDC2626), 'Ditolak');
      default:
        return _StatusStyle(bnw200, bnw600, s ?? '-');
    }
  }

  List<dynamic> get _filteredWallets {
    final w = (_walletData?['wallets'] as List<dynamic>?) ?? [];
    if (_merchantQ.isEmpty) return w;
    return w
        .where((e) => (e['merchant_name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_merchantQ.toLowerCase()))
        .toList();
  }

  List<dynamic> get _filteredWithdrawals {
    var raw = _withdrawals;
    if (_selectedStatus != 'Semua Status') {
      raw = raw
          .where((e) => _ss(e['payout_status']?.toString()).label == _selectedStatus)
          .toList();
    }
    if (_riwayatQ.isNotEmpty) {
      raw = raw
          .where((e) => (e['payout_batch_id'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_riwayatQ.toLowerCase()))
          .toList();
    }
    return raw;
  }

  // ─────────────────────── MODALS ──────────────────────────────────────

  // Merchant detail modal (gambar 2)
  void _showMerchantDetail(Map<String, dynamic> wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _MerchantDetailModal(
          token: widget.token,
          wallet: wallet,
          fetchSingle: _fetchWalletSingle,
          formatCurrency: _c,
          formatDate: _fmtDate,
          statusStyle: _ss,
        );
      },
    );
  }

  // Withdraw detail modal
  void _showWithdrawDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _WithdrawDetailModal(
          token: widget.token,
          item: item,
          fetchSingle: _fetchWithdrawSingle,
          formatCurrency: _c,
          formatDate: _fmtDate,
          statusStyle: _ss,
        );
      },
    );
  }

  // Status picker modal (gambar 2 dari deskripsi asli)
  void _showStatusModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
                  ..._statusOptions.map((s) {
                    final isSelected = _selectedStatus == s;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedStatus = s);
                        Navigator.pop(modalCtx);
                        _fetchWithdrawals();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s,
                                style: body1(
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  isSelected ? primary500 : bnw900,
                                  'Outfit',
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check, color: primary500, size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // ────────────────────── BUILD ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: bnw900, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dompet', style: heading2(FontWeight.w700, bnw900, 'Outfit')),
            Text(
              'Kelola saldo dan penarikan semua merchant',
              style: body2(FontWeight.w400, bnw500, 'Outfit'),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                final wallets = (_walletData?['wallets'] as List<dynamic>?) ?? [];
                final avail = double.tryParse(
                    _walletData?['total_available_balance']?.toString() ?? '0') ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TarikSaldoPage(
                      token: widget.token,
                      isGroupMerchant: wallets.length > 1,
                      wallets: wallets,
                      totalAvailable: avail,
                      onSuccess: () {
                        _fetchWallet();
                        _fetchWithdrawals();
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text('Tarik Saldo',
                  style: body2(FontWeight.w600, Colors.white, 'Outfit')),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary500,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchWallet();
                await _fetchWithdrawals();
              },
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _totalSaldoCard(),
                    const SizedBox(height: 12),
                    _infoRow(),
                    const SizedBox(height: 12),
                    _merchantSection(),
                    const SizedBox(height: 12),
                    _riwayatSection(),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Total saldo card ─────────────────────────────────────────────────
  Widget _totalSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2748C8), Color(0xFF4563E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child:
                    const Icon(PhosphorIcons.wallet, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text('Total Saldo',
                  style: body1(FontWeight.w500, Colors.white, 'Outfit')),
            ],
          ),
          const SizedBox(height: 14),
          Text(_c(_walletData?['total_balance']),
              style: heading1(FontWeight.w700, Colors.white, 'Outfit')),
        ],
      ),
    );
  }

  // ─── Info row (3 cards) ───────────────────────────────────────────────
  Widget _infoRow() {
    return Column(
      children: [
        _infoCard(
          icon: PhosphorIcons.currency_circle_dollar,
          iconBg: const Color(0xFFDCFCE7),
          iconFg: const Color(0xFF16A34A),
          title: 'Saldo Tersedia',
          value: _c(_walletData?['total_available_balance']),
        ),
        const SizedBox(height: 10),
        _infoCard(
          icon: PhosphorIcons.clock,
          iconBg: const Color(0xFFFFF7ED),
          iconFg: const Color(0xFFD97706),
          title: 'Penarikan Tertunda',
          value: _c(_walletData?['total_pending_withdrawal']),
          subtitle:
              '${_walletData?['total_pending_withdrawal'] ?? 0} transaksi menunggu',
        ),
        const SizedBox(height: 10),
        _infoCard(
          icon: PhosphorIcons.check_circle,
          iconBg: const Color(0xFFEFF6FF),
          iconFg: primary500,
          title: 'Total Cair',
          value: _c(_walletData?['total_withdraw_completed']),
          subtitle: 'Bulan ini',
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconFg, size: 16),
            ),
            const SizedBox(width: 10),
            Text(title, style: body1(FontWeight.w500, bnw600, 'Outfit')),
          ]),
          const SizedBox(height: 10),
          Text(value, style: heading2(FontWeight.w700, bnw900, 'Outfit')),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: body2(FontWeight.w400, bnw500, 'Outfit')),
          ],
        ],
      ),
    );
  }

  // ─── Merchant section ─────────────────────────────────────────────────
  Widget _merchantSection() {
    final wallets = _filteredWallets;
    return Container(
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          InkWell(
            onTap: () =>
                setState(() => _merchantExpanded = !_merchantExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(PhosphorIcons.storefront,
                      color: primary500, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dompet Merchant',
                          style: body1(FontWeight.w700, bnw900, 'Outfit')),
                      Text('Mengelola ${wallets.length} merchant',
                          style: body2(FontWeight.w400, bnw500, 'Outfit')),
                    ],
                  ),
                ),
                Icon(
                  _merchantExpanded
                      ? PhosphorIcons.caret_up
                      : PhosphorIcons.caret_down,
                  color: bnw600,
                  size: 20,
                ),
              ]),
            ),
          ),
          if (_merchantExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _searchField(
                _merchantSearchCtrl,
                'Cari nama merchant...',
                (v) => setState(() => _merchantQ = v),
              ),
            ),
            if (wallets.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  child: Text('Tidak ada data merchant',
                      style: body1(FontWeight.w400, bnw500, 'Outfit')),
                ),
              )
            else
              ...wallets.map((w) => _merchantTile(w)).toList(),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _merchantTile(Map<String, dynamic> w) {
    final img = w['merchant_image'];
    final name = (w['merchant_name'] ?? '-').toString();
    final balance = _c(w['balance']);
    final available = _c(w['available_balance']);
    final pending = _c(w['pending_withdrawal']);
    final lastAct = _fmtDate(w['last_activity']?.toString());

    return InkWell(
      onTap: () => _showMerchantDetail(w),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bnw200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: img != null && img.toString().isNotEmpty
                  ? Image.network(img.toString(),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatar(name))
                  : _avatar(name),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: body1(FontWeight.w700, bnw900, 'Outfit'),
                      overflow: TextOverflow.ellipsis),
                  Text(
                    (w['merchant_id'] ?? '').toString(),
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _miniRow('Saldo', balance, bnw900),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(child: _miniRow('Tersedia', available, const Color(0xFF16A34A))),
                      Expanded(child: _miniRow('Tertunda', pending, const Color(0xFFD97706))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(lastAct,
                      style: body3(FontWeight.w400, bnw400, 'Outfit')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String name) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
          color: primary500.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'M',
          style: heading2(FontWeight.w700, primary500, 'Outfit'),
        ),
      ),
    );
  }

  Widget _miniRow(String label, String value, Color color) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$label: ',
              style: body2(FontWeight.w400, bnw500, 'Outfit')),
          TextSpan(text: value, style: body2(FontWeight.w700, color, 'Outfit')),
        ],
      ),
    );
  }

  // ─── Riwayat section ──────────────────────────────────────────────────
  Widget _riwayatSection() {
    final list = _filteredWithdrawals;
    return Container(
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // header
          InkWell(
            onTap: () =>
                setState(() => _riwayatExpanded = !_riwayatExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(PhosphorIcons.clock_counter_clockwise,
                      color: Color(0xFFD97706), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riwayat Penarikan',
                          style: body1(FontWeight.w700, bnw900, 'Outfit')),
                      Text('${_withdrawals.length} total penarikan',
                          style: body2(FontWeight.w400, bnw500, 'Outfit')),
                    ],
                  ),
                ),
                Icon(
                  _riwayatExpanded
                      ? PhosphorIcons.caret_up
                      : PhosphorIcons.caret_down,
                  color: bnw600,
                  size: 20,
                ),
              ]),
            ),
          ),
          if (_riwayatExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _searchField(
                _riwayatSearchCtrl,
                'Cari ID penarikan...',
                (v) => setState(() => _riwayatQ = v),
                onSubmit: (_) => _fetchWithdrawals(),
              ),
            ),
            // status dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: InkWell(
                onTap: _showStatusModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: bnw300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(_selectedStatus,
                          style: body1(FontWeight.w400, bnw900, 'Outfit')),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: bnw600, size: 20),
                  ]),
                ),
              ),
            ),
            if (_riwayatLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (list.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12, horizontal: size16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.clock, size: 52, color: bnw300),
                    const SizedBox(height: 12),
                    Text('Tidak ada riwayat penarikan',
                        style: heading3(FontWeight.w600, bnw600, 'Outfit')),
                    const SizedBox(height: 4),
                    Text(
                      'Coba ubah filter atau kata kunci pencarian',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...list.map((w) => _withdrawTile(w)).toList(),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _withdrawTile(Map<String, dynamic> item) {
    final statusStyle = _ss(item['payout_status']);
    final id = (item['payout_batch_id'] ?? '').toString();
    final shortId = id.length > 20 ? '#${id.substring(0, 10)}...' : '#$id';
    final amount = _c(item['payout_total_amount']);
    final fee    = _c(item['payout_total_fee']);
    final date   = _fmtDate(item['payout_requested_at']?.toString());

    return InkWell(
      onTap: () => _showWithdrawDetail(item),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                  child: Text(shortId,
                      style: body2(FontWeight.w600, bnw700, 'Outfit'),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusStyle.bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusStyle.label,
                      style: body2(
                          FontWeight.w600, statusStyle.fg, 'Outfit')),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _miniRow('Jumlah', amount, bnw900)),
                Expanded(
                    child: _miniRow('Biaya', '-$fee', const Color(0xFFDC2626))),
              ],
            ),
            const SizedBox(height: 4),
            _miniRow('Sisa', _c((double.tryParse(item['payout_total_amount'].toString()) ?? 0) - (double.tryParse(item['payout_total_fee'].toString()) ?? 0)), const Color(0xFF16A34A)),
            const SizedBox(height: 4),
            Text(date, style: body2(FontWeight.w400, bnw400, 'Outfit')),
          ],
        ),
      ),
    );
  }

  // ─── search field ─────────────────────────────────────────────────────
  Widget _searchField(
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged, {
    ValueChanged<String>? onSubmit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bnw100,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATUS STYLE
// ─────────────────────────────────────────────────────────────────────────────
class _StatusStyle {
  final Color bg;
  final Color fg;
  final String label;
  const _StatusStyle(this.bg, this.fg, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MERCHANT DETAIL MODAL
// ─────────────────────────────────────────────────────────────────────────────
class _MerchantDetailModal extends StatefulWidget {
  final String token;
  final Map<String, dynamic> wallet;
  final Future<Map<String, dynamic>?> Function(String) fetchSingle;
  final String Function(dynamic) formatCurrency;
  final String Function(String?) formatDate;
  final _StatusStyle Function(String?) statusStyle;

  const _MerchantDetailModal({
    required this.token,
    required this.wallet,
    required this.fetchSingle,
    required this.formatCurrency,
    required this.formatDate,
    required this.statusStyle,
  });

  @override
  State<_MerchantDetailModal> createState() => _MerchantDetailModalState();
}

class _MerchantDetailModalState extends State<_MerchantDetailModal> {
  bool _loading = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await widget.fetchSingle(widget.wallet['merchant_id'] ?? '');
    setState(() {
      _detail = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.wallet['merchant_name'] ?? '-';
    final img = widget.wallet['merchant_image'];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, sc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              // title
              Text('Detail Dompet',
                  style: heading2(FontWeight.w700, bnw900, 'Outfit')),
              const SizedBox(height: 2),
              Text('Informasi lengkap dompet merchant',
                  style: body1(FontWeight.w400, bnw500, 'Outfit')),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _detail == null
                        ? Center(
                            child: Text('Gagal memuat data',
                                style: body1(
                                    FontWeight.w400, bnw500, 'Outfit')))
                        : ListView(
                            controller: sc,
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            children: [
                              // merchant identity
                              Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: img != null &&
                                          img.toString().isNotEmpty
                                      ? Image.network(img.toString(),
                                          width: 52,
                                          height: 52,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _av(name))
                                      : _av(name),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: heading3(FontWeight.w700,
                                              bnw900, 'Outfit')),
                                      Text(
                                        'ID: ${_detail!['merchant_id'] ?? '-'}',
                                        style: body2(FontWeight.w400,
                                            bnw500, 'Outfit'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 16),
                              // saldo + tersedia row
                              Row(children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2748C8),
                                          Color(0xFF4563E9)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Icon(PhosphorIcons.wallet,
                                              color: Colors.white, size: 14),
                                          const SizedBox(width: 6),
                                          Text('Saldo',
                                              style: body2(
                                                  FontWeight.w500,
                                                  Colors.white,
                                                  'Outfit')),
                                        ]),
                                        const SizedBox(height: 8),
                                        Text(
                                            widget.formatCurrency(
                                                _detail!['balance']),
                                            style: heading3(FontWeight.w700,
                                                Colors.white, 'Outfit')),
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
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Icon(
                                              PhosphorIcons
                                                  .currency_circle_dollar,
                                              color:
                                                  const Color(0xFF16A34A),
                                              size: 14),
                                          const SizedBox(width: 6),
                                          Text('Tersedia',
                                              style: body2(
                                                  FontWeight.w500,
                                                  const Color(0xFF16A34A),
                                                  'Outfit')),
                                        ]),
                                        const SizedBox(height: 8),
                                        Text(
                                            widget.formatCurrency(
                                                _detail!['available_balance']),
                                            style: heading3(
                                                FontWeight.w700,
                                                const Color(0xFF16A34A),
                                                'Outfit')),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 20),
                              // History
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Riwayat Transaksi',
                                      style: heading3(FontWeight.w700,
                                          bnw900, 'Outfit')),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${(_detail!['history'] as List?)?.length ?? 0} transaksi',
                                      style: body2(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...((_detail!['history'] as List<dynamic>?) ??
                                      [])
                                  .map((h) => _historyTile(h))
                                  .toList(),
                              if (((_detail!['history'] as List<dynamic>?) ??
                                      [])
                                  .isEmpty)
                                Center(
                                    child: Text('Belum ada riwayat',
                                        style: body1(FontWeight.w400,
                                            bnw500, 'Outfit'))),
                              const SizedBox(height: 16),
                              // last activity
                              Row(children: [
                                Icon(PhosphorIcons.clock,
                                    size: 14, color: bnw400),
                                const SizedBox(width: 6),
                                Text(
                                  'Aktivitas terakhir: ${widget.formatDate(_detail!['last_activity']?.toString())}',
                                  style: body2(
                                      FontWeight.w400, bnw500, 'Outfit'),
                                ),
                              ]),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _av(String name) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
          color: primary500.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'M',
          style: heading2(FontWeight.w700, primary500, 'Outfit'),
        ),
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> h) {
    final amount = h['amount'] ?? h['change'] ?? 0;
    final isPos = (double.tryParse(amount.toString()) ?? 0) >= 0;
    final amountStr =
        (isPos ? '+' : '') + widget.formatCurrency(amount);
    final type = h['type'] ?? h['activity_type'] ?? 'Update Saldo';
    final desc = h['description'] ?? h['note'] ?? '-';
    final date = widget.formatDate(h['created_at']?.toString() ?? h['date']?.toString());
    final balance = h['balance_after'] ?? h['balance'] ?? h['balance_now'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: isPos
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle),
            child: Icon(
              isPos ? Icons.arrow_downward : Icons.arrow_upward,
              size: 14,
              color: isPos
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.toString(),
                    style: body1(FontWeight.w600, bnw900, 'Outfit')),
                Text(desc.toString(),
                    style: body2(FontWeight.w400, bnw500, 'Outfit')),
                Text(date,
                    style: body2(FontWeight.w400, bnw400, 'Outfit')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountStr,
                  style: body1(
                      FontWeight.w700,
                      isPos
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      'Outfit')),
              if (balance != null)
                Text('Saldo: ${widget.formatCurrency(balance)}',
                    style: body2(FontWeight.w400, bnw500, 'Outfit')),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WITHDRAW DETAIL MODAL
// ─────────────────────────────────────────────────────────────────────────────
class _WithdrawDetailModal extends StatefulWidget {
  final String token;
  final Map<String, dynamic> item;
  final Future<Map<String, dynamic>?> Function(String) fetchSingle;
  final String Function(dynamic) formatCurrency;
  final String Function(String?) formatDate;
  final _StatusStyle Function(String?) statusStyle;

  const _WithdrawDetailModal({
    required this.token,
    required this.item,
    required this.fetchSingle,
    required this.formatCurrency,
    required this.formatDate,
    required this.statusStyle,
  });

  @override
  State<_WithdrawDetailModal> createState() => _WithdrawDetailModalState();
}

class _WithdrawDetailModalState extends State<_WithdrawDetailModal> {
  bool _loading = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await widget.fetchSingle(
        widget.item['payout_batch_id']?.toString() ?? '');
    setState(() {
      _detail = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, sc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Detail Penarikan',
                  style: heading2(FontWeight.w700, bnw900, 'Outfit')),
              const SizedBox(height: 2),
              Text('Informasi lengkap permintaan penarikan',
                  style: body1(FontWeight.w400, bnw500, 'Outfit')),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _detail == null
                        ? Center(
                            child: Text('Gagal memuat data',
                                style: body1(
                                    FontWeight.w400, bnw500, 'Outfit')))
                        : _buildContent(sc),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController sc) {
    final d = _detail!;
    final ss = widget.statusStyle(d['payout_status']);
    final requests = (d['payout_requests'] as List<dynamic>?) ?? [];
    final amount = double.tryParse(d['payout_total_amount']?.toString() ?? '0') ?? 0;
    final fee = double.tryParse(d['payout_total_fee']?.toString() ?? '0') ?? 0;
    final net = amount - fee;

    return ListView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        // ── Batch ID header row ─────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(PhosphorIcons.receipt,
                  color: Color(0xFFD97706), size: 22),
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
                  Text('Detail Penarikan',
                      style: body2(FontWeight.w400, bnw500, 'Outfit')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ── Status badge ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: ss.bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: ss.fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(ss.label, style: body1(FontWeight.w600, ss.fg, 'Outfit')),
          ]),
        ),
        const SizedBox(height: 16),
        // ── Summary card (blue) ───────────────────────────────────────
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
                    Text('Total Penarikan',
                        style: body1(FontWeight.w500, Colors.white, 'Outfit')),
                    Text(widget.formatCurrency(amount),
                        style: body1(FontWeight.w700, Colors.white, 'Outfit')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Biaya Admin',
                        style: body1(FontWeight.w500, Colors.white, 'Outfit')),
                    Text('-${widget.formatCurrency(fee)}',
                        style: body1(FontWeight.w700,
                            const Color(0xFFFF8080), 'Outfit')),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.white.withAlpha(60),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Diterima',
                        style: body1(FontWeight.w700, Colors.white, 'Outfit')),
                    Text(widget.formatCurrency(net),
                        style: heading3(FontWeight.w700,
                            const Color(0xFF86EFAC), 'Outfit')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Status Proses timeline ────────────────────────────────────
        Text('Status Proses', style: heading3(FontWeight.w700, bnw900, 'Outfit')),
        const SizedBox(height: 12),
        _timelineRow('Diajukan', d['payout_requested_at']),
        if (d['payout_approved_at'] != null)
          _timelineRow('Disetujui', d['payout_approved_at']),
        if (d['payout_completed_at'] != null)
          _timelineRow('Selesai', d['payout_completed_at']),
        if (d['payout_canceled_at'] != null)
          _timelineRow('Dibatalkan', d['payout_canceled_at'],
              color: const Color(0xFFDC2626)),
        if (d['payout_notes'] != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(d['payout_notes'].toString(),
                      style: body1(FontWeight.w400, bnw700, 'Outfit')),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        // ── Daftar Permintaan ─────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daftar Permintaan',
                style: heading3(FontWeight.w700, bnw900, 'Outfit')),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${requests.length} permintaan',
                  style: body2(FontWeight.w600, primary500, 'Outfit')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...requests
            .map((r) => _requestTile(r as Map<String, dynamic>)),
      ],
    );
  }

  Widget _timelineRow(String label, dynamic raw,
      {Color color = const Color(0xFF16A34A)}) {
    final val = widget.formatDate(raw?.toString());
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: body1(FontWeight.w600, bnw900, 'Outfit')),
          ),
          Text(val, style: body2(FontWeight.w400, bnw500, 'Outfit')),
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
                    Text(r['destination_name'] ?? '-',
                        style:
                            body1(FontWeight.w700, bnw900, 'Outfit')),
                    Text(
                      '${r['destination_code'] ?? ''} · ${r['destination_number'] ?? ''}',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                    Text(r['destination_type'] ?? '-',
                        style: body2(FontWeight.w400, bnw400, 'Outfit')),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ss.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(ss.label,
                    style: body2(FontWeight.w600, ss.fg, 'Outfit')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah',
                      style: body2(FontWeight.w400, bnw500, 'Outfit')),
                  Text(widget.formatCurrency(r['amount']),
                      style:
                          body1(FontWeight.w700, bnw900, 'Outfit')),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biaya',
                      style: body2(FontWeight.w400, bnw500, 'Outfit')),
                  Text('-${widget.formatCurrency(r['fee'])}',
                      style: body1(FontWeight.w700,
                          const Color(0xFFDC2626), 'Outfit')),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Diterima',
                      style: body2(FontWeight.w400, bnw500, 'Outfit')),
                  Text(widget.formatCurrency(r['net_amount']),
                      style: body1(FontWeight.w700,
                          const Color(0xFF16A34A), 'Outfit')),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(widget.formatDate(r['requested_at']?.toString()),
              style: body2(FontWeight.w400, bnw400, 'Outfit')),
        ],
      ),
    );
  }
}
