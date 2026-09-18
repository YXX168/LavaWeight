enum BMICategory {
  underweight('偏瘦'),
  normal('标准'),
  overweight('偏胖'),
  obese('肥胖');

  final String label;
  const BMICategory(this.label);
}

class BMICalculator {
  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  static BMICategory getCategory(double bmi) {
    if (bmi < 18.5) {
      return BMICategory.underweight;
    } else if (bmi < 24.0) {
      return BMICategory.normal;
    } else if (bmi < 28.0) {
      return BMICategory.overweight;
    } else {
      return BMICategory.obese;
    }
  }

  static (double minKg, double maxKg) getHealthyWeightRange(double heightCm) {
    if (heightCm <= 0) return (0.0, 0.0);
    final heightM = heightCm / 100.0;
    final minKg = 18.5 * heightM * heightM;
    final maxKg = 23.9 * heightM * heightM;
    return (
      double.parse(minKg.toStringAsFixed(1)),
      double.parse(maxKg.toStringAsFixed(1)),
    );
  }
}
