class ChartModelData {
  final String? caption;
  final String? rp;
  final String? qty;
  final String? dateRange;

  ChartModelData({
    this.caption,
    this.rp,
    this.qty,
    this.dateRange,
  });

  factory ChartModelData.fromJson(Map<String, dynamic> json) {
    return ChartModelData(
      caption: json['caption'],
      rp: json['rp'],
      qty: json['qty'],
      dateRange: json['date-range'],
    );
  }
}
