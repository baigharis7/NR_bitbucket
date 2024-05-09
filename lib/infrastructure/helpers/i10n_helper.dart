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
      'regular': 'Regular',
      'irregular': 'Irregular',
      'repose': 'Very sedentary',
      'very_light_activity': 'Sedentary',
      'light_activity': 'Light activity',
      'moderated_activity': 'Moderated activity',
      'intense_activity': 'Intense activity',
      'very_intense_activity': 'Very intense activity',
      'repose_explanation': 'No daily activity. Resting or sitting all day',
      'very_light_activity_explanation': 'Low daily activity. Office work, driving, cooking, using the computer.',
      'light_activity_explanation': 'Work standing or job that involves occasional walking.',
      'moderated_activity_explanation': 'Active standing job, predominantly involving walking.',
      'intense_activity_explanation': 'Physically demanding and active job.',
      'very_intense_activity_explanation': 'Physically very demanding and active job.',
      'occupation_mandatory': 'You have to select an activity according to your occupation',
      'high_blood_pressure': 'High blood pressure',
      'arteriosclerosis': 'Arteriosclerosis',
      'type_1_diabetes': 'Type 1 diabetes',
      'type_2_diabetes': 'Type 2 diabetes',
      'high_sugar_level': 'High levels of sugar',
      'high_cholesterol': 'High cholesterol',
      'high_triglycerides': 'High triglycerides',
      'other_diseases': 'Other diseases',
      'none': 'None',
      'omnivorous': 'Omnivorous',
      'vegetarian': 'Vegetarian',
      'vegan': 'Vegan',
      'halal': 'Halal',
      'crustaceans': 'Crustaceans',
      'gluten': 'Gluten',
      'eggs': 'Eggs',
      'fish': 'Fish',
      'peanuts': 'Peanuts',
      'soy': 'Soy',
      'milk': 'Milk',
      'nuts': 'Frutos secos',
      'celery': 'Celery',
      'mustard': 'Mustard',
      'sesame': 'Sesame',
      'sulfites': 'Sulfites',
      'lupins': 'Lupins',
      'mollusks': 'Mollusks',
      'lactose': 'Lactose',
      'fructose': 'Fructose',
      'sorbitol': 'Sorbitol',
      'stomach_acidity': 'Stomach acidity',
      'diarrhea': 'Diarrea',
      'constipation': 'Constipation',
      'water' : 'Water',
      'breakfast' : 'Breakfast',
      'lunch' : 'Lunch',
      'dinner' : 'Dinner',
      'snack' : 'Snack',
      'hindu' : 'Hindu',
      'kosher' : 'Kosher',
      'lactoovovegetarian' : 'LactoOvoVegetarian',
      'ovovegetarian' : 'OvoVegetarian',
      'lactovegetarian' : 'LactoVegetarian',
      'no_bowel_movement' : 'No bowel movements',
      'type1_feces' : 'Type 1 - Constipation',
      'type2_feces' : 'Type 2 - Constipation',
      'type3_feces' : 'Type 3 - Normal',
      'type4_feces' : 'Type 4 - Normal',
      'type5_feces' : 'Type 5 - Diarrea',
      'type6_feces' : 'Type 6 - Diarrea',
      'type7_feces' : 'Type 7 - Diarrea',
      'type1_feces_exp' : 'Hard and separated pieces',
      'type2_feces_exp' : 'sausage shape With packages',
      'type3_feces_exp' : 'Sausage shape, with cracks on the surface',
      'type4_feces_exp' : 'soft and squishy',
      'type5_feces_exp' : 'Soft pieces with edges',
      'type6_feces_exp' : 'soft pieces with undone edges',
      'type7_feces_exp' : 'No solid pieces.Entirely liquid',
      'good_hydration' : 'Good hydration',
      'mild_dehydration' : 'Mild dehydration',
      'medium_dehydration' : 'Medium dehydration',
      'high_dehydration' : 'High dehydration',
      'height_cm':'Height (cm)',
      'weight_kg':'Weight (kg)',
      'height_feet':'Height (feet)',
      'weight_lb':'Weight (lb)',
    },
    'es': {
      'masculine': 'Masculino',
      'feminine': 'Femenino',
      'regular': 'Regular',
      'irregular': 'Irregular',
      'repose': 'Muy sedentario',
      'very_light_activity': 'Sedentario',
      'light_activity': 'Actividad leve',
      'moderated_activity': 'Actividad moderada',
      'intense_activity': 'Actividad intensa',
      'very_intense_activity': 'Actividad muy intensa',
      'repose_explanation': 'Ninguna actividad diaria. En reposo o sentado todo el día',
      'very_light_activity_explanation': 'Poca actividad diaria. Trabajo de oficina, conducir, cocinar, estar en el ordenador.',
      'light_activity_explanation': 'Trabajo de pie o que requiera caminar ocasionalmente.',
      'moderated_activity_explanation': 'Trabajo de pie activo, predominantemente caminando.',
      'intense_activity_explanation': 'Trabajo físicamente exigente y activo.',
      'very_intense_activity_explanation': 'Trabajo físicamente muy exigente y activo.',
      'high_blood_pressure': 'Hipertensión arterial',
      'arteriosclerosis': 'Arterioesclerosis',
      'type_1_diabetes': 'Diabetes tipo 1',
      'type_2_diabetes': 'Diabetes tipo 2',
      'high_sugar_level': 'Glucosa/Azúcar Elevada',
      'high_cholesterol': 'Colesterol alto',
      'high_triglycerides': 'Triglicéridos altos',
      'other_diseases': 'Otras enfermedades',
      'none': 'Ninguna',
      'omnivorous': 'Omnívoro',
      'vegetarian': 'Vegetariano',
      'vegan': 'Vegano',
      'halal': 'Halal',
      'crustaceans': 'Crustáceos',
      'gluten': 'Gluten',
      'eggs': 'Huevos',
      'fish': 'Pescado',
      'peanuts': 'Maní',
      'soy': 'Soja',
      'milk': 'Leche',
      'nuts': 'Frutos secos',
      'celery': 'Apio',
      'mustard': 'Mostaza',
      'sesame': 'Sésamo',
      'sulfites': 'Sulfitos',
      'lupins': 'Altramuces',
      'mollusks': 'Moluscos',
      'allergens_question': '¿Tienes alguna alergia?',
      'lactose': 'Lactosa',
      'fructose': 'Fructosa',
      'sorbitol': 'Sorbitol',
      'stomach_acidity': 'Acidez estomacal',
      'diarrhea': 'Diarrea',
      'constipation': 'Estreñimiento',
      'water': 'Agua',
      'breakfast' : 'Desayuno',
      'lunch' : 'Comida',
      'dinner' : 'Cena',
      'snack' : 'Snack',
      'hindu' : 'Hindú',
      'kosher' : 'Kosher',
      'lactoovovegetarian' : 'LactoOvoVegetariana',
      'ovovegetarian' : 'OvoVegetariana',
      'lactovegetarian' : 'LactoVegetariana',
      'no_bowel_movement' : 'Sin Deposiciones',
      'type1_feces' : 'Tipo 1 - Estreñimiento',
      'type2_feces' : 'Tipo 2 - Estreñimiento',
      'type3_feces' : 'Type 3 - Normal',
      'type4_feces' : 'Type 4 - Normal',
      'type5_feces' : 'Type 5 - Diarrea',
      'type6_feces' : 'Type 6 - Diarrea',
      'type7_feces' : 'Type 7 - Diarrea',
      'type1_feces_exp' : 'Pedazos duros y separados',
      'type2_feces_exp' : 'Forma de salchicha con bultos',
      'type3_feces_exp' : 'Forma de salchicha, con rajaduras en la superficie',
      'type4_feces_exp' : 'Suave y blanda',
      'type5_feces_exp' : 'Pedazos blandos con bordes',
      'type6_feces_exp' : 'Pedazos blandos con bordes deshechos',
      'type7_feces_exp' : 'Sin trozos sólidos.Enteramente líquido',
      'good_hydration' : 'Buena hidratación',
      'mild_dehydration' : 'Deshidratación leve',
      'medium_dehydration' : 'Deshidratación media',
      'high_dehydration' : 'Deshidratación alta',
      'height_cm' : 'Altura (cm)',
      'weight_kg':'Peso (kg)',
      'height_feet' : 'Altura (Pulgadas)',
      'weight_lb':'Peso (lb)',
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