import 'package:flutter_test/flutter_test.dart';
import 'package:Annujoom/src/data/utils/currency_formatter.dart';

void main() {
  group('formatCurrency Tests', () {
    test('formats null value safely to zero rupees', () {
      expect(formatCurrency(null), equals('₹0'));
    });

    test('returns already formatted string as is', () {
      expect(formatCurrency('₹50,000'), equals('₹50,000'));
    });

    test('formats regular numeric string representation of number', () {
      expect(formatCurrency('50000'), equals('₹50,000'));
    });

    test('formats integers correctly', () {
      expect(formatCurrency(50000), equals('₹50,000'));
    });

    test('formats large values to Lakh (L) and Crore (Cr)', () {
      expect(formatCurrency(100000), equals('₹1L'));
      expect(formatCurrency(1250000), equals('₹12.5L'));
      expect(formatCurrency(10000000), equals('₹1Cr'));
      expect(formatCurrency(125000000), equals('₹12.5Cr'));
    });

    test('formats invalid string to ₹0', () {
      expect(formatCurrency('abc'), equals('₹0'));
    });

    test('formats unexpected dynamic types to ₹0', () {
      expect(formatCurrency(Object()), equals('₹0'));
    });
  });
}
