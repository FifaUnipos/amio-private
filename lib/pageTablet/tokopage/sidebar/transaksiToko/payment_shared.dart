import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/utils/component/shared_qris_handler.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/transaksiToko/pesananPage.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/transaction_success_page.dart';
import 'package:unipos_app_335/services/websocket_service.dart';

dynamic blankToNull(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }
  return value;
}

bool asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase().trim();
  return s == 'true' || s == '1' || s == 'yes';
}

int asInt(dynamic v, {int fallback = 0}) {
  // if (v == null) return fallback;
  // if (v is int) return v;
  // if (v is double) return v.round();
  // if (v is num) return v.round();
  // final s = v.toString().trim();
  // return int.tryParse(s) ?? fallback;

  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.round();

  final s = v.toString().trim();
  if (s.isEmpty) return fallback;

  final parsedInt = int.tryParse(s);
  if (parsedInt != null) return parsedInt;

  return parseMoneyToInt(s);
}

double asDouble(dynamic v, {double def = 0}) {
  if (v == null) return def;
  return double.tryParse(v.toString()) ?? def;
}

String moneyString(dynamic v, {bool isThousandUnit = false}) {
  double n = asDouble(v);
  if (isThousandUnit) n = n * 1000;
  return n.toStringAsFixed(2);
}

int parseMoneyToInt(dynamic input) {
  if (input == null) return 0;
  if (input is int) return input;
  if (input is double) return input.round();
  if (input is num) return input.round();

  String s = input.toString().trim();
  if (s.isEmpty) return 0;
  s = s.replaceAll(RegExp(r'[^0-9\.,-]'), '');

  final dotCount = '.'.allMatches(s).length;
  final commaCount = ','.allMatches(s).length;

  if (dotCount >= 1 && commaCount >= 1) {
    final lastDot = s.lastIndexOf('.');
    final lastComma = s.lastIndexOf(',');
    if (lastComma > lastDot) {
      final normalized = s.replaceAll('.', '').replaceAll(',', '');
      return (double.tryParse(normalized) ?? 0).round();
    } else {
      final normalized = s.replaceAll(',', '');
      return (double.tryParse(normalized) ?? 0).round();
    }
  }
  if (dotCount > 1 && commaCount == 0) {
    final normalized = s.replaceAll(',', '');
    return int.tryParse(normalized.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }
  if (commaCount > 1 && dotCount == 0) {
    final normalized = s.replaceAll(',', '');
    return int.tryParse(normalized.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
  if (dotCount == 1 && commaCount == 0) {
    final parts = s.split('.');
    final frac = parts.length == 2 ? parts[1] : '';
    if (frac.length == 3) {
      final normalized = parts[0] + frac;
      return int.tryParse(normalized.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
    }
    return (double.tryParse(s) ?? 0).round();
  }
  if (commaCount == 1 && dotCount == 0) {
    final parts = s.split(',');
    final frac = parts.length == 2 ? parts[1] : '';
    if (frac.length == 3) {
      final normalized = parts[0] + frac;
      return int.tryParse(normalized.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
    }
    return (double.tryParse(s.replaceAll(',', '.')) ?? 0).round();
  }

  final digits = s.replaceAll(RegExp(r'[^0-9-]'), '');
  return int.tryParse(digits) ?? 0;
}

String toAmountString(dynamic input) {
  final v = parseMoneyToInt(input);
  return "$v.00";
}

dynamic safeJsonDecode(dynamic raw) {
  if (raw == null) return null;
  if (raw is List || raw is Map) return raw;

  if (raw is String) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }
  return null;
}

int parseIdr(String s) =>
    int.tryParse(s.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
Map<String, dynamic>? readPaymentSummaryMap(Map<String, dynamic> data) {
  final summary = data['payment_summary'];
  if (summary is Map) {
    return Map<String, dynamic>.from(summary);
  }
  return null;
}

List<Map<String, dynamic>> readPaymentFromResponse(Map<String, dynamic> data) {
  final raw = data['payments'];
  if (raw is! List) return [];

  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

class SplitLine {
  String methodCode;
  String methodLabel;
  String? paymentReferenceId;
  final TextEditingController amountCon;

  SplitLine({
    required this.methodCode,
    required this.methodLabel,
    required this.amountCon,
    this.paymentReferenceId,
  });
}

// String? transactionidValue;
// bool isTagihan = false;

int totalTagihanAwal = 0;
int totalSudahDibayar = 0;
int sisaTagihan = 0;

String? discountIdFix;
String discountNameFix = '';

final List<SplitLine> splitLines = [
  SplitLine(
    methodCode: '',
    methodLabel: '',
    amountCon: TextEditingController(text: ''),
  ),
];

int activeSplitIndex = 0;
bool splitShowKeypad = false;
int paymentTypeIndex = 0;

bool get hasActiveInstallment => isTagihan && sisaTagihan > 0;

int get currentDueNominal =>
    hasActiveInstallment ? sisaTagihan : asInt(totalTransaksi);

int readTotalDue(Map<String, dynamic> data) {
  final summary = readPaymentSummaryMap(data);

  if (summary != null) {
    final totalDue = asInt(summary['total_due'], fallback: -1);
    if (totalDue >= 0) return totalDue;
  }

  return asInt(data['amount']);
}

int readTotalPaid(Map<String, dynamic> data) {
  final summary = readPaymentSummaryMap(data);

  if (summary != null) {
    final totalPaid = asInt(summary['total_paid'], fallback: -1);
    if (totalPaid >= 0) return totalPaid;

    final prev = asInt(summary['previous_payment'], fallback: -1);
    if (prev >= 0) return prev;
  }
  return asInt(data['money_paid'] ?? data['moneyPaid']);
}

int readOutStandingAfter(Map<String, dynamic> data) {
  final summary = readPaymentSummaryMap(data);

  if (summary != null) {
    final outStandingAfter = asInt(summary['outstanding_after'], fallback: -1);
    if (outStandingAfter >= 0) return outStandingAfter;

    final outStandingBefore = asInt(
      summary['outstanding_before'],
      fallback: -1,
    );
    if (outStandingBefore >= 0) return outStandingBefore;
  }

  if (data.containsKey('sisa_tagihan')) {
    return asInt(data['sisa_tagihan']);
  }

  if (data.containsKey('outstanding')) {
    return asInt(data['outstanding']);
  }

  if (data.containsKey('remaining_payment')) {
    return asInt(data['remaining_payment']);
  }

  final totalDue = readTotalDue(data);
  final totalPaid = readTotalPaid(data);
  final remain = totalDue - totalPaid;
  return remain < 0 ? 0 : remain;
}

void hydratePaymentSummaryFromData(
  Map<String, dynamic> data, {
  bool treatAsOpenBill = false,
}) {
  final summary = readPaymentSummaryMap(data);

  final rawTx = blankToNull(data['transactionid'] ?? data['transaction_id']);

  final hasTransactionId = rawTx != null;

  transactionidValue = rawTx?.toString();

  final rawDiscount = blankToNull(data['discountid']);
  discountIdFix = rawDiscount?.toString();

  if (discountIdFix == null || discountIdFix!.isEmpty) {
    discountNameFix = '';
  }

  subTotal = asInt(data['total_before_dsc_tax']);
  ppnTransaksi = asInt(data['ppn']);
  discountProduct = asInt(data['discount']);
  discountProductUmum = asInt(data['discount_umum']);
  namaCustomerCalculate = (data['customer_name'] ?? data['customer'] ?? '')
      .toString();

  totalTagihanAwal = readTotalDue(data);
  totalSudahDibayar = readTotalPaid(data);
  sisaTagihan = readOutStandingAfter(data);

  totalTransaksi = sisaTagihan > 0 ? sisaTagihan : totalTagihanAwal;

  final isFullyPaid = summary != null
      ? asBool(summary['is_fully_paid'])
      : sisaTagihan <= 0;

  isTagihan =
      treatAsOpenBill ||
      (hasTransactionId && (!isFullyPaid || sisaTagihan > 0));

  if (isTagihan) {
    paymentTypeIndex = 1;
  }

  debugPrint(
    "HYDRATE totalTagihanAwal=$totalTagihanAwal totalSudahDibayar=$totalSudahDibayar sisaTagihan=$sisaTagihan totalTransaksi=$totalTransaksi isTagihan=$isTagihan",
  );
}

void resetSplitPaymentState() {
  if (splitLines.isEmpty) {
    splitLines.add(
      SplitLine(
        methodCode: '',
        methodLabel: '',
        amountCon: TextEditingController(text: ''),
      ),
    );
  }

  final first = splitLines.first;
  final extras = splitLines.skip(1).toList();

  first.methodCode = '';
  first.methodLabel = '';
  first.paymentReferenceId = null;
  first.amountCon.clear();

  splitLines
    ..clear()
    ..add(first);

  for (final extra in extras) {
    extra.amountCon.dispose();
  }

  activeSplitIndex = 0;
  splitShowKeypad = false;
}

void resetPaymentSummaryState() {
  transactionidValue = null;
  isTagihan = false;
  selectedTagihanData = null;

  totalTagihanAwal = 0;
  totalSudahDibayar = 0;
  sisaTagihan = 0;

  discountIdFix = null;
  discountNameFix = '';

  paymentTypeIndex = 0;

  subTotal = 0;
  ppnTransaksi = 0;
  discountProduct = 0;
  discountProductUmum = 0;
  totalTransaksi = 0;
  namaCustomerCalculate = '';

  resetSplitPaymentState();
}

List<Map<String, dynamic>> buildPaymentForCreateBayar() {
  final result = <Map<String, dynamic>>[];

  for (final line in splitLines) {
    final amount = parseIdr(line.amountCon.text);

    if (line.methodCode.trim().isEmpty) continue;
    if (amount <= 0) continue;

    result.add({
      "payment_method_id": line.methodCode.trim(),
      "payment_reference_id": blankToNull(line.paymentReferenceId),
      "payment_value": amount.toString(),
    });
  }
  return result;
}

Future<String> calculateTransactionBayar2(
  BuildContext context,
  String token,
  List<Map<String, dynamic>> details,
  dynamic memberId,
  dynamic discountId,
  dynamic transactionId,
) async {
  whenLoading(context);

  try {
    final preparedDetails = buildApiDetailPayload(details);

    if (preparedDetails.isEmpty) {
      showSnackbar(context, {"rc": "99", "message": "Detail kosong"});
      return "99";
    }

    final isOpenBillFlow = blankToNull(transactionId) != null;

    if (!isOpenBillFlow) {
      selectedTagihanData = null;
      resetSplitPaymentState();
    }

    final previousPaymentType = paymentTypeIndex;

    final body = {
      "device_id": identifier,
      "deviceid": identifier,
      "transaction_id": blankToNull(transactionId),
      "discount_id": blankToNull(discountId),
      "member_id": blankToNull(memberId),
      "value": 0,
      "payment_method": "001",
      "payment_reference": "",
      "detail": preparedDetails,
    };

    debugPrint("REQ CALC BAYAR V2: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(calculateTransaksiUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint("RESP CALC BAYAR V2: ${jsonEncode(jsonResponse)}");

    final rc = (jsonResponse['rc'] ?? '99').toString();
    final data = jsonResponse['data'];

    if (response.statusCode == 200 && data is Map<String, dynamic>) {
      hydratePaymentSummaryFromData(data, treatAsOpenBill: false);

      paymentTypeIndex = previousPaymentType;
      return rc;
    }

    showSnackbar(context, jsonResponse);
    return rc;
  } catch (e) {
    showSnackbar(context, {
      "rc": "99",
      "message": "calculateTransactionBayar2 error: $e",
    });
    return "99";
  } finally {
    closeLoading(context);
  }
}

Future<Map<String, dynamic>> createTransactionBayar2(
  BuildContext context,
  String token,
  List<Map<String, dynamic>> details,
  dynamic transactionId,
  dynamic memberId,
  dynamic discountId,
) async {
  final payments = buildPaymentForCreateBayar();

  final paidTotal = splitLines.fold<int>(
    0,
    (sum, element) => sum + parseIdr(element.amountCon.text),
  );

  final dueNow = sisaTagihan > 0 ? sisaTagihan : asInt(totalTransaksi);

  final hasAmountWithoutMethod = splitLines.any(
    (element) =>
        parseIdr(element.amountCon.text) > 0 &&
        element.methodCode.trim().isEmpty,
  );

  if (hasAmountWithoutMethod) {
    final err = {
      "rc": "99",
      "message": "Pilih metode pembayaran dulu.",
    };
    showSnackbar(context, err);
    return err;
  }

  if (paymentTypeIndex == 0 && paidTotal > 0 && paidTotal < dueNow) {
    final err = {
      "rc": "99",
      "message": "Nominal pembayaran kurang untuk pelunasan",
    };
    showSnackbar(context, err);
    return err;
  }

  return submitTransactionApi(
    context,
    token,
    details,
    transactionId: transactionId,
    memberId: memberId,
    discountId: discountId,
    payments: payments,
    dueAmountOverride: dueNow,
  );
}

List<Map<String, dynamic>> buildApiVariantPayload(dynamic rawVariants) {
  final decoded = safeJsonDecode(rawVariants);
  final List rawList = decoded is List
      ? decoded
      : (rawVariants is List ? rawVariants : const []);
  final result = <Map<String, dynamic>>[];

  for (final category in rawList) {
    if (category is! Map) continue;

    final categoryId = (category['variant_category_id'] ?? '')
        .toString()
        .trim();
    if (categoryId.isEmpty) continue;

    final rawVariantItems =
        category['variant'] ??
        category['variant_detail'] ??
        category['variant_products'] ??
        const [];

    final List variantItems = rawVariantItems is List
        ? rawVariantItems
        : const [];

    final normalizedItems = <Map<String, dynamic>>[];

    for (final item in variantItems) {
      if (item is! Map) continue;

      final variantId = (item['variant_id'] ?? item['variant_product_id'] ?? '')
          .toString()
          .trim();

      if (variantId.isEmpty) continue;

      normalizedItems.add({
        "variant_id": variantId,
        "variant_price": asInt(item['variant_price'] ?? item['price']),
        "is_variant_customize": asBool(item['is_variant_customize']) ? 1 : 0,
      });
    }

    result.add({"variant_category_id": categoryId, "variant": normalizedItems});
  }

  return result;
}

List<Map<String, dynamic>> buildApiDetailPayload(
  List<Map<String, dynamic>> details,
) {
  final result = <Map<String, dynamic>>[];

  for (final item in details) {
    final productId = (item['product_id'] ?? item['productid'] ?? '')
        .toString()
        .trim();
    if (productId.isEmpty) continue;

    // final isCustomize = asBool(item['is_customize']);
    // final forceAmount = productId == 'custom' || productId == 'digitalProduct';
    final amountSource = item['amount'] ?? item['amount_display'] ?? 0;

    result.add({
      "request_id": blankToNull(item['request_id'] ?? item['id_request']),
      "product_id": productId,
      "is_online": asBool(item['is_online']),
      "is_customize": asBool(item['is_customize']),
      "amount": toAmountString(amountSource),
      "name": (item['name'] ?? '').toString(),
      "quantity": asInt(item['quantity'], fallback: 1),
      "description": blankToNull(item['description']),
      "variants": buildApiVariantPayload(item['variants']),
    });
  }
  return result;
}

Future<Map<String, dynamic>> submitTransactionApi(
  BuildContext context,
  String token,
  List<Map<String, dynamic>> details, {
  dynamic transactionId,
  dynamic memberId,
  dynamic discountId,
  List<Map<String, dynamic>> payments = const [],
  int? dueAmountOverride,
}) async {
  whenLoading(context);

  try {
    final detailFinal = buildApiDetailPayload(details);

    if (detailFinal.isEmpty) {
      final err = {"rc": "99", "message": "Detail Kosong"};
      showSnackbar(context, err);
      return err;
    }

    final paidTotal = payments.fold<int>(
      0,
      (sum, item) => sum + asInt(item['payment_value']),
    );
    final totalDue =
        dueAmountOverride ??
        (sisaTagihan > 0 ? sisaTagihan : asInt(totalTransaksi));

    final bodyJson = {
      "deviceid": identifier,
      "device_id": identifier,
      "discount_id": blankToNull(discountId),
      "member_id": blankToNull(memberId),
      "transaction_id": blankToNull(transactionId),
      "is_partial_payment": payments.isNotEmpty && paidTotal < totalDue,
      "payments": payments,
      "detail": detailFinal,
    };

    debugPrint("REQ SUBMIT API: ${jsonEncode(bodyJson)}");

    final response = await http.post(
      Uri.parse(createTransaksiUrl),
      headers: {"token": token, "Content-Type": "application/json"},
      body: jsonEncode(bodyJson),
    );

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint("RESP SUBMIT API: ${jsonEncode(jsonResponse)}");

    final rc = (jsonResponse["rc"] ?? "99").toString();

    if (rc == '00' && jsonResponse["data"] is Map<String, dynamic>) {
      hydratePaymentSummaryFromData(
        Map<String, dynamic>.from(jsonResponse["data"]),
        treatAsOpenBill: false,
      );

      if (sisaTagihan > 0) {
        isTagihan = true;
        paymentTypeIndex = 1;
      } else {
        isTagihan = false;
        paymentTypeIndex = 0;
        transactionidValue = null;
        totalTransaksi = 0;
        sisaTagihan = 0;
      }
    }

    if (rc == '91') {
      resetPaymentSummaryState();
    }

    showSnackbar(context, jsonResponse);
    return jsonResponse;
  } catch (e) {
    final err = {
      "rc": "99",
      "message": "submitTransactionApi error: $e",
    };
    showSnackbar(context, err);
    return err;
  } finally {
    closeLoading(context);
  }
}


Map<String, dynamic>? selectedTagihanData;

Future<bool> handleQrisResponse({
  required BuildContext context,
  required Map<String, dynamic> response,
  required String token,
  required VoidCallback onSuccess,
  List<Map<String, dynamic>>? cart,
}) async {
  final rc = response['rc']?.toString();
  final data = response['data'];

  if (rc == '00' && data is Map<String, dynamic>) {
    int amountQris = 0;

    // Identify amount for payment method '003' (QRIS)
    if (data['payments'] != null) {
      final payments = data['payments'];
      if (payments is Map<String, dynamic> && payments['payments'] is List) {
        final paymentList = payments['payments'] as List;
        for (var p in paymentList) {
          if (p is Map && p['payment_method_id']?.toString() == '003') {
            amountQris = asInt(p['payment_value'] ?? 0);
            break;
          }
        }
      }
    }

    if (amountQris == 0) {
      amountQris = asInt(data['amount'] ?? totalTransaksi);
    }

    await SharedQrisHandler.showSharedQrisFlow(
      context: context,
      response: response,
      token: token,
      amount: amountQris,
      cart: cart,
      onSuccess: onSuccess,
    );

    return true;
  }
  return false;
}
