// TODO: Add deserialization tests for all API response models against real JSON payloads.
//
// These tests should verify that the Dart models correctly parse actual API/S3 JSON,
// catching field-name mismatches (e.g. snake_case vs camelCase) that unit tests
// with hand-constructed Dart objects will miss.
//
// Models to cover:
//   - SupplementsInfoResponse        (supplementsInfo master file — computer_name field)
//   - NutrientsInfoResponse           (nutrientsInfo master file)
//   - SportsInfoResponse              (sportsInfo master file)
//   - FoodsAndDrinksNamesResponse     (foodsAndDrinksNames master file)
//   - ObjectivesInfoResponse          (objectivesInfo master file)
//   - CookingMethodsResponse          (cookingMethods master file)
//   - CookingMethodsInfoResponse      (cookingMethodsInfo master file)
//   - CookingMethodsOilsInfoResponse  (cookingMethodsOilsInfo master file)
//   - ConversionFactorsResponse       (conversionFactors master file)
//   - ConversionFactorsInfoResponse   (conversionFactorsInfo master file)
//   - UnitsInfoResponse               (unitsInfo master file)
//   - UnitsFoodsResponse              (unitsFoods master file)
//   - RecommendationGroupsResponse    (recommendationGroups master file)
//   - SubjectiveAnalysisListResponse  (subjectiveAnalysis master file)
//   - OilTypesResponse                (oilTypes master file)
//   - EventsSynchronizationResponse   (sync endpoint)
//   - MasterFilesResponse             (manage-master-files endpoint — wraps all above)
//
// Approach:
//   1. Capture a real JSON response from each endpoint / S3 file
//   2. Store as fixture files in test/fixtures/
//   3. Deserialize with Model.fromJson() and assert key fields are non-null
//   4. Round-trip test: fromJson → toJson → fromJson and verify equality
