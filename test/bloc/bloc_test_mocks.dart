import 'package:mockito/annotations.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';

@GenerateNiceMocks([
  // FoodBloc
  MockSpec<GetMasterFileInteractor>(),
  // SettingsBloc
  MockSpec<SignOutInteractor>(),
  MockSpec<EraseDatabaseInteractor>(),
  // EnergyBalanceDetailBloc
  MockSpec<GetWeekFoodEventsInteractor>(),
  MockSpec<GetWeekLiquidEventsInteractor>(),
  MockSpec<GetWeekSportsInteractor>(),
  MockSpec<GetProfileInteractor>(),
  // FavoriteFoodsBloc
  MockSpec<GetFoodFavoritesInteractor>(),
  MockSpec<GetUserIdInteractor>(),
  MockSpec<DeleteFoodFavoriteInteractor>(),
  MockSpec<RemoveFoodFavoriteFromLocalInteractor>(),
  MockSpec<IsNecessaryToShowExplainingCardInteractor>(),
  MockSpec<SaveExplainingCardInteractionInteractor>(),
])
void main() {}
