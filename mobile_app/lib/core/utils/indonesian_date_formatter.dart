class IndonesianDateFormatter {
  IndonesianDateFormatter._();

  static const List<String> _weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthsFull = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String fullDate(DateTime value) {
    final local = value.toLocal();
    return '${_weekday(local.weekday)}, ${local.day} ${_monthFull(local.month)} ${local.year}';
  }

  static String shortDateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${_monthShort(local.month)} ${local.year}, $hour:$minute';
  }

  static String _weekday(int weekday) => _weekdays[weekday - 1];

  static String _monthFull(int month) => _monthsFull[month - 1];

  static String _monthShort(int month) => _monthsShort[month - 1];
}
