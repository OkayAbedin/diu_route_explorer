class RouteUtils {
  /// Sorts route names in logical order: R1, R2, R3... then F1, F2, F3...
  /// Route format expected: "R1 - Route Name" or "F1 - Route Name"
  static List<String> sortRouteNames(List<String> routes) {
    List<String> sortedRoutes = List.from(routes);

    sortedRoutes.sort((a, b) {
      // Extract route codes (R1, F1, etc.)
      String codeA = a.split(' - ')[0];
      String codeB = b.split(' - ')[0];

      // Get prefix (R, F, etc.) and number
      String prefixA = codeA.replaceAll(RegExp(r'\d+'), '');
      String prefixB = codeB.replaceAll(RegExp(r'\d+'), '');

      // Extract numbers
      int? numberA = int.tryParse(codeA.replaceAll(RegExp(r'[^0-9]'), ''));
      int? numberB = int.tryParse(codeB.replaceAll(RegExp(r'[^0-9]'), ''));

      // Handle null numbers
      numberA ??= 0;
      numberB ??= 0;

      // First sort by prefix with custom order (R comes before F, etc.)
      int prefixComparison = _comparePrefixes(prefixA, prefixB);
      if (prefixComparison != 0) {
        return prefixComparison;
      }

      // If same prefix, sort by number
      return numberA.compareTo(numberB);
    });

    return sortedRoutes;
  }

  /// Sorts route data objects by their Route field
  /// Expected format: Map with 'Route' field containing route code like "R1", "F1"
  static List<Map<String, dynamic>> sortRouteData(
    List<Map<String, dynamic>> routes,
  ) {
    List<Map<String, dynamic>> sortedRoutes = List.from(routes);

    sortedRoutes.sort((a, b) {
      String codeA = a['Route'] ?? '';
      String codeB = b['Route'] ?? '';

      // Get prefix (R, F, etc.) and number
      String prefixA = codeA.replaceAll(RegExp(r'\d+'), '');
      String prefixB = codeB.replaceAll(RegExp(r'\d+'), '');

      // Extract numbers
      int? numberA = int.tryParse(codeA.replaceAll(RegExp(r'[^0-9]'), ''));
      int? numberB = int.tryParse(codeB.replaceAll(RegExp(r'[^0-9]'), ''));

      // Handle null numbers
      numberA ??= 0;
      numberB ??= 0;

      // First sort by prefix with custom order (R comes before F, etc.)
      int prefixComparison = _comparePrefixes(prefixA, prefixB);
      if (prefixComparison != 0) {
        return prefixComparison;
      }

      // If same prefix, sort by number
      return numberA.compareTo(numberB);
    });

    return sortedRoutes;
  }

  /// Helper method to compare prefixes with custom order
  /// R routes come first, then F routes, then alphabetical order for others
  static int _comparePrefixes(String prefixA, String prefixB) {
    // Define custom order: R first, F second, then alphabetical
    const Map<String, int> prefixOrder = {'R': 1, 'F': 2};

    int orderA = prefixOrder[prefixA] ?? 999; // Unknown prefixes go last
    int orderB = prefixOrder[prefixB] ?? 999;

    if (orderA != orderB) {
      return orderA.compareTo(orderB);
    }

    // If both have same custom order or both are unknown, use alphabetical
    return prefixA.compareTo(prefixB);
  }

  /// Helper method to extract route code from full route name
  /// Example: "R1 - DSC <> Dhanmondi" -> "R1"
  static String extractRouteCode(String fullRouteName) {
    return fullRouteName.split(' - ')[0];
  }

  /// Helper method to format route display name
  /// Example: "R1", "DSC <> Dhanmondi" -> "R1 - DSC <> Dhanmondi"
  static String formatRouteDisplayName(String routeCode, String routeName) {
    return '$routeCode - $routeName';
  }
}
