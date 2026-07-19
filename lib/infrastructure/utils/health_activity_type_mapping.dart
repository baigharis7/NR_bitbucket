import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_type_normalizer.dart';

/// How confidently a platform workout type was mapped to a master-file sport,
/// ordered strongest first.
enum HealthTypeMappingConfidence {
  /// The humanized platform type equals a sport's en/es name.
  explicitName,

  /// A curated per-type keyword matched a sport name.
  keyword,

  /// No specific match; imported under the configured generic sport.
  genericImported,

  /// No specific match and no generic sport in the master file.
  unmapped,
}

/// Which pipeline tier produced the result.
enum HealthTypeMappingStrategy { exactNameMatch, keywordScan, genericFallback, none }

/// Deterministic outcome of mapping one platform workout type against the
/// sports master file.
///
/// Plain immutable class — no `==`/`hashCode` override (the codebase uses
/// neither `equatable` nor `freezed`). Tests assert on individual fields.
class HealthActivityTypeMappingResult {
  /// Matched sport id; null iff [confidence] is
  /// [HealthTypeMappingConfidence.unmapped].
  final int? sportId;

  final HealthTypeMappingConfidence confidence;

  final HealthTypeMappingStrategy strategy;

  /// The normalized platform type the pipeline ran on (e.g. 'TAI_CHI') — a
  /// coarse activity-category token safe for diagnostics metadata.
  final String platformType;

  const HealthActivityTypeMappingResult({
    required this.sportId,
    required this.confidence,
    required this.strategy,
    required this.platformType,
  });
}

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

  /// Ordered generic-sport names. The generic tier scans this list
  /// list-order-first (for each name, over all sports), so the outcome never
  /// depends on master-file ordering.
  static const List<String> _genericSportNames = [
    'other',
    'otro',
    'general',
    'exercise',
    'ejercicio',
    'workout',
    'entrenamiento',
  ];

  /// Deterministically resolves [workoutType] against [sportsInfo].
  ///
  /// Input is normalized via [HealthWorkoutTypeNormalizer.normalize] (one
  /// normalization in the codebase, shared with the dedupe fingerprint).
  /// Pipeline, first hit wins:
  /// 1. Exact name — the humanized type (underscores → spaces) equals a
  ///    sport's en/es name case-insensitively → [HealthTypeMappingConfidence.explicitName].
  /// 2. Curated keywords — only for types that HAVE a table entry; there is
  ///    no unknown-type keyword fallback → [HealthTypeMappingConfidence.keyword].
  /// 3. Generic — [_genericSportNames], list-order-first contains-match on
  ///    en/es → [HealthTypeMappingConfidence.genericImported].
  /// 4. Unmapped — `sportId` null; there is deliberately NO first-sport last
  ///    resort → [HealthTypeMappingConfidence.unmapped].
  static HealthActivityTypeMappingResult mapToResult(
    String workoutType,
    SportsInfoEntity sportsInfo,
  ) {
    final normalizedType = HealthWorkoutTypeNormalizer.normalize(workoutType);
    final humanized = normalizedType.replaceAll('_', ' ').toLowerCase();

    // Tier 1: exact en/es name equality.
    for (final sport in sportsInfo.data) {
      if (sport.en.toLowerCase() == humanized ||
          sport.es.toLowerCase() == humanized) {
        return HealthActivityTypeMappingResult(
          sportId: sport.id,
          confidence: HealthTypeMappingConfidence.explicitName,
          strategy: HealthTypeMappingStrategy.exactNameMatch,
          platformType: normalizedType,
        );
      }
    }

    // Tier 2: curated keyword table, only for types that have an entry. The
    // legacy 'OTHER' entry is excluded: OTHER carries no type information,
    // so it resolves via the generic tier below. (The entry itself is
    // deleted together with the legacy mapToSportId API — it is still
    // dereferenced there until that method is removed.)
    final keywords = normalizedType == 'OTHER'
        ? null
        : _workoutTypeKeywords[normalizedType];
    if (keywords != null) {
      for (final keyword in keywords) {
        final lowerKeyword = keyword.toLowerCase();
        for (final sport in sportsInfo.data) {
          if (sport.en.toLowerCase().contains(lowerKeyword) ||
              sport.es.toLowerCase().contains(lowerKeyword)) {
            return HealthActivityTypeMappingResult(
              sportId: sport.id,
              confidence: HealthTypeMappingConfidence.keyword,
              strategy: HealthTypeMappingStrategy.keywordScan,
              platformType: normalizedType,
            );
          }
        }
      }
    }

    // Tier 3: deterministic generic-sport lookup.
    for (final name in _genericSportNames) {
      for (final sport in sportsInfo.data) {
        if (sport.en.toLowerCase().contains(name) ||
            sport.es.toLowerCase().contains(name)) {
          return HealthActivityTypeMappingResult(
            sportId: sport.id,
            confidence: HealthTypeMappingConfidence.genericImported,
            strategy: HealthTypeMappingStrategy.genericFallback,
            platformType: normalizedType,
          );
        }
      }
    }

    // Tier 4: unmapped — never an arbitrary first master-file sport.
    return HealthActivityTypeMappingResult(
      sportId: null,
      confidence: HealthTypeMappingConfidence.unmapped,
      strategy: HealthTypeMappingStrategy.none,
      platformType: normalizedType,
    );
  }

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
