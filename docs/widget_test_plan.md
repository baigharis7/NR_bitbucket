# Widget Navigation Test Plan

> Plan for adding comprehensive widget-level navigation tests using `flutter_test` (no device required).

## Approach

Each test:
1. Wraps a navigation-source widget (navbar, screen, dashboard widget) in a `MaterialApp`
2. Provides a route map with **stub destination screens** (rendering a single `Text` with the route name)
3. Taps the trigger
4. Verifies the destination screen renders OR `Navigator` was called with the right route + args

Pattern reference: `test/widget/calendar_pane_screen_test.dart` (already does this for the close button).

## Common test harness

We'll create `test/widget/test_navigation_helpers.dart` with:
- `buildAppWithRoutes(home, routesNeeded)` — creates a `MaterialApp` with all relevant routes mapped to a `Text` stub showing the route name
- `expectNavigatedTo(routeName)` — asserts the stub destination is rendered
- `expectArgumentsPushed(predicate)` — asserts arguments matched

This avoids re-mounting full screens (which would need full DI scaffolding) while still verifying navigation wiring.

## Test files to add

### 1. `bottom_navbar_widget_test.dart` (~10 tests)
Source: `lib/presentation/widgets/custom_bottom_navi_bar_widget.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Dashboard tab navigates | tap "Start" icon | `DashboardScreen.routeName` (with `pushNamedAndRemoveUntil`) |
| Dashboard tab is no-op when already on dashboard | tap when route name == DashboardScreen | no nav |
| Hamburger toggles menu open | tap menu icon | menu items visible |
| Plus button toggles overlay | tap + | overlay visible |
| Plus button toggles closed when re-tapped | tap + twice | overlay hidden |
| Scrim dismisses plus menu | tap scrim | overlay hidden |
| Scrim dismisses hamburger menu | tap scrim | overlay hidden |
| Plus opening closes hamburger | open menu, then tap + | menu closed |
| Hamburger opening closes plus | open +, then tap menu | + closed |

### 2. `bottom_navbar_plus_menu_test.dart` (~7 tests)
Source: same file, plus menu items

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Breakfast | tap Breakfast in + menu | `AddFoodEventScreen.routeName` with `FoodArgumentsModel(mealTime: Breakfast)` |
| Lunch | tap Lunch | `AddFoodEventScreen.routeName` with Lunch |
| Dinner | tap Dinner | `AddFoodEventScreen.routeName` with Dinner |
| Snack | tap Snack | `AddFoodEventScreen.routeName` with Snack |
| Supplements | tap Supplements | `SupplementsScreen.routeName` |
| Physical Activity | tap Physical Activity | `AddSportEventScreen.routeName` with selectedDateTime arg |
| Feces/Urine | tap Feces/Urine | `FecesUrineTabs.routeName` |

### 3. `bottom_navbar_hamburger_menu_test.dart` (~5 tests)
Source: same file, hamburger menu items

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Routines | tap Routines | `RoutinesTabHolder.routeName` |
| Favorites | tap Favorites | `FavoritesTabHolder.routeName` |
| Tips | tap Tips | `RecommendationsTabHolder.routeName` |
| Recipes | tap Recipes | `RecipesTabsHolder.routeName` |
| Profile | tap Profile | `ProfileScreen.routeName` |

### 4. `meal_time_section_widget_test.dart` (~9 tests)
Source: `lib/presentation/widgets/meal_time_section.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Breakfast card tap | tap card | `MealTimeDetailScreen.routeName` w/ Breakfast |
| Breakfast + button | tap + on card | `AddFoodEventScreen.routeName` w/ Breakfast |
| Lunch card tap | tap card | `MealTimeDetailScreen.routeName` w/ Lunch |
| Lunch + | tap + | `AddFoodEventScreen.routeName` w/ Lunch |
| Dinner card tap | tap card | `MealTimeDetailScreen.routeName` w/ Dinner |
| Dinner + | tap + | `AddFoodEventScreen.routeName` w/ Dinner |
| Snack card tap | tap card | `MealTimeDetailScreen.routeName` w/ Snack |
| Snack + | tap + | `AddFoodEventScreen.routeName` w/ Snack |
| Selected date passed through | tap with non-default selectedDateTime | argument matches |

### 5. `micro_nutrients_section_widget_test.dart` (~2 tests)
Source: `lib/presentation/widgets/micro_nutrients_section.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap section | tap micronutrients section | `MicroNutrientsDetailScreen.routeName` |
| Selected date is passed in arguments | tap with date | arguments contain selectedDate |

### 6. `dashboard_supplements_card_nav_test.dart` (~3 tests)
Source: dashboard supplements card region

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap card body | tap card | `SupplementsDetailScreen.routeName` |
| Tap + button | tap + on card | `SupplementsScreen.routeName` |
| Tap creatine toggle | tap | (no nav, fires action — covered in BLoC) |

### 7. `dashboard_water_widget_nav_test.dart` (~2 tests)
Source: dashboard water widget

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap water info icon | tap | `LiquidSummaryDetailScreen.routeName` |
| Tap + or - | tap | (no nav — covered in widget tests already) |

### 8. `dashboard_activity_log_nav_test.dart` (~3 tests)
Source: activity_log_widget

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap log row | tap card | `SportItemsScreen.routeName` |
| Tap + button | tap + | `AddSportEventScreen.routeName` |
| Tap health sync prompt | tap | `HealthSyncSettingsScreen.routeName` |

### 9. `dashboard_feces_urine_card_nav_test.dart` (~2 tests)
Source: dashboard depositions card

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap item card | tap | `FecesUrineTabHolder.routeName` |
| Tap + button | tap + | `FecesUrineTabs.routeName` |

### 10. `profile_screen_nav_test.dart` (~6 tests)
Source: `lib/presentation/profile/profile/view/profile_screen.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Settings icon | tap | `SettingsScreen.routeName` |
| Profile update | tap profile card edit | `GeneralQuestionsScreen.routeName` |
| Objectives tap | tap objectives | `ObjectivesProfileScreen.routeName` |
| Health tap | tap health | `HealthQuestionsScreen.routeName` |
| Diet tap | tap diet | `DietQuestionsScreen.routeName` |
| Physical activity tap | tap PA | `PhysicalActivityScreen.routeName` |

### 11. `settings_screen_nav_test.dart` (~3 tests)
Source: `lib/presentation/settings/view/settings_screen.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Health Sync link | tap | `HealthSyncSettingsScreen.routeName` |
| Privacy Policy link | tap | `PolicyScreen.routeName` |
| Log out | tap | (BLoC action — covered) |

### 12. `favorites_tabs_nav_test.dart` (~5 tests)
Source: `lib/presentation/favoritestabs/view/*.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Meal tab + | tap + | `AddFoodFavoriteScreen.routeName` |
| Sport tab + | tap + | `AddSportEventScreen.routeName` (with preSelectFavorite) |
| Supplement tab + | tap + | `SupplementsScreen.routeName` (with preSelectFavorite arg) |
| Sport tab create new | tap "Create new" | `CreateNewSportFavoriteScreen.routeName` |
| Meal tab create new | tap "Create new" | `CreateNewFoodFavoriteScreen.routeName` |

### 13. `routines_screen_nav_test.dart` (~3 tests)
Source: `lib/presentation/routines/view/routines_screen.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Add new sport routine | tap + | `AddSportEventScreen.routeName` |
| Edit sport routine | tap edit on item | `AddSportEventScreen.routeName` w/ routine arg |
| Add food routine (similar) | tap | `AddFoodEventScreen.routeName` |

### 14. `meal_time_details_nav_test.dart` (~3 tests)
Source: `lib/presentation/mealtimedetails/view/meal_time_details_screen.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap food item edit | tap item | `ItemUpdateScreen.routeName` w/ food arg |
| Tap back | tap back | Navigator.pop |
| Tap delete cancel | tap cancel in delete dialog | dialog dismissed |

### 15. `micro_nutrients_detail_nav_test.dart` (~3 tests)
Source: `lib/presentation/micronutrients_detail/view/micro_nurtrients_detail_screen.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Tap weekly graph icon (regular) | tap | `MicroNutrientsWeeklyScreen.routeName` |
| Tap weekly graph icon (temporary) | tap | `MicroNutrientsWeeklyScreen.routeName` with temporary list |
| Tap back arrow | tap | Navigator.pop |

### 16. `journal_screens_nav_test.dart` (~3 tests)
Source: `lib/presentation/journal/view/*.dart`

| Test | Trigger | Expected destination |
|------|---------|---------------------|
| Journal Liquid → Add Liquid | tap add | `AddLiquidEventScreen.routeName` |
| Journal Sport → Pop | tap back | Navigator.pop |
| Journal Food → Add Food | tap add | `AddFoodEventScreen.routeName` |

## Total: ~70 navigation widget tests across 16 files

## Estimated impact on AUTO coverage

Will move many MANUAL tags → AUTO:
- All NAV-* (16 cases)
- DASH-07, DASH-09 to DASH-15, DASH-20, DASH-22 to DASH-23, DASH-26 to DASH-28 (~14 cases)
- FOOD-01, FOOD-19 (2 cases)
- SUP-01, SUP-09 (2 cases)
- SPORT-01, SPORT-09, SPORT-10 (3 cases)
- FU-01 (1 case)
- NUT-01, NUT-04, NUT-05, NUT-14 (4 cases)
- FAV-01, FAV-04, FAV-05, FAV-07, FAV-10 (5 cases)
- ROU-01, ROU-04, ROU-09, ROU-10 (4 cases)
- PROF-01, PROF-03 to PROF-08, PROF-11 to PROF-13, PROF-15 to PROF-17 (~11 cases)
- LIQ-03, LIQ-06 (2 cases)
- JRNL-01, JRNL-06, JRNL-10 (3 cases)
- RCPE-01, RCPE-02, RCPE-04, RCPE-08, RCPE-09 (5 cases)

**Estimated +60 cases moving to AUTO** → 119 (41%) → ~179 (63%).

## Strategy for difficult screens

Some screens (Dashboard, Profile, MealTimeDetails) require BLoC providers. For these:
- Either provide mock BLoC instances via `BlocProvider.value`
- Or extract the navigation triggers into stateless widgets where possible (preferred but more invasive)
- Or skip rendering the full screen and just test the widget that contains the nav trigger (simplest)

We'll prefer the third approach where possible — test individual nav-emitting widgets in isolation.
