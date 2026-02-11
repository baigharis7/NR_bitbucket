import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/bloc/energy_balance_detail_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetWeekFoodEventsInteractor mockFoodEvents;
  late MockGetWeekLiquidEventsInteractor mockLiquidEvents;
  late MockGetWeekSportsInteractor mockSportEvents;
  late MockGetProfileInteractor mockProfile;

  setUp(() {
    mockFoodEvents = MockGetWeekFoodEventsInteractor();
    mockLiquidEvents = MockGetWeekLiquidEventsInteractor();
    mockSportEvents = MockGetWeekSportsInteractor();
    mockProfile = MockGetProfileInteractor();
  });

  EnergyBalanceDetailBloc _buildBloc() => EnergyBalanceDetailBloc(
        getWeekFoodEventsInteractor: mockFoodEvents,
        getWeekLiquidEventsInteractor: mockLiquidEvents,
        getWeekSportsInteractor: mockSportEvents,
        getProfileInteractor: mockProfile,
      );

  void _stubDefaults({
    List<FoodEventComplete>? food,
    List<FoodEventComplete>? liquid,
    List<SportEventComplete>? sport,
    UserProfileModel? profile,
  }) {
    when(mockFoodEvents.execute()).thenAnswer((_) async => food ?? []);
    when(mockLiquidEvents.execute()).thenAnswer((_) async => liquid ?? []);
    when(mockSportEvents.execute()).thenAnswer((_) async => sport ?? []);
    when(mockProfile.execute()).thenAnswer(
      (_) async => profile ?? (UserProfileModel()..kcal = 2000),
    );
  }

  group('EnergyBalanceDetailBloc', () {
    blocTest<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
      'initial state has isLoading false',
      build: () {
        _stubDefaults();
        return _buildBloc();
      },
      verify: (bloc) {
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.weeklyFoodEvents, isNull);
      },
    );

    blocTest<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
      'InitializeEventAction emits loading true then false',
      build: () {
        _stubDefaults();
        return _buildBloc();
      },
      act: (bloc) => bloc.add(InitializeEventAction()),
      expect: () => [
        isA<EnergyBalanceDetailState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<EnergyBalanceDetailState>()
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
      'InitializeEventAction calls all 4 interactors',
      build: () {
        _stubDefaults();
        return _buildBloc();
      },
      act: (bloc) => bloc.add(InitializeEventAction()),
      verify: (bloc) {
        verify(mockFoodEvents.execute()).called(1);
        verify(mockLiquidEvents.execute()).called(1);
        verify(mockSportEvents.execute()).called(1);
        verify(mockProfile.execute()).called(1);
      },
    );

    blocTest<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
      'consumedKcal sums food + liquid event kcals',
      build: () {
        _stubDefaults(
          food: [
            FoodEventComplete(eventKcals: 500, eventDate: 1700000000),
            FoodEventComplete(eventKcals: 300, eventDate: 1700000000),
          ],
          liquid: [
            FoodEventComplete(eventKcals: 150, eventDate: 1700000000),
          ],
        );
        return _buildBloc();
      },
      act: (bloc) => bloc.add(InitializeEventAction()),
      verify: (bloc) {
        expect(bloc.state.averageConsumedKcal, 950.0);
      },
    );

    blocTest<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
      'spentKcal sums sport event kcals',
      build: () {
        _stubDefaults(
          sport: [
            SportEventComplete(
                userId: 'u1', eventId: 1, eventDate: 0, info: [],
                eventKcals: 200),
            SportEventComplete(
                userId: 'u1', eventId: 2, eventDate: 0, info: [],
                eventKcals: 350),
          ],
        );
        return _buildBloc();
      },
      act: (bloc) => bloc.add(InitializeEventAction()),
      verify: (bloc) {
        expect(bloc.state.averageSpentKcal, 550.0);
      },
    );

    blocTest<EnergyBalanceDetailBloc, EnergyBalanceDetailState>(
      'LoadEnergyBalanceEventAction sets energyModel',
      build: () {
        _stubDefaults();
        return _buildBloc();
      },
      act: (bloc) => bloc.add(LoadEnergyBalanceEventAction(
        energyModel: EnergyModel(
          fractionToFill: 0.8,
          totalKcal: 2000,
          rawKcalTaken: 1600,
          spentKcal: 300,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.energyModel, isNotNull);
        expect(bloc.state.energyModel!.totalKcal, 2000);
        expect(bloc.state.energyModel!.rawKcalTaken, 1600);
      },
    );
  });
}
