import 'dart:math' as math;

import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

class MeasureSystemValues {
  const MeasureSystemValues._();

  // ==========================
  // --- Distance & Length ---
  // ==========================

  /// Kilometers to Miles: 1 km ≈ 0.62 miles
  static const double milesMultiplier = 0.621371;

  /// Miles to Kilometers: 1 mile ≈ 1.61 km
  static const double kmMultiplier = 1.609344;

  /// Meters to Feet: 1 m ≈ 3.28 feet
  static const double feetMultiplier = 3.28084;

  /// Feet to Meters: 1 foot = 0.3048 m
  static const double meterMultiplier = 0.3048;

  /// Centimeters to Inches: 1 cm ≈ 0.39 inches
  static const double inchMultiplier = 0.393701;

  /// Inches to Centimeters: 1 inch = 2.54 cm
  static const double cmMultiplier = 2.54;

  // =======================
  // --- Weight & Mass ---
  // =======================

  /// Kilograms to Pounds (lbs): 1 kg ≈ 2.2 lbs
  static const double poundsMultiplier = 2.20462;

  /// Pounds (lbs) to Kilograms: 1 lb ≈ 0.45 kg
  static const double kgMultiplier = 0.453592;

  /// Grams to Ounces (oz): 1 g ≈ 0.035 oz
  static const double ounceMultiplier = 0.035274;

  /// Ounces (oz) to Grams: 1 oz ≈ 28.35 g
  static const double gramMultiplier = 28.3495;

  // ==========================
  // --- Geometry (Angles) ---
  // ==========================

  /// Degrees to Radians: 1 deg ≈ 0.01745 rad
  static const double degreeToRadianMultiplier = math.pi / 180.0;

  /// Radians to Degrees: 1 rad ≈ 57.29 deg
  static const double radianToDegreeMultiplier = 180.0 / math.pi;

  // =========================
  // --- Converter Methods ---
  // =========================

  // Distance
  static double toMiles(double km) => km * milesMultiplier;
  static double toKm(double miles) => miles * kmMultiplier;

  static double toFeet(double meters) => meters * feetMultiplier;
  static double toMeters(double feet) => feet * meterMultiplier;

  static double toInches(double cm) => cm * inchMultiplier;
  static double toCm(double inches) => inches * cmMultiplier;

  // Weight
  static double toPounds(double kg) => kg * poundsMultiplier;
  static double toKg(double lbs) => lbs * kgMultiplier;

  static double toOunces(double grams) => grams * ounceMultiplier;
  static double toGrams(double ounces) => ounces * gramMultiplier;

  // Geometry
  static double toRadians(double degrees) => degrees * degreeToRadianMultiplier;
  static double toDegrees(double radians) => radians * radianToDegreeMultiplier;
}

extension WeightConverter on double {
  double toDisplayWeight(MeasurementSystem system) {
    return switch (system) {
      MeasurementSystem.metric => this,
      MeasurementSystem.imperial => MeasureSystemValues.toPounds(this),
    };
  }

  double toStorageWeight(MeasurementSystem system) {
    return switch (system) {
      MeasurementSystem.metric => this,
      MeasurementSystem.imperial => MeasureSystemValues.toKg(this),
    };
  }

  double roundWeight() => double.parse(toStringAsFixed(2));

  String formatWeight() {
    final rounded = roundWeight();
    return rounded % 1 == 0 ? rounded.toInt().toString() : rounded.toString();
  }
}

extension DistanceConverter on double {
  double toDisplayHeight(MeasurementSystem system) {
    return switch (system) {
      MeasurementSystem.metric => this,
      MeasurementSystem.imperial => MeasureSystemValues.toInches(this),
    };
  }
}
