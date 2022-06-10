import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizationsHelper {
  AppLocalizationsHelper(this.locale);

  final Locale locale;

  static AppLocalizationsHelper of(BuildContext context) {
    return Localizations.of<AppLocalizationsHelper>(context, AppLocalizationsHelper)!;
  }

  static AppLocalizationsHelper get instance => AppLocalizationsHelperDelegate.instance;

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      "regular": "Regular",
      "irregular": "Irregular",
      "repose": "Repose",
      "very_light_activity": "Very light activity",
      "light_activity": "Light activity",
      "moderated_activity": "Moderated activity",
      "intense_activity": "Intense activity",
      "very_intense_activity": "Very intense activity",
      "repose_explanation": "Descanso. Personas con movilidad reducida, o con dependencia alta.",
      "very_light_activity_explanation": "Personas que pasen la mayor parte de su jornada sentados.",
      "light_activity_explanation": "Actividad leve, trabajo que requiera caminar o levantarse ocasionalmente. Conductores, estudiantes, operarios, dependientes.",
      "moderated_activity_explanation": "Actividad moderada, trabajo predominantemente de pie o caminando. Tareas del hogar, hostelería.",
      "intense_activity_explanation": "Actividad intensa, trabajo pesado pasen la mayor parte de su jornada en movimiento y muy activo. Trabajadores de construcción, atletas de alto rendimiento.",
      "very_intense_activity_explanation": "Actividad excepcionalmente intensa. Práctica de deporte (30–60 min de 4–5 veces a la semana).",
      "occupation_mandatory": "You have to select an activity according to your occupation",
      "high_blood_pressure": "High blood pressure",
      "arteriosclerosis": "Arteriosclerosis",
      "type_1_diabetes": "Type 1 diabetes",
      "type_2_diabetes": "Type 2 diabetes",
      "high_sugar_level": "High levels of sugar",
      "high_cholesterol": "High cholesterol",
      "high_triglycerides": "High triglycerides",
      "other_diseases": "Other disease",
      "none": "None",
      "omnivorous": "Omnivorous",
      "vegetarian": "Vegetarian",
      "vegan": "Vegan",
      "halal": "Halal",
      "crustaceans": "Crustaceans",
      "gluten": "Gluten",
      "eggs": "Eggs",
      "fish": "Fish",
      "peanuts": "Peanuts",
      "soy": "Soy",
      "milk": "Milk",
      "nuts": "Frutos secos",
      "celery": "Celery",
      "mustard": "Mustard",
      "sesame": "Sesame",
      "sulphites": "Sulphites",
      "lupins": "Lupins",
      "mollusks": "Mollusks",
      "lactose": "Lactose",
      "fructose": "Fructose",
      "sorbitol": "Sorbitol",
      "stomach_acidity": "Stomach acidity",
      "diarrhea": "Diarrea",
      "constipation": "Constipation",
    },
    'es': {
      "masculine": "Masculino",
      "feminine": "Femenino",
      "regular": "Regular",
      "irregular": "Irregular",
      "repose": "Reposo",
      "very_light_activity": "Actividad muy leve",
      "light_activity": "Actividad leve",
      "moderated_activity": "Actividad moderada",
      "intense_activity": "Actividad intensa",
      "very_intense_activity": "Actividad muy intensa",
      "repose_explanation": "Descanso. Personas con movilidad reducida, o con dependencia alta.",
      "very_light_activity_explanation": "Personas que pasen la mayor parte de su jornada sentados.",
      "light_activity_explanation": "Actividad leve, trabajo que requiera caminar o levantarse ocasionalmente. Conductores, estudiantes, operarios, dependientes.",
      "moderated_activity_explanation": "Actividad moderada, trabajo predominantemente de pie o caminando. Tareas del hogar, hostelería.",
      "intense_activity_explanation": "Actividad intensa, trabajo pesado pasen la mayor parte de su jornada en movimiento y muy activo. Trabajadores de construcción, atletas de alto rendimiento.",
      "very_intense_activity_explanation": "Actividad excepcionalmente intensa. Práctica de deporte (30–60 min de 4–5 veces a la semana).",
      "high_blood_pressure": "Hipertensión arterial",
      "arteriosclerosis": "Arterioesclerosis",
      "type_1_diabetes": "Diabetes tipo 1",
      "type_2_diabetes": "Diabetes tipo 2",
      "high_sugar_level": "Glucosa/Azúcar Elevada",
      "high_cholesterol": "High cholesterol",
      "high_triglycerides": "High triglycerides",
      "other_diseases": "Otra enfermedad",
      "none": "Ninguna",
      "omnivorous": "Omnivorous",
      "vegetarian": "Vegetarian",
      "vegan": "Vegan",
      "halal": "Halal",
      "crustaceans": "Crustaceans",
      "gluten": "Gluten",
      "eggs": "Eggs",
      "fish": "Fish",
      "peanuts": "Peanuts",
      "soy": "Soy",
      "milk": "Milk",
      "nuts": "Frutos secos",
      "celery": "Celery",
      "mustard": "Mustard",
      "sesame": "Sesame",
      "sulphites": "Sulphites",
      "lupins": "Lupins",
      "mollusks": "Mollusks",
      "allergens_question": "Do you have any allergies?",
      "lactose": "Lactose",
      "fructose": "Fructose",
      "sorbitol": "Sorbitol",
      "stomach_acidity": "Stomach acidity",
      "diarrhea": "Diarrea",
      "constipation": "Constipation",
    },
  };

  static List<String> languages ()=> _localizedValues.keys.toList();

  String translate(String key) {
    return _localizedValues[locale.languageCode]![key]!;
  }
}
// #enddocregion App

// #docregion Delegate
class AppLocalizationsHelperDelegate
    extends LocalizationsDelegate<AppLocalizationsHelper> {
  static var instance;

  const AppLocalizationsHelperDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizationsHelper.languages().contains(locale.languageCode);


  @override
  Future<AppLocalizationsHelper> load(Locale locale) async {
    var localizations =
    await SynchronousFuture<AppLocalizationsHelper>(AppLocalizationsHelper(locale));
    instance = localizations;
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsHelperDelegate old) => false;
}