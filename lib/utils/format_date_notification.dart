String formatDateNotification(String rawDate) {
  try {
    final dt = DateTime.parse(rawDate.trim());
    final now = DateTime.now();

    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$jam:$menit';

    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) return timeStr; // contoh: "14:30"

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;
    if (isYesterday) return 'Kemarin · $timeStr';

    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  } catch (_) {
    return rawDate;
  }
}

String formatDateNotificationDetail(String rawDate) {
  try {
    final dt = DateTime.parse(rawDate.trim());
    final now = DateTime.now();

    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$jam:$menit';

    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) return timeStr; 

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;
    if (isYesterday) return 'Kemarin · $timeStr';

    const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month]} ${dt.year} · $timeStr';
  } catch (_) {
    return rawDate;
  }
}
