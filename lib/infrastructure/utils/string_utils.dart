String getNutrientName(String translatedName) {
  if (!translatedName.contains(',')) return translatedName;
  return translatedName.split(',')[0];
}