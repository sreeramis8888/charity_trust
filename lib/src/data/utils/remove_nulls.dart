Map<String, dynamic> removeNulls(Map<String, dynamic> json) {
  final Map<String, dynamic> newMap = {};
  json.forEach((key, value) {
    if (value is Map) {
      final cleaned = removeNulls(Map<String, dynamic>.from(value));
      if (cleaned.isNotEmpty) newMap[key] = cleaned;
    } else if (value is List) {
      final cleanedList = value
          .where((element) => element != null)
          .map((element) => element is Map
              ? removeNulls(Map<String, dynamic>.from(element))
              : element)
          .toList();
      if (cleanedList.isNotEmpty) newMap[key] = cleanedList;
    } else if (value != null) {
      newMap[key] = value;
    }
  });
  return newMap;
}


Map<String, dynamic> cleanMap(Map<String, dynamic> json) {
  final Map<String, dynamic> newMap = {};
  json.forEach((key, value) {
    if (value is Map) {
      final cleaned = cleanMap(Map<String, dynamic>.from(value));
      if (cleaned.isNotEmpty) newMap[key] = cleaned;
    } else if (value is List) {
      final cleanedList = value
          .where((element) => element != null && element != '')
          .map((element) => element is Map
              ? cleanMap(Map<String, dynamic>.from(element))
              : element)
          .toList();
      if (cleanedList.isNotEmpty) newMap[key] = cleanedList;
    } else if (value != null && value != '') {
      newMap[key] = value;
    }
  });
  return newMap;
}
