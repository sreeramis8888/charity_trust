import 'dart:convert';
import 'dart:io';

Future<double?> convertCurrency({
  required String from,
  required String to,
  required double amount,
}) async {
  try {
    // If both currencies are the same, return the original amount
    if (from.toLowerCase() == to.toLowerCase()) {
      return amount;
    }

    // Convert both currencies to lowercase for API consistency
    final fromLower = from.toLowerCase();
    final toLower = to.toLowerCase();

    // Get rates from the 'from' currency
    final response = await HttpClient().getUrl(Uri.parse(
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$fromLower.json'));
    final httpResponse = await response.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    final data = json.decode(responseBody);
    final rates = data[fromLower] as Map<String, dynamic>;
    
    if (rates.containsKey(toLower)) {
      final rate = rates[toLower] as double;
      return amount * rate;
    } else {
      print('Currency $toLower not found in $fromLower rates');
      return null;
    }
  } catch (e) {
    print('Conversion error: $e');
    return null;
  }
}

