import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/bloc/macro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/view/macro_nutrients_detail.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/macro_nutrient_detail_widget.dart';

import '../bloc/bloc_test_mocks.mocks.dart';
import 'test_navigation_helpers.dart';

/// AC-1.3 (B2, protein workstream): the macronutrients detail screen shows
/// the localized protein texts for the `proteinLabel` macro, and no macro
/// card ever renders an empty title. Guards against the view's officialName
/// gate drifting out of sync with the macro lists emitted by the blocs
/// (which are pinned to proteinLabel in the bloc tests).
void main() {
  setUpAll(() {
    // MealTime names in the bottom navbar use the helper singleton.
    AppLocalizationsHelperDelegate.instance =
        AppLocalizationsHelper(const Locale('en'));
  });

  // Suppress overflow errors. The navbar is designed for real device widths.
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });
  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  // Master fixture with the user-facing names proteinLabel carries after the
  // B3 master-file rename ("Proteínas"/"Protein").
  final masterFixture = NutrientsInfoMaster(nutrientsInfo: [
    NutrientInfoMaster(
        officialName: 'proteinLabel', unit: 'g', en: 'Protein', es: 'Proteínas'),
    NutrientInfoMaster(
        officialName: 'carbsAvailable',
        unit: 'g',
        en: 'Carbohydrates',
        es: 'Hidratos de carbono'),
    NutrientInfoMaster(officialName: 'fatTotal', unit: 'g', en: 'Fat', es: 'Grasas'),
  ]);

  // Builds the macros list the way the dashboard blocs do: one NutrientsModel
  // per key in the production macro list, master info looked up by key.
  List<NutrientsModel> macrosFromMaster() {
    NutrientInfoMaster lookup(String officialName) =>
        masterFixture.nutrientsInfo.firstWhere(
          (info) => info.officialName == officialName,
          orElse: () =>
              NutrientInfoMaster(officialName: officialName, unit: '', en: '', es: ''),
        );

    return ['proteinLabel', 'carbsAvailable', 'fatTotal']
        .map((macro) => NutrientsModel(
              quantityConsumed: 10.0,
              nutrientInfoMaster: lookup(macro),
              fractionToFill: 0.5,
              unit: 'g',
              rda: 100,
              upperLimit: 100,
            ))
        .toList();
  }

  Future<MacroNutrientsDetailBloc> pumpScreen(
    WidgetTester tester, {
    required Locale locale,
  }) async {
    setPhoneSurface(tester);

    final masterInteractor = MockGetMasterFileInteractor();
    when(masterInteractor.execute(MasterFilesType.nutrientsInfo))
        .thenAnswer((_) async => masterFixture);
    final profileInteractor = MockGetProfileInteractor();
    when(profileInteractor.execute())
        .thenAnswer((_) async => UserProfileModel(userId: 'user1', kcal: 2000));

    final bloc = MacroNutrientsDetailBloc(
      getMasterFileInteractor: masterInteractor,
      getProfileInteractor: profileInteractor,
      getWeekFoodEventsInteractor: MockGetWeekFoodEventsInteractor(),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: BlocProvider<MacroNutrientsDetailBloc>.value(
        value: bloc,
        child: const MacroNutrientsDetailScreen(),
      ),
    ));
    // Let the post-frame InitializeEventAction run (shows and hides the
    // loading overlay), then load the macros list like the dashboard does.
    await tester.pump();
    await tester.pump();
    bloc.add(LoadMacroNutrientsEventAction(macronutrientsList: macrosFromMaster()));
    await tester.pump();
    await tester.pump();

    return bloc;
  }

  void expectNoEmptyCardTexts(WidgetTester tester) {
    final cardTexts = tester.widgetList<Text>(find.descendant(
      of: find.byType(MacroNutrientDetailWidget),
      matching: find.byType(Text),
    ));
    expect(cardTexts, isNotEmpty);
    for (final text in cardTexts) {
      expect(text.data, isNotNull);
      expect(text.data!.trim(), isNotEmpty,
          reason: 'A macro card rendered an empty text (AC-1.3: the protein '
              'title must never be blank)');
    }
  }

  testWidgets('shows "Protein" title and localized description in English',
      (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // Card title (from the master lookup) plus the weekly graphic label.
    expect(
      find.descendant(
        of: find.byType(MacroNutrientDetailWidget),
        matching: find.text('Protein'),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.protein), findsOneWidget);
    expectNoEmptyCardTexts(tester);
  });

  testWidgets('shows "Proteínas" title and localized description in Spanish',
      (tester) async {
    await pumpScreen(tester, locale: const Locale('es'));

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(
      find.descendant(
        of: find.byType(MacroNutrientDetailWidget),
        matching: find.text('Proteínas'),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.protein), findsOneWidget);
    expectNoEmptyCardTexts(tester);
  });
}
