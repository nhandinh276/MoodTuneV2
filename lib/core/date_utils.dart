// lib/core/date_utils.dart
String twoDigits(int n) => n.toString().padLeft(2, '0');

/// Format: dd/MM/yyyy HH:mm
String formatDateTimeVN(DateTime dt) {
  final d = twoDigits(dt.day);
  final m = twoDigits(dt.month);
  final y = dt.year.toString();
  final hh = twoDigits(dt.hour);
  final mm = twoDigits(dt.minute);
  return "$d/$m/$y $hh:$mm";
}

/// Format: yyyy-MM-dd
String formatDateKey(DateTime dt) {
  final y = dt.year.toString();
  final m = twoDigits(dt.month);
  final d = twoDigits(dt.day);
  return "$y-$m-$d";
}
