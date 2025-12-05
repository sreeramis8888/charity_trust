/// Formats currency values to show as L (Lakh) or Cr (Crore) when appropriate
/// 
/// Examples:
/// - 50000 -> "₹50,000"
/// - 100000 -> "₹1L"
/// - 1250000 -> "₹12.5L"
/// - 10000000 -> "₹1Cr"
/// - 125000000 -> "₹12.5Cr"
String formatCurrency(dynamic value) {
  if (value is String) {
    // If it's already a formatted string like "₹50,000", return as is
    if (value.startsWith('₹')) {
      return value;
    }
    // Try to parse string to number
    value = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  final amount = (value as num).toInt();

  if (amount >= 10000000) {
    // Crore
    final crores = amount / 10000000;
    if (crores % 1 == 0) {
      return '₹${crores.toInt()}Cr';
    }
    return '₹${(crores * 10).toInt() / 10}Cr';
  } else if (amount >= 100000) {
    // Lakh
    final lakhs = amount / 100000;
    if (lakhs % 1 == 0) {
      return '₹${lakhs.toInt()}L';
    }
    return '₹${(lakhs * 10).toInt() / 10}L';
  } else {
    // Regular format with commas
    return '₹${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  }
}
