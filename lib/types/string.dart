extension StringExtensions on String {
  String capitalize() {
    return isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : this;
  }

  String last() {
    return isNotEmpty ? substring(length - 1) : this;
  }
}
