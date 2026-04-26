class ApiParser {
  static List<Map<String, dynamic>> extractList(dynamic apiData) {
    if (apiData is List) {
      return apiData.whereType<Map<String, dynamic>>().toList();
    }

    if (apiData is Map<String, dynamic>) {
      final dynamic nestedData = apiData['data'];
      if (nestedData is List) {
        return nestedData.whereType<Map<String, dynamic>>().toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  static Map<String, dynamic> extractMap(dynamic apiData) {
    if (apiData is Map<String, dynamic>) {
      if (apiData['data'] is Map<String, dynamic>) {
        return apiData['data'] as Map<String, dynamic>;
      }

      return apiData;
    }

    return <String, dynamic>{};
  }
}
