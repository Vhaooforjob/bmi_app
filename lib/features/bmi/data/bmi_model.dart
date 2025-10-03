class Meal {
  final String id;
  final String name;
  final int percent;
  final int kcal;

  Meal({
    required this.id,
    required this.name,
    required this.percent,
    required this.kcal,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    id: json['id'],
    name: json['name'],
    percent: json['percent'],
    kcal: json['kcal'],
  );
}

class BmiData {
  final String id;
  final int heightCm;
  final int weightKg;
  final int ageYears;
  final String sex;
  final String activity;
  final double bmi;
  final String bmiClass;
  final int bmrKcal;
  final int tdeeKcal;
  final List<Meal> meals;

  BmiData({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.ageYears,
    required this.sex,
    required this.activity,
    required this.bmi,
    required this.bmiClass,
    required this.bmrKcal,
    required this.tdeeKcal,
    required this.meals,
  });

  factory BmiData.fromJson(Map<String, dynamic> json) => BmiData(
    id: json['_id'],
    heightCm: json['height_cm'],
    weightKg: json['weight_kg'],
    ageYears: json['age_years'],
    sex: json['sex'],
    activity: json['activity'],
    bmi: (json['bmi'] as num).toDouble(),
    bmiClass: json['bmi_class'],
    bmrKcal: json['bmr_kcal'],
    tdeeKcal: json['tdee_kcal'],
    meals: (json['meals'] as List).map((m) => Meal.fromJson(m)).toList(),
  );
}
