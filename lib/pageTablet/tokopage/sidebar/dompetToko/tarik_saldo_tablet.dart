import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

// â”€â”€â”€ Static bank/ewallet list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BankOption {
  final String code, name;
  final bool isEwallet;
  final String? image;
  _BankOption(this.code, this.name, {this.isEwallet = false, this.image});
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  TABLET TARIK SALDO PAGE  (2-column layout)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class TarikSaldoTabletPage extends StatefulWidget {
  final String token;
  final bool isGroupMerchant;
  final List<dynamic> wallets;
  final double totalAvailable;
  final VoidCallback? onSuccess;
  final VoidCallback? onBack;

  const TarikSaldoTabletPage({
    Key? key,
    required this.token,
    required this.isGroupMerchant,
    required this.wallets,
    required this.totalAvailable,
    this.onSuccess,
    this.onBack,
  }) : super(key: key);

  @override
  State<TarikSaldoTabletPage> createState() => _TarikSaldoTabletPageState();
}

class _TarikSaldoTabletPageState extends State<TarikSaldoTabletPage> {
  // â”€â”€ Source dana â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final Set<String> _selectedWalletIds = {};
  List<_BankOption> _bankList = [];
  bool _isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final res = await http.post(
        Uri.parse('$url/api/type/payment/references'),
        headers: {'Content-Type': 'application/json', 'token': widget.token},
        body: jsonEncode({"category": ""}),
      );
      final json = jsonDecode(res.body);
      if (json['rc'] == '00') {
        final List data = json['data'] ?? [];
        List<_BankOption> fetched = [];
        for (var item in data) {
           final cat = (item['paymentReferenceCategory'] ?? '').toString().toLowerCase();
           fetched.add(_BankOption(
             item['paymentReferenceName'] ?? '',
             item['paymentReferenceName'] ?? '',
             isEwallet: cat.contains('ewallet'),
             image: item['paymentReferenceImage'],
           ));
        }
        if (mounted) setState(() { _bankList = fetched; _isLoadingBanks = false; });
      } else {
        if (mounted) setState(() => _isLoadingBanks = false);
      }
    } catch(e) {
      if (mounted) setState(() => _isLoadingBanks = false);
    }
  }

  double get _selectedBalance {
    if (_selectedWalletIds.isEmpty) return widget.totalAvailable;
    double total = 0;
    for (final w in widget.wallets) {
      if (_selectedWalletIds.contains(w['wallet_id']?.toString())) {
        total += double.tryParse(w['available_balance']?.toString() ?? '0') ?? 0;
      }
    }
    return total;
  }

  // â”€â”€ Nominal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _amountCtrl = TextEditingController();
  double _amount = 0;
  double get _fee => _amount * 0.10;
  double get _net => _amount > 0 ? (_amount - _fee) : 0;

  final _fmt = NumberFormat('#,###', 'id_ID');
  final _fmtRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp\u00A0', decimalDigits: 0);

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

  // â”€â”€ Tujuan transfer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int _destTab = 0;
  final _nameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  _BankOption? _selectedBank;

  String get _destType => _destTab == 0 ? 'bank_account' : 'ewallet';
  List<_BankOption> get _filteredBanks => _bankList.where((b) => b.isEwallet == (_destTab == 1)).toList();

  // â”€â”€ Submission â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _isSubmitting = false;
  String? _errorMsg;

  String _rp(double v) => _fmtRp.format(v.toInt());

  bool get _canSubmit =>
      _amount > 0 &&
      _nameCtrl.text.trim().isNotEmpty &&
      _accountCtrl.text.trim().isNotEmpty &&
      _selectedBank != null &&
      !_isSubmitting;

  Future<void> _submit() async {
    setState(() { _isSubmitting = true; _errorMsg = null; });
    try {
      final res = await http.post(
        Uri.parse('$url/api/wallet/withdraw/request'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
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
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Penarikan berhasil diajukan!', style: body1(FontWeight.w500, Colors.white, 'Outfit')),
            backgroundColor: const Color(0xFF16A34A),
          ));
        }
      } else {
        final data = json['data'];
        final msg = json['message'] ?? 'Terjadi kesalahan';
        String detail = msg;
        if (data != null) {
          final avail = _rp(double.tryParse(data['total_available_balance'].toString()) ?? 0);
          final need = _rp(double.tryParse(data['total_required'].toString()) ?? 0);
          detail = '$msg\n\nTersedia: $avail\nDibutuhkan: $need';
        }
        setState(() => _errorMsg = detail);
      }
    } catch (e) {
      setState(() => _errorMsg = 'Koneksi gagal: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ BUILD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw200,
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: bnw900, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Request Penarikan', style: heading2(FontWeight.w700, bnw900, 'Outfit')),
          Text('Tarik saldo secara aman dari akun merchant ke rekening tujuan Anda.',
              style: body2(FontWeight.w400, const Color(0xFFD97706), 'Outfit')),
        ]),
        titleSpacing: 0,
      ),
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // â”€â”€ LEFT: scrollable form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
          flex: 6,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 40),
            children: [
              // 1. Pilihan Sumber Dana
              if (widget.isGroupMerchant) ...[
                _sectionHeader(
                  '1. Pilihan Sumber Dana',
                  'Jika tidak dipilih, maka akan menggunakan semua dompet',
                  action: TextButton(
                    onPressed: () => setState(() => _selectedWalletIds.clear()),
                    child: Text('Reset Pilihan', style: body1(FontWeight.w600, primary500, 'Outfit')),
                  ),
                ),
                const SizedBox(height: 12),
                // Grid layout for wallets on tablet (2 per row)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: widget.wallets.length,
                  itemBuilder: (_, i) => _walletSelectTile(widget.wallets[i]),
                ),
                const SizedBox(height: 24),
              ],

              // 2. Nominal Penarikan
              _sectionHeader(widget.isGroupMerchant ? '2. Nominal Penarikan' : '1. Nominal Penarikan', null),
              const SizedBox(height: 12),
              _amountCard(),
              const SizedBox(height: 24),

              // 3. Tujuan Transfer
              _sectionHeader(widget.isGroupMerchant ? '3. Tujuan Transfer' : '2. Tujuan Transfer', null),
              const SizedBox(height: 12),
              _destCard(),

              // Error
              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMsg!, style: body1(FontWeight.w500, const Color(0xFFB91C1C), 'Outfit'))),
                  ]),
                ),
              ],
            ],
          ),
        ),

        // â”€â”€ RIGHT: sticky summary card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                decoration: BoxDecoration(
                  color: bnw100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: bnw200),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('RINGKASAN REQUEST', style: body2(FontWeight.w700, bnw500, 'Outfit')),
                  const SizedBox(height: 16),
                  _summaryRow('Nominal Penarikan', _rp(_amount), bnw900),
                  const SizedBox(height: 10),
                  _summaryRow('Biaya Layanan', '-${_rp(_fee)}', const Color(0xFFDC2626)),
                  Divider(color: bnw200, height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Nominal\nDiterima', style: body1(FontWeight.w700, bnw900, 'Outfit')),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_rp(_net), style: heading3(FontWeight.w700, primary500, 'Outfit')),
                      Text('Estimasi Selesai: 1-2\nHari Kerja',
                          style: body2(FontWeight.w400, bnw500, 'Outfit'), textAlign: TextAlign.right),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? primary500 : bnw400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Kirim Request Penarikan',
                              style: body1(FontWeight.w600, Colors.white, 'Outfit'), textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dengan mengirim permintaan, Anda menyetujui Ketentuan Finansial dan menyetujui proses review.',
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // â”€â”€â”€ Widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _sectionHeader(String title, String? subtitle, {Widget? action}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: heading3(FontWeight.w700, bnw900, 'Outfit')),
        if (subtitle != null) Text(subtitle, style: body2(FontWeight.w400, bnw500, 'Outfit')),
      ])),
      if (action != null) action,
    ]);
  }

  Widget _walletSelectTile(Map<String, dynamic> w) {
    final id = w['wallet_id']?.toString() ?? '';
    final name = w['merchant_name'] ?? '-';
    final avail = double.tryParse(w['available_balance']?.toString() ?? '0') ?? 0;
    final isSelected = _selectedWalletIds.contains(id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) { _selectedWalletIds.remove(id); } else { _selectedWalletIds.add(id); }
          if (_amount > _selectedBalance) _setAmount(_selectedBalance);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : bnw100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primary500 : bnw300, width: isSelected ? 1.5 : 1),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.toString(), style: body1(FontWeight.w700, bnw900, 'Outfit')),
            Text('Saldo: ${_fmtRp.format(avail.toInt())}', style: body2(FontWeight.w400, bnw500, 'Outfit')),
          ])),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: isSelected ? primary500 : bnw200, shape: BoxShape.circle, border: Border.all(color: isSelected ? primary500 : bnw400)),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ]),
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bnw100, borderRadius: BorderRadius.circular(16), border: Border.all(color: bnw200)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Masukan Nominal', style: body1(FontWeight.w500, bnw600, 'Outfit')),
          GestureDetector(onTap: () => _setAmount(0), child: Icon(PhosphorIcons.arrow_counter_clockwise, size: 20, color: bnw500)),
        ]),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Rp', style: heading1(FontWeight.w400, bnw400, 'Outfit')),
          const SizedBox(width: 16),
          Expanded(child: TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
            decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: _onAmountChanged,
          )),
        ]),
        const SizedBox(height: 12),
        Divider(color: bnw300),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.info_outline, size: 14, color: bnw500),
          const SizedBox(width: 6),
          Text('Minimal: Rp 10.000', style: body2(FontWeight.w400, bnw500, 'Outfit')),
          const Spacer(),
          GestureDetector(
            onTap: () => _setAmount(_selectedBalance),
            child: Text('Tarik Semua Saldo', style: body1(FontWeight.w600, primary500, 'Outfit')),
          ),
        ]),
      ]),
    );
  }

  Widget _destCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bnw100, borderRadius: BorderRadius.circular(16), border: Border.all(color: bnw200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Bank/ewallet toggle
        Container(
          decoration: BoxDecoration(color: bnw200, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            _tabButton(0, PhosphorIcons.bank, 'Bank'),
            _tabButton(1, PhosphorIcons.device_mobile, 'E-Wallet'),
          ]),
        ),
        const SizedBox(height: 24),
        _formLabel('NAMA PEMILIK AKUN', required: true),
        const SizedBox(height: 8),
        _textField(_nameCtrl, 'Contoh: ALEXANDER VANCE', textCapitalization: TextCapitalization.characters),
        const SizedBox(height: 20),
        // Bank code + account number side by side on tablet
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _formLabel('KODE BANK / PROVIDER', required: true),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showBankPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: bnw300))),
                child: Row(children: [
                  Expanded(child: Text(
                    _selectedBank != null ? '${_selectedBank!.code} - ${_selectedBank!.name}' : 'Pilih / Cari...',
                    style: body1(FontWeight.w400, _selectedBank != null ? bnw900 : bnw400, 'Outfit'),
                  )),
                  Icon(Icons.keyboard_arrow_down, color: bnw500, size: 20),
                ]),
              ),
            ),
          ])),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _formLabel('NOMOR REKENING / AKUN', required: true),
            const SizedBox(height: 8),
            _textField(_accountCtrl, '**** **** 8829', keyboardType: TextInputType.number),
          ])),
        ]),
      ]),
    );
  }

  Widget _tabButton(int index, IconData icon, String label) {
    final isSelected = _destTab == index;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _destTab = index; _selectedBank = null; }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? bnw100 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: bnw900.withAlpha(20), blurRadius: 4, offset: const Offset(0, 1))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: isSelected ? bnw900 : bnw500),
          const SizedBox(width: 6),
          Text(label, style: body1(isSelected ? FontWeight.w600 : FontWeight.w400, isSelected ? bnw900 : bnw500, 'Outfit')),
        ]),
      ),
    ));
  }

  Widget _formLabel(String text, {bool required = false}) {
    return Row(children: [
      Text(text, style: body2(FontWeight.w700, bnw700, 'Outfit')),
      if (required) Text(' *', style: body2(FontWeight.w700, const Color(0xFFDC2626), 'Outfit')),
    ]);
  }

  Widget _textField(TextEditingController ctrl, String hint, {TextInputType? keyboardType, TextCapitalization textCapitalization = TextCapitalization.none}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: (_) => setState(() {}),
      style: body1(FontWeight.w400, bnw900, 'Outfit'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: body1(FontWeight.w400, bnw400, 'Outfit'),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: bnw300)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary500)),
        contentPadding: const EdgeInsets.only(bottom: 6),
      ),
    );
  }

  void _showBankPicker() {
    String q = '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setModal) {
        final filtered = _filteredBanks.where((b) =>
            b.name.toLowerCase().contains(q.toLowerCase()) || b.code.toLowerCase().contains(q.toLowerCase())).toList();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: SizedBox(
            width: 480,
            height: MediaQuery.of(ctx2).size.height * 0.65,
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 16, 12), child: Row(children: [
                Expanded(child: Text(_destTab == 0 ? 'Pilih Bank' : 'Pilih E-Wallet', style: heading2(FontWeight.w700, bnw900, 'Outfit'))),
                IconButton(icon: Icon(Icons.close, color: bnw600), onPressed: () => Navigator.pop(ctx)),
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: Container(
                decoration: BoxDecoration(border: Border.all(color: bnw300), borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  onChanged: (v) => setModal(() => q = v),
                  style: body1(FontWeight.w400, bnw900, 'Outfit'),
                  decoration: InputDecoration(
                    hintText: 'Cari...',
                    hintStyle: body1(FontWeight.w400, bnw400, 'Outfit'),
                    prefixIcon: Icon(Icons.search, color: bnw400, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              )),
              Expanded(child: _isLoadingBanks 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final b = filtered[i];
                  final isSelected = _selectedBank?.code == b.code;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () { setState(() => _selectedBank = b); Navigator.pop(ctx); },
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                      child: b.image != null && b.image!.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(b.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(b.isEwallet ? PhosphorIcons.device_mobile : PhosphorIcons.bank, color: primary500, size: 18)))
                          : Icon(b.isEwallet ? PhosphorIcons.device_mobile : PhosphorIcons.bank, color: primary500, size: 18),
                    ),
                    title: Text(b.name, style: body1(FontWeight.w600, bnw900, 'Outfit')),
                    subtitle: Text(b.code, style: body2(FontWeight.w400, bnw500, 'Outfit')),
                    trailing: isSelected ? Icon(Icons.check_circle, color: primary500) : null,
                  );
                },
              )),
            ]),
          ),
        );
      }),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: body1(FontWeight.w400, bnw700, 'Outfit')),
      Text(value, style: body1(FontWeight.w700, valueColor, 'Outfit')),
    ]);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }
}

