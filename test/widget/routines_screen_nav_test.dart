import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/routines/bloc/routines_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/routines/view/routines_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';

import '../bloc/bloc_test_mocks.mocks.dart';
import 'test_navigation_helpers.dart';

/// Full-screen navigation tests for [RoutinesScreen]. Uses a real
/// [RoutinesBloc] with mocked interactors so the bloc can answer the
/// initialization fetch but the destination screens are stubbed.
void main() {
  late MockGetRoutinesInteractor mockGetRoutines;
  late MockGetUserIdInteractor mockGetUserId;
  late MockDeleteSportRoutineInteractor mockDeleteRoutine;
  late MockRemoveSportRoutineInteractor mockRemoveRoutine;
  late MockUploadSportFavoriteInteractor mockUploadFavorite;
  late MockSaveSportFavoriteInteractor mockSaveFavorite;
  late MockDeleteSportFavoriteInteractor mockDeleteFavorite;
  late MockRemoveSportFavoriteInteractor mockRemoveFavorite;
  late MockGetSportFavoritesInteractor mockGetFavorites;

  setUp(() {
    mockGetRoutines = MockGetRoutinesInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockDeleteRoutine = MockDeleteSportRoutineInteractor();
    mockRemoveRoutine = MockRemoveSportRoutineInteractor();
    mockUploadFavorite = MockUploadSportFavoriteInteractor();
    mockSaveFavorite = MockSaveSportFavoriteInteractor();
    mockDeleteFavorite = MockDeleteSportFavoriteInteractor();
    mockRemoveFavorite = MockRemoveSportFavoriteInteractor();
    mockGetFavorites = MockGetSportFavoritesInteractor();

    // Default stubs so the screen initializes cleanly
    when(mockGetRoutines.execute())
        .thenAnswer((_) async => <SportRoutineCompleted>[]);
    when(mockGetFavorites.execute())
        .thenAnswer((_) async => <AddSportFavorite>[]);
    when(mockGetUserId.execute()).thenReturn('user123');
  });

  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });
  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  Widget buildHarness(NavRecorder recorder) {
    final bloc = RoutinesBloc(
      getRoutinesInteractor: mockGetRoutines,
      getUserIdInteractor: mockGetUserId,
      deleteSportRoutineInteractor: mockDeleteRoutine,
      removeSportRoutineInteractor: mockRemoveRoutine,
      uploadSportFavoriteInteractor: mockUploadFavorite,
      saveSportFavoriteInteractor: mockSaveFavorite,
      deleteSportFavoriteInteractor: mockDeleteFavorite,
      removeSportFavoriteInteractor: mockRemoveFavorite,
      getSportFavoritesInteractor: mockGetFavorites,
    );
    return BlocProvider<RoutinesBloc>.value(
      value: bloc,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        routes: {
          AddSportEventScreen.routeName: (_) => Scaffold(
                key: Key('stub:${AddSportEventScreen.routeName}'),
                body: const Text('add-sport'),
              ),
        },
        navigatorObservers: [recorder],
        home: const RoutinesScreen(),
      ),
    );
  }

  SportRoutineCompleted stubRoutine({String name = 'Morning Run'}) {
    return SportRoutineCompleted(
      userId: 'user123',
      eventId: 1,
      eventDate: 1700000000000,
      sportName: name,
      info: [],
      isRoutine: true,
      daysOfWeek: [1, 3, 5],
      scheduleTime: '07:00',
    );
  }

  group('RoutinesScreen navigation', () {
    testWidgets('renders header with Routines title', (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      await tester.pumpWidget(buildHarness(NavRecorder()));
      await tester.pumpAndSettle();

      expect(find.text('Routines'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('Add button navigates to AddSportEventScreen', (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, AddSportEventScreen.routeName);
      // No arguments for plain "+ Add" tap
      expect(recorder.lastArguments, isNull);
    });

    testWidgets(
        'Edit on routine item navigates to AddSportEventScreen with routine arg',
        (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      final routine = stubRoutine(name: 'Yoga');
      when(mockGetRoutines.execute())
          .thenAnswer((_) async => [routine]);

      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      // Routine is shown
      expect(find.text('Yoga'), findsOneWidget);

      // CalenderEventListItem renders an edit icon. Find the row's edit
      // button — the icon is Icons.edit.
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expectNavigated(recorder, AddSportEventScreen.routeName);
      expect(recorder.lastArguments, routine);
    });

    testWidgets('back arrow pops the screen', (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      var popped = false;
      final bloc = RoutinesBloc(
        getRoutinesInteractor: mockGetRoutines,
        getUserIdInteractor: mockGetUserId,
        deleteSportRoutineInteractor: mockDeleteRoutine,
        removeSportRoutineInteractor: mockRemoveRoutine,
        uploadSportFavoriteInteractor: mockUploadFavorite,
        saveSportFavoriteInteractor: mockSaveFavorite,
        deleteSportFavoriteInteractor: mockDeleteFavorite,
        removeSportFavoriteInteractor: mockRemoveFavorite,
        getSportFavoritesInteractor: mockGetFavorites,
      );
      await tester.pumpWidget(BlocProvider<RoutinesBloc>.value(
        value: bloc,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const RoutinesScreen()),
                  ).then((_) => popped = true);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });
}
