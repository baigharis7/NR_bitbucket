import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';

/// Utility class for mapping HealthKit/Health Connect workout types
/// to the app's sport IDs from the master file.
class HealthActivityTypeMapping {
  /// Maps common health platform workout type strings to search keywords
  /// for finding matching sports in the master file.
  static const Map<String, List<String>> _workoutTypeKeywords = {
    // Running activities
    'RUNNING': ['running', 'correr', 'jogging', 'carrera'],
    'WALKING': ['walking', 'caminar', 'walk', 'hiking', 'senderismo'],
    'CYCLING': ['cycling', 'ciclismo', 'bicycle', 'bicicleta', 'bike'],
    'SWIMMING': ['swimming', 'natación', 'swim', 'nadar'],

    // Gym activities
    'TRADITIONAL_STRENGTH_TRAINING': ['weights', 'pesas', 'strength', 'gym', 'gimnasio', 'musculación'],
    'FUNCTIONAL_STRENGTH_TRAINING': ['functional', 'crossfit', 'hiit'],
    'CORE_TRAINING': ['core', 'abs', 'abdominales'],
    'FLEXIBILITY': ['stretching', 'estiramientos', 'yoga', 'flexibility'],
    'HIGH_INTENSITY_INTERVAL_TRAINING': ['hiit', 'interval', 'high intensity'],

    // Sports
    'TENNIS': ['tennis', 'tenis'],
    'BADMINTON': ['badminton', 'bádminton'],
    'SOCCER': ['soccer', 'football', 'fútbol'],
    'BASKETBALL': ['basketball', 'baloncesto'],
    'VOLLEYBALL': ['volleyball', 'voleibol'],
    'TABLE_TENNIS': ['table tennis', 'ping pong', 'tenis de mesa'],
    'GOLF': ['golf'],
    'SKIING': ['skiing', 'esquí'],
    'SNOWBOARDING': ['snowboard'],
    'SKATING': ['skating', 'patinaje'],
    'MARTIAL_ARTS': ['martial arts', 'artes marciales', 'karate', 'judo', 'taekwondo'],
    'BOXING': ['boxing', 'boxeo'],
    'WRESTLING': ['wrestling', 'lucha'],

    // Cardio
    'ELLIPTICAL': ['elliptical', 'elíptica'],
    'ROWING': ['rowing', 'remo'],
    'STAIR_CLIMBING': ['stairs', 'escaleras', 'stair'],
    'JUMP_ROPE': ['jump rope', 'saltar cuerda', 'comba'],

    // Dance & others
    'DANCE': ['dance', 'baile', 'dancing', 'zumba'],
    'PILATES': ['pilates'],
    'YOGA': ['yoga'],

    // Water activities
    'WATER_POLO': ['water polo', 'waterpolo'],
    'SURFING': ['surfing', 'surf'],
    'PADDLE_SPORTS': ['paddle', 'kayak', 'canoe', 'paddleboard'],

    // Default/fallback
    'WORKOUT': ['exercise', 'ejercicio', 'workout', 'training', 'entrenamiento'],
    'OTHER': ['other', 'otro', 'general'],
  };

  /// Find the best matching sport ID from the master file for a given workout type.
  /// Returns null if no good match is found (caller should use a generic fallback).
  static int? mapToSportId(String workoutType, SportsInfoEntity sportsInfo) {
    final keywords = _workoutTypeKeywords[workoutType.toUpperCase()] ??
                     _workoutTypeKeywords['OTHER']!;

    // Search through sports master file for a match
    for (final keyword in keywords) {
      final lowerKeyword = keyword.toLowerCase();
      for (final sport in sportsInfo.data) {
        final enLower = sport.en.toLowerCase();
        final esLower = sport.es.toLowerCase();

        if (enLower.contains(lowerKeyword) || esLower.contains(lowerKeyword)) {
          return sport.id;
        }
      }
    }

    return null;
  }

  /// Find a fallback "general exercise" sport ID from the master file.
  /// Used when no specific match is found.
  static int? findFallbackSportId(SportsInfoEntity sportsInfo) {
    // Try to find a generic exercise/workout entry
    final fallbackKeywords = ['general', 'exercise', 'ejercicio', 'other', 'otro', 'training'];

    for (final keyword in fallbackKeywords) {
      for (final sport in sportsInfo.data) {
        final enLower = sport.en.toLowerCase();
        final esLower = sport.es.toLowerCase();

        if (enLower.contains(keyword) || esLower.contains(keyword)) {
          return sport.id;
        }
      }
    }

    // If no fallback found, return the first sport ID as a last resort
    if (sportsInfo.data.isNotEmpty) {
      return sportsInfo.data.first.id;
    }

    return null;
  }

  /// Find sport info by ID from the master file.
  static SportInfoEntity? findSportById(int sportId, SportsInfoEntity sportsInfo) {
    for (final sport in sportsInfo.data) {
      if (sport.id == sportId) {
        return sport;
      }
    }
    return null;
  }

  /// Infer intensity (0=low, 1=medium, 2=high) from activity metadata.
  /// Uses calories per minute as a proxy for intensity.
  static int inferIntensity(double? caloriesBurned, int durationMinutes, double? avgHeartRate) {
    if (durationMinutes <= 0) return 1; // Default to medium

    // If we have heart rate data, use that
    if (avgHeartRate != null) {
      if (avgHeartRate < 100) return 0; // Low
      if (avgHeartRate < 140) return 1; // Medium
      return 2; // High
    }

    // Otherwise use calories per minute
    if (caloriesBurned != null) {
      final calPerMin = caloriesBurned / durationMinutes;
      if (calPerMin < 5) return 0; // Low
      if (calPerMin < 10) return 1; // Medium
      return 2; // High
    }

    return 1; // Default to medium
  }
}
