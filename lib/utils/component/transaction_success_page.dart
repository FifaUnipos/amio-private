import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:flutter/services.dart' as services;

class TransactionSuccessPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>>? localCart;

  const TransactionSuccessPage({Key? key, required this.data, this.localCart})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract values from data
    final String customerName = data['customer_name'] ?? '-';
    final String paymentMethod =
        data['payment_name'] ?? data['payment_method'] ?? '-';
    final String transactionId =
        data['transactionid']?.toString() ??
        '-'; // Using transactionid from response
    final String cashier = data['pic_name'] ?? '-';
    final List<dynamic> details = data['detail'] ?? [];

    final int subTotal =
        int.tryParse(data['total_before_dsc_tax'].toString()) ?? 0;
    final int ppn = int.tryParse(data['ppn'].toString()) ?? 0;
    final int totalPay = int.tryParse(data['amount'].toString()) ?? 0;
    final int discount = int.tryParse(data['discount'].toString()) ?? 0;
    final int cashGiven = int.tryParse(data['money_paid'].toString()) ?? 0;
    final int change = int.tryParse(data['change_money'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bnw100,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaksi Berhasil',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size16, vertical: size24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informasi Pesanan",
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size16),
                      _rowInfo("Nama Pembeli", customerName),
                      _rowInfo("Metode Pembayaran", paymentMethod),
                      _rowInfo(
                        "Nomor Pesanan",
                        transactionId,
                      ), // Updated to use real ID
                      _rowInfo("Kasir", cashier),
                      Divider(height: 32, thickness: 1),
                      Text(
                        "Rincian Pesanan",
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size16),
                      ...details.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        // Adapter for detail item
                        final String name =
                            item['shortname'] ?? item['name'] ?? 'Item';
                        final int qty =
                            int.tryParse(item['quantity'].toString()) ?? 0;
                        final int price =
                            int.tryParse(item['price'].toString()) ?? 0;
                        // notes might be in description or not present in this structure
                        final String notes =
                            item['description']?.toString() ?? '';

                        // Attempt to find variants from localCart
                        List<dynamic>? uiVariants;
                        if (localCart != null && index < localCart!.length) {
                          // Try to match basic properties if possible, or trust index
                          final localItem = localCart![index];
                          // Optional: check product name similarity?
                          // For now, index is safest assumption if flow is direct.
                          uiVariants = localItem['variants_ui'];
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: size12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "x$qty ",
                                style: heading2(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              SizedBox(width: size8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          name,
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp. ',
                                            decimalDigits: 0,
                                          ).format(
                                            int.tryParse(
                                                  item['amount']?.toString() ??
                                                      '0',
                                                ) ??
                                                price,
                                          ),
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item['discount_type'] != null)
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp. ',
                                          decimalDigits: 0,
                                        ).format(price),
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontFamily: 'Outfit',
                                          color: bnw500,
                                          fontSize: sp12,
                                        ),
                                      ),
                                    if (uiVariants != null &&
                                        uiVariants.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: uiVariants.map<Widget>((v) {
                                            return Text(
                                              "+ ${v['name']} (${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(v['amount'])})",
                                              style: heading4(
                                                FontWeight.w600,
                                                bnw600,
                                                'Outfit',
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    SizedBox(height: size12),
                                    if (notes.isNotEmpty)
                                      Text(
                                        "Catatan : $notes",
                                        style: heading4(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      Divider(height: 32, thickness: 1),
                      _rowInfo(
                        "Sub Total",
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(subTotal),
                      ),
                      _rowInfo(
                        "PPN",
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(ppn),
                      ),
                      if (discount > 0)
                        _rowInfo(
                          "Diskon",
                          "- ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(discount)}",
                        ),
                      Divider(height: 32, thickness: 1),
                      _rowInfo(
                        "Uang Tunai",
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(cashGiven),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kembalian",
                            style: TextStyle(color: primary500),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(change),
                            style: TextStyle(
                              color: primary500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Bayar",
                            style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(totalPay),
                            style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.print, color: bnw100),
                  label: Text(
                    "Cetak Struk",
                    style: TextStyle(
                      color: bnw100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primary500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                  child: Text(
                    "Kembali Ke Kasir",
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
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: size8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: heading3(FontWeight.w400, bnw900, 'Outfit')),
          Text(value, style: heading3(FontWeight.w600, bnw900, 'Outfit')),
        ],
      ),
    );
  }
}

class RupiahInputFormatter extends services.TextInputFormatter {
  final NumberFormat _nf = NumberFormat.decimalPattern('id');

  @override
  services.TextEditingValue formatEditUpdate(
    services.TextEditingValue oldValue,
    services.TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const services.TextEditingValue(
        text: '',
        selection: services.TextSelection.collapsed(offset: 0),
      );
    }
    final number = int.tryParse(digits) ?? 0;
    final formatted = _nf.format(number);

    return services.TextEditingValue(
      text: formatted,
      selection: services.TextSelection.collapsed(offset: formatted.length),
    );
  }
}
