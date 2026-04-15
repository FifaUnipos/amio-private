import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

// ─── Static bank/ewallet list ─────────────────────────────────────────────────
class _BankOption {
  final String code;
  final String name;
  final bool isEwallet;
  const _BankOption(this.code, this.name, {this.isEwallet = false});
}

const List<_BankOption> _bankList = [
  _BankOption('BCA', 'Bank Central Asia (BCA)'),
  _BankOption('BRI', 'Bank Rakyat Indonesia (BRI)'),
  _BankOption('BNI', 'Bank Negara Indonesia (BNI)'),
  _BankOption('MANDIRI', 'Bank Mandiri'),
  _BankOption('BSI', 'Bank Syariah Indonesia (BSI)'),
  _BankOption('CIMB', 'CIMB Niaga'),
  _BankOption('PERMATA', 'Bank Permata'),
  _BankOption('BTN', 'Bank Tabungan Negara (BTN)'),
  _BankOption('DANAMON', 'Bank Danamon'),
  _BankOption('OCBC', 'OCBC NISP'),
  _BankOption('PANIN', 'Bank Panin'),
  _BankOption('MEGA', 'Bank Mega'),
  _BankOption('BUKOPIN', 'Bank Bukopin'),
  _BankOption('MAYBANK', 'Maybank Indonesia'),
  _BankOption('SINARMAS', 'Bank Sinarmas'),
  _BankOption('BJB', 'Bank Jabar Banten (BJB)'),
  _BankOption('BPD_DIY', 'Bank BPD DIY'),
  _BankOption('BPD_JATIM', 'Bank Jatim'),
  _BankOption('BPD_JATENG', 'Bank Jateng'),
  _BankOption('BPD_SUMUT', 'Bank Sumut'),
  _BankOption('GOPAY', 'GoPay', isEwallet: true),
  _BankOption('OVO', 'OVO', isEwallet: true),
  _BankOption('DANA', 'DANA', isEwallet: true),
  _BankOption('SHOPEEPAY', 'ShopeePay', isEwallet: true),
  _BankOption('LINKAJA', 'LinkAja', isEwallet: true),
  _BankOption('JENIUS', 'Jenius (BTPN)', isEwallet: true),
];

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
class TarikSaldoPage extends StatefulWidget {
  final String token;
  final bool isGroupMerchant;
  final List<dynamic> wallets; // list from api/wallet
  final double totalAvailable;
  final VoidCallback? onSuccess;

  const TarikSaldoPage({
    Key? key,
    required this.token,
    required this.isGroupMerchant,
    required this.wallets,
    required this.totalAvailable,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<TarikSaldoPage> createState() => _TarikSaldoPageState();
}

class _TarikSaldoPageState extends State<TarikSaldoPage> {
  // ── Source dana ──────────────────────────────────────────────────────
  final Set<String> _selectedWalletIds = {};

  double get _selectedBalance {
    if (_selectedWalletIds.isEmpty) return widget.totalAvailable;
    double total = 0;
    for (final w in widget.wallets) {
      if (_selectedWalletIds.contains(w['wallet_id']?.toString())) {
        total += double.tryParse(
                w['available_balance']?.toString() ?? '0') ??
            0;
      }
    }
    return total;
  }

  // ── Nominal ───────────────────────────────────────────────────────────
  final _amountCtrl = TextEditingController();
  double _amount = 0;
  double get _fee => _amount * 0.10;
  double get _net => _amount > 0 ? (_amount - _fee) : 0;

  final _fmt = NumberFormat('#,###', 'id_ID');
  final _fmtRp = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp\u00A0', decimalDigits: 0);

  void _setAmount(double v) {
    setState(() {
      _amount = v.clamp(0, _selectedBalance);
      _amountCtrl.text = _amount == 0 ? '' : _fmt.format(_amount.toInt());
    });
  }

  void _onAmountChanged(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(clean) ?? 0;
    setState(() => _amount = parsed.clamp(0, _selectedBalance));
  }

  // ── Tujuan transfer ───────────────────────────────────────────────────
  int _destTab = 0; // 0=Bank, 1=EWallet
  final _nameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  _BankOption? _selectedBank;

  String get _destType =>
      _destTab == 0 ? 'bank_account' : 'ewallet';

  List<_BankOption> get _filteredBanks =>
      _bankList.where((b) => b.isEwallet == (_destTab == 1)).toList();

  // ── submission ────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  String? _errorMsg;

  // ── formatting ────────────────────────────────────────────────────────
  String _rp(double v) => _fmtRp.format(v.toInt());

  bool get _canSubmit =>
      _amount > 0 &&
      _nameCtrl.text.trim().isNotEmpty &&
      _accountCtrl.text.trim().isNotEmpty &&
      _selectedBank != null &&
      !_isSubmitting;

  // ─── submit ───────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$url/api/wallet/withdraw/request'),
        headers: {
          'token': widget.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': _amount.toInt(),
          'destination_type': _destType,
          'destination_account_number': _accountCtrl.text.trim(),
          'destination_account_name': _nameCtrl.text.trim(),
          'destination_code': _selectedBank?.code ?? '',
        }),
      );

      final json = jsonDecode(res.body);

      if (json['rc'] == '00') {
        if (mounted) {
          widget.onSuccess?.call();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Penarikan berhasil diajukan!',
                  style: body1(FontWeight.w500, Colors.white, 'Outfit')),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      } else {
        // parse error detail
        final data = json['data'];
        final msg = json['message'] ?? 'Terjadi kesalahan';
        String detail = msg;
        if (data != null) {
          final avail = _rp(
              (double.tryParse(data['total_available_balance'].toString()) ?? 0));
          final need = _rp(
              (double.tryParse(data['total_required'].toString()) ?? 0));
          detail =
              '$msg\n\nTersedia: $avail\nDibutuhkan: $need';
        }
        setState(() => _errorMsg = detail);
      }
    } catch (e) {
      setState(() => _errorMsg = 'Koneksi gagal: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ─────────────────── BUILD ────────────────────────────────────────────
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
        title: Text('Request Penarikan',
            style: heading2(FontWeight.w700, bnw900, 'Outfit')),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // ── 1. Pilihan Sumber Dana (group merchant only) ──────
                  if (widget.isGroupMerchant) ...[
                    _sectionHeader(
                      '1. Pilihan Sumber Dana',
                      'Jika tidak dipilih, maka akan menggunakan semua dompet',
                      action: TextButton(
                        onPressed: () =>
                            setState(() => _selectedWalletIds.clear()),
                        child: Text('Reset Pilihan',
                            style:
                                body1(FontWeight.w600, primary500, 'Outfit')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.wallets.map((w) => _walletSelectTile(w)).toList(),
                    const SizedBox(height: 20),
                  ],
        
                  // ── 2. Nominal Penarikan ─────────────────────────────
                  _sectionHeader(
                    widget.isGroupMerchant
                        ? '2. Nominal Penarikan'
                        : '1. Nominal Penarikan',
                    null,
                  ),
                  const SizedBox(height: 10),
                  _amountCard(),
                  const SizedBox(height: 20),
        
                  // ── 3. Tujuan Transfer ───────────────────────────────
                  _sectionHeader(
                    widget.isGroupMerchant
                        ? '3. Tujuan Transfer'
                        : '2. Tujuan Transfer',
                    null,
                  ),
                  const SizedBox(height: 10),
                  _destCard(),
                  const SizedBox(height: 20),
        
                  // ── Summary ──────────────────────────────────────────
                  _summarySection(),
        
                  // ── Error ────────────────────────────────────────────
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_errorMsg!,
                                style: body1(FontWeight.w500,
                                    const Color(0xFFB91C1C), 'Outfit')),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // ── Bottom CTA ───────────────────────────────────────────────
            _bottomCta(),
          ],
        ),
      ),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────
  Widget _sectionHeader(String title, String? subtitle, {Widget? action}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: heading3(FontWeight.w700, bnw900, 'Outfit')),
              if (subtitle != null)
                Text(subtitle,
                    style: body2(FontWeight.w400, bnw500, 'Outfit')),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  // ─── Wallet select tile ───────────────────────────────────────────────
  Widget _walletSelectTile(Map<String, dynamic> w) {
    final id = w['wallet_id']?.toString() ?? '';
    final name = w['merchant_name'] ?? '-';
    final avail = double.tryParse(w['available_balance']?.toString() ?? '0') ?? 0;
    final isSelected = _selectedWalletIds.contains(id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedWalletIds.remove(id);
          } else {
            _selectedWalletIds.add(id);
          }
          // recalculate amount if it exceeds new max
          if (_amount > _selectedBalance) _setAmount(_selectedBalance);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : bnw100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary500 : bnw300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toString(),
                      style: body1(FontWeight.w700, bnw900, 'Outfit')),
                  Text('Saldo: ${_fmtRp.format(avail.toInt())}',
                      style: body2(FontWeight.w400, bnw500, 'Outfit')),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? primary500 : bnw200,
                shape: BoxShape.circle,
                border:
                    Border.all(color: isSelected ? primary500 : bnw400),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Amount card ──────────────────────────────────────────────────────
  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Masukan Nominal',
                  style: body1(FontWeight.w500, bnw600, 'Outfit')),
              GestureDetector(
                onTap: () => _setAmount(0),
                child: Icon(PhosphorIcons.arrow_counter_clockwise,
                    size: 20, color: bnw500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // big input row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rp',
                  style: heading1(FontWeight.w400, bnw400, 'Outfit')),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                  onChanged: _onAmountChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // quick buttons
          Row(
            children: [25, 50, 75].map((pct) {
              final v = _selectedBalance * pct / 100;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _setAmount(v),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primary500),
                    ),
                    child: Center(
                      child: Text('$pct%',
                          style: body1(FontWeight.w600, bnw900, 'Outfit')),
                    ),
                  ),
                ),
              );
            }).toList()
              ..add(Expanded(
                child: GestureDetector(
                  onTap: () => _setAmount(_selectedBalance),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primary500),
                    ),
                    child: Center(
                      child: Text('MAX',
                          style: body1(FontWeight.w600, primary500, 'Outfit')),
                    ),
                  ),
                ),
              )),
          ),
        ],
      ),
    );
  }

  // ─── Destination card ─────────────────────────────────────────────────
  Widget _destCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bank / ewallet toggle
          Container(
            decoration: BoxDecoration(
              color: bnw200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _tabButton(0, PhosphorIcons.bank, 'Bank'),
                _tabButton(1, PhosphorIcons.device_mobile, 'E-Wallet'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Name
          _formLabel('NAMA PEMILIK AKUN', required: true),
          const SizedBox(height: 6),
          _textField(
            _nameCtrl,
            'Contoh: ALEXANDER VANCE',
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          // Bank code picker
          _formLabel('KODE BANK / PROVIDER', required: true),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showBankPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: bnw300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedBank != null
                          ? '${_selectedBank!.code} - ${_selectedBank!.name}'
                          : 'Pilih / Cari...',
                      style: body1(
                        FontWeight.w400,
                        _selectedBank != null ? bnw900 : bnw400,
                        'Outfit',
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: bnw500, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Account number
          _formLabel('NOMOR REKENING / AKUN', required: true),
          const SizedBox(height: 6),
          _textField(
            _accountCtrl,
            '**** **** ****',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _tabButton(int index, IconData icon, String label) {
    final isSelected = _destTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _destTab = index;
          _selectedBank = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? bnw100 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: bnw900.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? bnw900 : bnw500),
              const SizedBox(width: 6),
              Text(
                label,
                style: body1(
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  isSelected ? bnw900 : bnw500,
                  'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text, style: body2(FontWeight.w700, bnw700, 'Outfit')),
        if (required)
          Text(' *',
              style: body2(FontWeight.w700, const Color(0xFFDC2626), 'Outfit')),
      ],
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: (_) => setState(() {}),
      style: body1(FontWeight.w400, bnw900, 'Outfit'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: body1(FontWeight.w400, bnw400, 'Outfit'),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: bnw300)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: primary500)),
        contentPadding: const EdgeInsets.only(bottom: 6),
      ),
    );
  }

  // ─── Bank picker modal ────────────────────────────────────────────────
  void _showBankPicker() {
    String q = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setModal) {
          final filtered = _filteredBanks
              .where((b) =>
                  b.name.toLowerCase().contains(q.toLowerCase()) ||
                  b.code.toLowerCase().contains(q.toLowerCase()))
              .toList();
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, sc) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
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
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _destTab == 0
                                ? 'Pilih Bank'
                                : 'Pilih E-Wallet',
                            style: heading2(
                                FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          const SizedBox(height: 12),
                          // search
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: bnw300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              onChanged: (v) =>
                                  setModal(() => q = v),
                              style: body1(
                                  FontWeight.w400, bnw900, 'Outfit'),
                              decoration: InputDecoration(
                                hintText: 'Cari...',
                                hintStyle: body1(FontWeight.w400,
                                    bnw400, 'Outfit'),
                                prefixIcon: Icon(Icons.search,
                                    color: bnw400, size: 20),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: sc,
                        padding: const EdgeInsets.fromLTRB(
                            20, 4, 20, 24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final b = filtered[i];
                          final isSelected =
                              _selectedBank?.code == b.code;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              setState(() => _selectedBank = b);
                              Navigator.pop(ctx);
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Icon(
                                b.isEwallet
                                    ? PhosphorIcons.device_mobile
                                    : PhosphorIcons.bank,
                                color: primary500,
                                size: 18,
                              ),
                            ),
                            title: Text(b.name,
                                style: body1(FontWeight.w600,
                                    bnw900, 'Outfit')),
                            subtitle: Text(b.code,
                                style: body2(FontWeight.w400,
                                    bnw500, 'Outfit')),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: primary500)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
      },
    );
  }

  // ─── Summary section ──────────────────────────────────────────────────
  Widget _summarySection() {
    return Column(
      children: [
        const Divider(),
        _summaryRow('Nominal Penarikan', _rp(_amount), bnw900),
        const SizedBox(height: 6),
        _summaryRow('Biaya Layanan', '-${_rp(_fee)}',
            const Color(0xFFDC2626)),
        const Divider(),
        _summaryRow(
          'Nominal Diterima',
          _rp(_net),
          primary500,
          bold: true,
          labelBold: true,
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor,
      {bool bold = false, bool labelBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: body1(
              labelBold ? FontWeight.w700 : FontWeight.w400, bnw700, 'Outfit'),
        ),
        Text(
          value,
          style: (bold ? heading3 : body1)(
              FontWeight.w700, valueColor, 'Outfit'),
        ),
      ],
    );
  }

  // ─── Bottom CTA ───────────────────────────────────────────────────────
  Widget _bottomCta() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: bnw100,
        boxShadow: [
          BoxShadow(
            color: bnw900.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _canSubmit ? _submit : null,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.verified_user_outlined,
                  color: Colors.white, size: 20),
          label: Text(
            _isSubmitting ? 'Memproses...' : 'Otorisasi Penarikan',
            style: heading3(FontWeight.w600, Colors.white, 'Outfit'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _canSubmit ? primary500 : bnw400,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }
}
