extension DateTimeExtensions on String {
  String getDayNumber() {
    final entries = split('/');
    return entries[0];
  }

  String getMonthNumber() {
    final entries = split('/');
    return entries[1];
  }

  String getYearOfBirth() {
    final entries = split('/');
    return entries[2];
  }

  String getDayAndMonth() {
    final entries = split('/');
    return '${entries[0]}/${entries[1]}';
  }
}
