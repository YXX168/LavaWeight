import 'package:flutter_test/flutter_test.dart';
import 'package:lava_weight/services/bmi_calculator.dart';

void main() {
  group('BMICalculator Tests', () {
    test('calculateBMI returns correct formatted value', () {
      // 68.5 kg, 175 cm -> 68.5 / (1.75 * 1.75) = 22.367 -> 22.4
      final bmi = BMICalculator.calculateBMI(68.5, 175.0);
      expect(bmi, 22.4);
    });

    test('getCategory categorizes properly', () {
      expect(BMICalculator.getCategory(18.0), BMICategory.underweight);
      expect(BMICalculator.getCategory(22.4), BMICategory.normal);
      expect(BMICalculator.getCategory(26.0), BMICategory.overweight);
      expect(BMICalculator.getCategory(31.0), BMICategory.obese);
    });

    test('getHealthyWeightRange computes accurately', () {
      final (minKg, maxKg) = BMICalculator.getHealthyWeightRange(175.0);
      // 18.5 * 1.75^2 = 56.656 -> 56.7
      // 23.9 * 1.75^2 = 73.193 -> 73.2
      expect(minKg, 56.7);
      expect(maxKg, 73.2);
    });

    test('handles zero or negative inputs safely', () {
      expect(BMICalculator.calculateBMI(0, 175), 0.0);
      expect(BMICalculator.calculateBMI(68.5, 0), 0.0);
      final (minKg, maxKg) = BMICalculator.getHealthyWeightRange(0);
      expect(minKg, 0.0);
      expect(maxKg, 0.0);
    });
  });
}

