extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension TimeExtension on double {
  String get toFormattedTime {
    final minutes = this ~/ 60;
    final seconds = this % 60;
    final formattedTime =
        '$minutes:${seconds.toStringAsFixed(0).padLeft(2, '0')}';
    return formattedTime;
  }
}
