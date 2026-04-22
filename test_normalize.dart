void main() {
  String normalizeDecimalQuantity(dynamic qty) {
    if (qty == null) return '0';
    String qString = qty.toString().trim();
    if (qString.isEmpty || qString == 'null') return '0';
    
    double? v;
    if (qty is int) {
      v = qty.toDouble();
    } else if (qty is double) {
      v = qty;
    } else {
      v = double.tryParse(qString);
    }
    
    if (v == null || v == 0) return '0';
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString().replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  print("12.0087000 -> " + normalizeDecimalQuantity("12.0087000"));
  print("10.000000 -> " + normalizeDecimalQuantity("10.000000"));
  print("15.50 -> " + normalizeDecimalQuantity("15.50"));
}
