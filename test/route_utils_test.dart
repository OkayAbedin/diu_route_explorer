import 'package:flutter_test/flutter_test.dart';
import 'package:diu_route_explorer/utils/route_utils.dart';

void main() {
  group('RouteUtils Tests', () {
    test('sortRouteNames should sort routes in logical order', () {
      // Arrange
      List<String> unsortedRoutes = [
        'F1 - Faculty Route 1',
        'R10 - Regular Route 10',
        'R2 - Regular Route 2',
        'F2 - Faculty Route 2',
        'R1 - Regular Route 1',
        'R3 - Regular Route 3',
      ];

      // Act
      List<String> sortedRoutes = RouteUtils.sortRouteNames(unsortedRoutes);

      // Assert
      List<String> expectedOrder = [
        'R1 - Regular Route 1',
        'R2 - Regular Route 2',
        'R3 - Regular Route 3',
        'R10 - Regular Route 10',
        'F1 - Faculty Route 1',
        'F2 - Faculty Route 2',
      ];

      expect(sortedRoutes, equals(expectedOrder));
    });

    test('sortRouteData should sort route data objects by Route field', () {
      // Arrange
      List<Map<String, dynamic>> unsortedData = [
        {'Route': 'F1', 'Route Name': 'Faculty Route 1'},
        {'Route': 'R10', 'Route Name': 'Regular Route 10'},
        {'Route': 'R2', 'Route Name': 'Regular Route 2'},
        {'Route': 'F2', 'Route Name': 'Faculty Route 2'},
        {'Route': 'R1', 'Route Name': 'Regular Route 1'},
      ];

      // Act
      List<Map<String, dynamic>> sortedData = RouteUtils.sortRouteData(
        unsortedData,
      );

      // Assert
      expect(sortedData[0]['Route'], equals('R1'));
      expect(sortedData[1]['Route'], equals('R2'));
      expect(sortedData[2]['Route'], equals('R10'));
      expect(sortedData[3]['Route'], equals('F1'));
      expect(sortedData[4]['Route'], equals('F2'));
    });

    test('extractRouteCode should extract route code correctly', () {
      expect(
        RouteUtils.extractRouteCode('R1 - DSC <> Dhanmondi'),
        equals('R1'),
      );
      expect(RouteUtils.extractRouteCode('F2 - Faculty Route'), equals('F2'));
    });

    test('formatRouteDisplayName should format correctly', () {
      expect(
        RouteUtils.formatRouteDisplayName('R1', 'DSC <> Dhanmondi'),
        equals('R1 - DSC <> Dhanmondi'),
      );
    });
  });
}
