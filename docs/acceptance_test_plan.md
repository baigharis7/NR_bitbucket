# NutRenaissance - Acceptance Test Plan

| Field | Value |
|-------|-------|
| **Document Version** | 1.0 |
| **Date** | 2026-04-08 |
| **App Name** | NutRenaissance |
| **Prepared By** | |

---

## Pre-Conditions

Before starting testing, ensure the following are in place:

| # | Requirement | Details |
|---|-------------|---------|
| 1 | **Test accounts** | Two accounts: one fresh (never logged in), one with existing data (food events, favorites, routines) |
| 2 | **Devices** | At least one Android device (with Health Connect installed) and/or one iOS device (with HealthKit) |
| 3 | **Network control** | Ability to toggle airplane mode for offline testing |
| 4 | **Test barcodes** | One known food product barcode, one invalid/unknown barcode |
| 5 | **Second device** | For cross-device sync verification (same account logged in on two devices) |
| 6 | **Language** | Device set to English; optionally a second device/config set to Spanish for locale testing |

---

## Test Environment

*Fill in before starting each test run:*

| Field | Value |
|-------|-------|
| **Tester Name** | |
| **Date** | |
| **App Version** | |
| **Build Number** | |
| **Device Model** | |
| **OS / Version** | |
| **Network** | Wi-Fi / Mobile Data / Mixed |
| **Language** | EN / ES |

---

## Status Legend

| Status | Meaning |
|--------|---------|
| **Pass** | Works as expected |
| **Fail** | Does not work as expected — describe in Notes |
| **Blocked** | Cannot test due to a dependency — describe in Notes |
| **Skip** | Intentionally skipped — describe reason in Notes |

---

## Section 1: Authentication & Onboarding

### 1.1 Splash & Login

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| AUTH-01 | Cold launch the app (kill process first) | Splash screen appears briefly, then transitions to Login screen (or Dashboard if already logged in) | | |
| AUTH-02 | On Login screen, enter valid email and password, tap Sign In | App navigates to Dashboard. User's name visible in greeting | | |
| AUTH-03 | On Login screen, enter invalid email/password, tap Sign In | Error message appears. User stays on Login screen | | |
| AUTH-04 | On Login screen, leave email or password empty, tap Sign In | Validation error shown for empty fields | | |
| AUTH-05 | On Login screen, tap "Sign Up" toggle. Fill all fields (name, email, password, confirm password). Check privacy policy checkbox. Tap Sign Up | Account created. Navigates to Welcome screen | | |
| AUTH-06 | On Sign Up, fill all fields but do NOT check privacy policy checkbox. Tap Sign Up | Submission is blocked. Privacy policy checkbox required | | |
| AUTH-07 | On Sign Up, enter mismatched passwords. Tap Sign Up | Error message about password mismatch | | |
| AUTH-08 | On Login screen, tap "Forgot Password?" link | Navigates to Forgotten Password screen | | |

### 1.2 Password Reset

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| AUTH-09 | On Forgotten Password screen, enter registered email, tap Submit | Confirmation code sent. Screen shows code entry field | | |
| AUTH-10 | Enter valid confirmation code and new password on Reset Password screen, tap Submit | Password reset successful. Navigates to Login or Dashboard | | |

### 1.3 Onboarding (New User)

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| AUTH-11 | After first sign-up, observe Welcome screen. Tap Continue | Navigates to Health Sync Onboarding screen | | |
| AUTH-12 | On Health Sync Onboarding, tap "Connect" | Device health permissions requested (Health Connect / HealthKit) | | |
| AUTH-13 | On Health Sync Onboarding, tap "Skip" instead | Proceeds to Registry screen without health sync | | |
| AUTH-14 | On Registry screen, fill General Questions (name, DOB, sex, height, weight). Tap Next/Save | Data saved. Advances to next section | | |
| AUTH-15 | Fill Health Questions (medical conditions, pharmaceutical status). Tap Next/Save | Data saved. Advances to next section | | |
| AUTH-16 | Fill Diet Questions (diet type, intolerances, allergens). Tap Next/Save | Data saved. Advances to next section | | |
| AUTH-17 | Fill Physical Activity level. Tap Next/Save | Data saved. Objectives dialog appears | | |
| AUTH-18 | Select objectives in Objectives dialog. Confirm | Objectives saved. Navigates to Dashboard | | |

---

## Section 2: Dashboard

### 2.1 Dashboard Layout & Data Display

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| DASH-01 | After login, observe Dashboard screen | Dashboard loads with user greeting, all sections visible | | |
| DASH-02 | Observe the week calendar at the top | Current week shown, today's date is highlighted/selected | | |
| DASH-03 | Tap a different day in the week calendar | Dashboard reloads data for the selected day | | |
| DASH-04 | Observe Nutrition Progress widget | Shows kcal consumed out of daily goal. Circular or bar progress | | |
| DASH-05 | Observe macro nutrient bars below progress | Protein, Carbs, Fat bars shown with percentages/amounts | | |
| DASH-06 | Observe Micro Nutrients section | Nutrient bars shown with RDA percentages | | |
| DASH-07 | Tap on the Micro Nutrients section | Navigates to Micro Nutrients Detail screen | | |

### 2.2 Meal Sections

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| DASH-08 | Observe Breakfast card on dashboard | Shows breakfast foods logged today (or empty state) with calorie total | | |
| DASH-09 | Tap Breakfast card | Navigates to Meal Time Details screen for Breakfast | | |
| DASH-10 | Tap Lunch card | Navigates to Meal Time Details screen for Lunch | | |
| DASH-11 | Tap Dinner card | Navigates to Meal Time Details screen for Dinner | | |
| DASH-12 | Tap Snack card | Navigates to Meal Time Details screen for Snack | | |

### 2.3 Supplements

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| DASH-13 | Observe Supplements card on dashboard | Shows supplements taken today (or empty state) | | |
| DASH-14 | Tap Supplements card | Navigates to Supplements Detail screen | | |
| DASH-15 | Tap "+" icon on Supplements card | Navigates to Supplements screen (add new) | | |

### 2.4 Water & Hydration

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| DASH-16 | Observe Water Intake widget | Shows current water count / glasses | | |
| DASH-17 | Tap "+" on water widget | Water count increments by 1 glass (0.25L) | | |
| DASH-18 | Tap "-" on water widget | Water count decrements by 1 glass | | |
| DASH-19 | Tap "-" when water is already at 0 | Water count does not go below 0 | | |
| DASH-20 | Tap the water info/detail icon | Navigates to Liquid Summary Detail screen | | |

### 2.5 Activity & Health Sync

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| DASH-21 | Observe Activity Log section | Shows sport events logged today (or empty state) | | |
| DASH-22 | Tap "+" on Activity Log section | Navigates to Add Sport Event screen | | |
| DASH-23 | Tap Activity Log area (not the +) | Navigates to Sport Items screen | | |
| DASH-24 | If Health Sync enabled: observe Sleep widget | Sleep hours from device health data displayed | | |
| DASH-25 | If Health Sync enabled: observe Steps widget | Step count from device health data displayed | | |

### 2.6 Feces/Urine & Calendar

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| DASH-26 | Observe Feces/Urine section on dashboard | Card visible with access to deposition tracking | | |
| DASH-27 | Tap Feces/Urine card | Navigates to Feces/Urine Tab Holder | | |
| DASH-28 | Tap Calendar icon in app bar | Navigates to Calendar Pane screen | | |

---

## Section 3: Bottom Navigation & Menus

### 3.1 Plus (+) Menu

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| NAV-01 | Tap the "+" button in bottom navigation bar | Overlay menu appears with food meal times and other options | | |
| NAV-02 | In + menu, tap Breakfast | Navigates to Add Food Event screen with Breakfast pre-selected | | |
| NAV-03 | In + menu, tap Lunch | Navigates to Add Food Event screen with Lunch pre-selected | | |
| NAV-04 | In + menu, tap Dinner | Navigates to Add Food Event screen with Dinner pre-selected | | |
| NAV-05 | In + menu, tap Snack | Navigates to Add Food Event screen with Snack pre-selected | | |
| NAV-06 | In + menu, tap Supplements | Navigates to Supplements screen | | |
| NAV-07 | In + menu, tap Physical Activity | Navigates to Add Sport Event screen | | |
| NAV-08 | In + menu, tap Feces/Urine | Navigates to Feces/Urine Tabs screen | | |

### 3.2 Hamburger Menu

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| NAV-09 | Tap hamburger menu icon in bottom navigation | Menu overlay opens with: Routines, Favorites, Tips, Recipes, Profile | | |
| NAV-10 | Tap Routines | Navigates to Routines Tab Holder | | |
| NAV-11 | Tap Favorites | Navigates to Favorites Tab Holder | | |
| NAV-12 | Tap Tips | Navigates to Recommendations Tab Holder | | |
| NAV-13 | Tap Recipes | Navigates to Recipes Tab Holder | | |
| NAV-14 | Tap Profile | Navigates to Profile screen | | |

### 3.3 General Navigation

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| NAV-15 | Tap "Start" / Home button in bottom nav from any screen | Navigates back to Dashboard | | |
| NAV-16 | Tap outside an open menu overlay (scrim area) | Menu dismisses | | |

---

## Section 4: Food Events

### 4.1 Add Food Event

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FOOD-01 | Navigate to Add Food Event (via + menu or meal card). Observe screen | Correct meal type icon/label shown. Search field visible | | |
| FOOD-02 | Type a food name in search field | Autocomplete results appear from food database | | |
| FOOD-03 | Select a food from search results | Food selected. Quantity and unit fields appear | | |
| FOOD-04 | Set quantity (e.g., 100g). Observe nutrient info card | Nutrient breakdown updates to reflect quantity | | |
| FOOD-05 | Tap Save/Add button | Confirmation shown. Returns to previous screen | | |
| FOOD-06 | Return to Dashboard, observe the meal section | Saved food appears in correct meal section with calories | | |
| FOOD-07 | On Add Food Event, toggle to "Recent" items tab | Previously logged foods shown | | |
| FOOD-08 | On Add Food Event, toggle to "Favorites" tab | User's food favorites shown | | |
| FOOD-09 | Tap a food favorite to select it, then save | Food event created from favorite. Returns to previous screen | | |
| FOOD-10 | Set quantity to 0 or leave empty, tap Save | Validation error. Event not saved | | |

### 4.2 Food Scanner

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FOOD-11 | On Add Food Event, tap scanner/camera icon | Camera opens (permission requested if first time). Scanner screen shown | | |
| FOOD-12 | Point camera at a known food product barcode | Barcode detected. Food info retrieved from database | | |
| FOOD-13 | Point camera at an unknown/invalid barcode | Barcode detected but no match. Appropriate message shown | | |
| FOOD-14 | Capture a photo of food for visual recognition | Photo sent for recognition. Food suggestions returned | | |
| FOOD-15 | From scanner results, tap "Edit" on a matched food | Returns to Add Food Event screen with food pre-filled | | |
| FOOD-16 | From scanner results, tap "Log" on a matched food | Food event saved directly. Confirmation shown | | |
| FOOD-17 | Enable airplane mode, open food scanner | Offline indicator or message shown | | |

### 4.3 Meal Time Details & Editing

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FOOD-18 | Tap a meal card on Dashboard (with foods logged) | Meal Time Details screen shows all foods for that meal with totals | | |
| FOOD-19 | Tap a food item in Meal Time Details | Opens edit screen (Item Update) for that food | | |
| FOOD-20 | Edit the food quantity, tap Save | Quantity updated. Returns to Meal Time Details with updated values | | |
| FOOD-21 | Tap delete on a food item. Confirm deletion | Food removed. Meal Time Details and Dashboard reflect the change | | |
| FOOD-22 | On Add Food Event, enable "Save as favorite" toggle, then save | Food event saved AND food added to favorites | | |

---

## Section 5: Liquid & Water Events

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| LIQ-01 | On Dashboard, tap "+" on water widget multiple times | Water count increments correctly each time | | |
| LIQ-02 | On Dashboard, tap "-" on water widget | Water count decrements correctly | | |
| LIQ-03 | Tap water detail icon on Dashboard | Navigates to Liquid Summary Detail screen | | |
| LIQ-04 | On Liquid Summary Detail, observe water + liquid breakdown | All water and liquid events for the day shown with totals | | |
| LIQ-05 | On Liquid Summary Detail, tap add water | Water event added. Count updates | | |
| LIQ-06 | Navigate to Add Liquid Event screen | Screen shows liquid type selector and quantity fields | | |
| LIQ-07 | Select a liquid type (e.g., juice, tea), set quantity, save | Liquid event saved. Appears in Liquid Summary Detail | | |
| LIQ-08 | Delete a liquid event from the detail screen | Event removed. Totals update | | |
| LIQ-09 | Verify water goal on dashboard matches profile weight * 0.035L | Goal displayed correctly based on user's weight | | |
| LIQ-10 | Log multiple different liquids, check nutrient contribution on Dashboard | Liquid nutrients (if applicable) contribute to daily totals | | |
| LIQ-11 | On a day with no water/liquid logged, observe water widget | Shows 0 glasses / 0L consumed | | |
| LIQ-12 | Add water from Liquid Summary Detail screen, return to Dashboard | Dashboard water widget reflects the added water | | |

---

## Section 6: Supplements

### 6.1 Add & View Supplements

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SUP-01 | Navigate to Supplements screen (via + menu or supplements card) | Supplement search and selection screen shown | | |
| SUP-02 | Search for a supplement by name | Results appear from master supplement list | | |
| SUP-03 | Select a supplement, set time and quantity, tap Save | Supplement event saved. Confirmation shown | | |
| SUP-04 | Return to Dashboard. Tap Supplements card | Supplements Detail screen shows the saved supplement | | |
| SUP-05 | Toggle to "Recent" on Supplements screen | Recently logged supplements shown | | |
| SUP-06 | Toggle to "Favorites" on Supplements screen | Saved supplement favorites shown | | |
| SUP-07 | Enable "Save as favorite" toggle, then save supplement | Supplement saved AND added to favorites | | |
| SUP-08 | Enable "Save as routine" toggle, set days and time, then save | Supplement saved AND routine created | | |

### 6.2 Edit & Delete Supplements

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SUP-09 | On Supplements Detail, tap a supplement item | Opens Update Supplement screen | | |
| SUP-10 | Edit supplement quantity/time, tap Save | Updated values shown in Supplements Detail | | |
| SUP-11 | Delete a supplement from Update Supplement screen | Supplement removed. Detail and Dashboard reflect removal | | |

### 6.3 Creatine & Collagen Quick Toggles

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SUP-12 | On Dashboard, toggle Creatine ON | Creatine event created for today | | |
| SUP-13 | On Dashboard, toggle Creatine OFF | Creatine event removed for today | | |
| SUP-14 | On Dashboard, toggle Collagen ON | Collagen event created for today | | |
| SUP-15 | On Dashboard, toggle Collagen OFF | Collagen event removed for today | | |

---

## Section 7: Sport / Physical Activity

### 7.1 Add Sport Event

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SPORT-01 | Navigate to Add Sport Event (via + menu or activity log) | Sport search and selection screen shown | | |
| SPORT-02 | Search for a sport/activity by name | Results appear from master sports list | | |
| SPORT-03 | Select a sport, set duration in minutes, tap Save | Sport event saved. Calories burned calculated and shown | | |
| SPORT-04 | Return to Dashboard. Observe Activity Log | Saved sport event appears with duration and kcal burned | | |
| SPORT-05 | Toggle to "Recent" on Add Sport Event screen | Recently logged sports shown | | |
| SPORT-06 | Toggle to "Favorites" on Add Sport Event screen | Saved sport favorites shown | | |
| SPORT-07 | Enable "Save as favorite" toggle, then save sport | Sport saved AND added to favorites | | |
| SPORT-08 | Enable "Save as routine" toggle, set days, then save sport | Sport saved AND routine created | | |

### 7.2 View, Edit & Delete Sport Events

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SPORT-09 | Tap Activity Log on Dashboard to open Sport Items screen | All sport events for the day shown | | |
| SPORT-10 | Tap a sport item to open edit screen | Sport Update screen opens with current values | | |
| SPORT-11 | Edit duration, tap Save | Updated duration and recalculated kcal shown | | |
| SPORT-12 | Delete a sport event, confirm deletion | Sport removed. Dashboard Activity Log updated | | |
| SPORT-13 | Set duration to 0, tap Save | Validation error. Event not saved with 0 duration | | |

---

## Section 8: Feces / Urine Analysis

### 8.1 Feces Tracking

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FU-01 | Navigate to Feces/Urine Tab Holder (from Dashboard or + menu) | Tab holder opens with Feces and Urine tabs | | |
| FU-02 | On Feces tab, observe the form | Bristol scale or stool type selection visible | | |
| FU-03 | Select feces type/characteristics, tap Save | Feces event saved. Entry appears in history below | | |
| FU-04 | Delete a feces event from the list | Event removed from history | | |

### 8.2 Urine Tracking

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FU-05 | Switch to Urine tab | Urine color/characteristic selection visible | | |
| FU-06 | Select urine color/characteristics, tap Save | Urine event saved. Entry appears in history below | | |
| FU-07 | Delete a urine event from the list | Event removed from history | | |

### 8.3 Detail View

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FU-08 | Navigate to Feces/Urine detail view (from Dashboard depositions area) | Detail view shows chart/history of events over time | | |
| FU-09 | Select a different date, observe events | Events for selected date shown | | |
| FU-10 | On a day with no feces/urine logged | Empty state shown (no crash) | | |

---

## Section 9: Nutrient Detail Screens

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| NUT-01 | Tap Macro Nutrients area on Dashboard | Macro Nutrients Detail screen opens with protein, carbs, fat breakdown | | |
| NUT-02 | Verify macro values match foods logged today | Values are consistent with logged food events | | |
| NUT-03 | Tap Micro Nutrients section on Dashboard | Micro Nutrients Detail screen opens with all micronutrients and RDA bars | | |
| NUT-04 | Scroll through micronutrients list | All vitamins and minerals shown with progress towards RDA | | |
| NUT-05 | Navigate to Micro Nutrients Weekly screen | Weekly aggregation of micronutrient data shown | | |
| NUT-06 | Navigate to Energy Balance Detail screen | Ingested kcal vs. burned kcal displayed | | |
| NUT-07 | Verify energy balance accounts for food + sport | Both food intake and sport calories reflected | | |
| NUT-08 | Navigate to Sugar Detail screen | Sugar intake for the day displayed | | |
| NUT-09 | Navigate to Fiber Detail screen | Fiber intake for the day displayed | | |
| NUT-10 | Navigate to Weekly All Nutrients Detail screen | Complete weekly nutrient summary shown | | |
| NUT-11 | Navigate to Weekly Dashboard Detail screen | Weekly summary with daily trends/charts displayed | | |
| NUT-12 | On a day with no food logged, open any nutrient detail screen | Zero values displayed (no crash, no negative numbers) | | |
| NUT-13 | Add a food event, then re-open a nutrient detail screen | Updated nutrient values reflected | | |
| NUT-14 | Tap back/navigate away from each detail screen | Returns to previous screen correctly | | |

---

## Section 10: Favorites

### 10.1 Favorites Tab Navigation

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FAV-01 | Navigate to Favorites Tab Holder (hamburger menu > Favorites) | Tab holder opens | | |
| FAV-02 | Observe available tabs | Three tabs visible: Meal, Physical Activity, Supplements | | |

### 10.2 Meal Favorites

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FAV-03 | Tap Meal tab | List of food favorites shown (grouped by meal time), or empty state | | |
| FAV-04 | Tap a food favorite cluster | Cluster detail screen shows individual items | | |
| FAV-05 | Tap "+" to add a new food favorite | Meal type selection appears, then food search | | |
| FAV-06 | Search and select a food, save as favorite | Food favorite created. Appears in Meal favorites list | | |
| FAV-07 | Tap "Create new" to create a multi-food cluster favorite | Create New Food Favorite screen opens. Add multiple foods, save | | |
| FAV-08 | Delete a food favorite (swipe or delete button) | Favorite removed from list | | |

### 10.3 Physical Activity Favorites

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FAV-09 | Tap Physical Activity tab | List of sport favorites shown, or empty state | | |
| FAV-10 | Tap "+" to add a sport favorite | Sport search screen opens | | |
| FAV-11 | Search and select a sport, save as favorite | Sport favorite created. Appears in list | | |
| FAV-12 | Delete a sport favorite | Favorite removed from list | | |

### 10.4 Supplements Favorites

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FAV-13 | Tap Supplements tab | List of supplement favorites shown, or empty state | | |
| FAV-14 | Delete a supplement favorite | Favorite removed from list | | |

### 10.5 Using Favorites from Event Screens

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| FAV-15 | On Add Food Event screen, toggle to Favorites. Tap a favorite | Food fields pre-filled from favorite data | | |
| FAV-16 | On Add Sport Event screen, toggle to Favorites. Tap a favorite | Sport fields pre-filled from favorite data | | |
| FAV-17 | On Supplements screen, toggle to Favorites. Tap a favorite | Supplement fields pre-filled from favorite data | | |
| FAV-18 | With no favorites saved, toggle to Favorites tab on any add screen | Empty state shown with guidance to create favorites | | |

---

## Section 11: Routines

### 11.1 Routine Tab Navigation

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| ROU-01 | Navigate to Routines Tab Holder (hamburger menu > Routines) | Tab holder opens | | |
| ROU-02 | Observe available tabs | Three tabs: Meal, Workouts, Supplements | | |

### 11.2 Meal Routines

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| ROU-03 | Tap Meal routines tab | List of food routines shown with days of week, or empty state | | |
| ROU-04 | Tap "+" to create a new food routine | Add Food Event screen opens with routine mode | | |
| ROU-05 | Select food, set time, select days of week, save | Food routine created. Appears in Meal routines list | | |
| ROU-06 | Delete a food routine, confirm deletion | Routine removed from list | | |

### 11.3 Workout Routines

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| ROU-07 | Tap Workouts tab | List of sport routines, or empty state | | |
| ROU-08 | Create a sport routine: select sport, set duration, set time, select days, save | Sport routine created. Appears in Workouts list | | |
| ROU-09 | After saving sport routine, observe navigation | Note where the app navigates after save (back to routines list, or elsewhere) | | |
| ROU-10 | Verify routine data appears immediately after save (no need to navigate away) | Routine data visible immediately in the list | | |
| ROU-11 | Delete a sport routine | Routine removed from list | | |

### 11.4 Supplement Routines

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| ROU-12 | Tap Supplements tab | List of supplement routines, or empty state | | |
| ROU-13 | Create a supplement routine: select supplement, set time, select days, save | Supplement routine created. Appears in Supplements list | | |
| ROU-14 | Delete a supplement routine | Routine removed from list | | |

### 11.5 Routine General Behavior

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| ROU-15 | Days-of-week selector: tap individual days on and off | Selected days highlight/unhighlight correctly | | |
| ROU-16 | Create routine with no days selected, try to save | Validation error. Routine not saved without at least one day | | |
| ROU-17 | With no routines saved, observe each routine tab | Empty state shown (no crash) | | |

---

## Section 12: Recommendations

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| REC-01 | Navigate to Recommendations (hamburger menu > Tips) | Recommendations Tab Holder opens | | |
| REC-02 | Observe available tabs | Two tabs: Tips and List (or similar) | | |
| REC-03 | Tap Tips tab | Personalized tips/recommendations load based on user profile | | |
| REC-04 | Tap a tip card (if it links to a recipe or food) | Opens relevant detail (recipe or food info) | | |
| REC-05 | Tap List tab | Food list/recommendations shown, grouped by category | | |
| REC-06 | Verify food list respects user's aversions/exclusions | Foods the user has excluded in profile are not recommended | | |
| REC-07 | With a new user profile (no objectives set), view recommendations | Appropriate content shown or empty state | | |
| REC-08 | Navigate back from Recommendations | Returns to Dashboard | | |

---

## Section 13: Recipes

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| RCPE-01 | Navigate to Recipes (hamburger menu > Recipes) | Recipes Tab Holder opens | | |
| RCPE-02 | Observe available tabs | Discover and Favorites tabs | | |
| RCPE-03 | Tap Discover tab | Recipe cards load | | |
| RCPE-04 | Tap a recipe card | Recipe Detail screen opens | | |
| RCPE-05 | On Recipe Detail, tap Ingredients tab | Ingredient list with quantities shown | | |
| RCPE-06 | On Recipe Detail, tap Steps tab | Cooking steps shown in order | | |
| RCPE-07 | Tap heart/favorite icon on a recipe | Recipe saved to favorites. Heart icon fills | | |
| RCPE-08 | Tap Favorites tab in Recipes | Saved recipe favorites listed | | |
| RCPE-09 | Remove a recipe from favorites (tap heart again or delete) | Recipe removed from favorites list | | |
| RCPE-10 | With no recipe favorites, observe Favorites tab | Empty state shown | | |

---

## Section 14: Journal & Calendar

### 14.1 Journal

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| JRNL-01 | Navigate to Journal screen | Journal opens with Food, Sport, Liquid tabs | | |
| JRNL-02 | Tap Food tab | Food event history shown for selected date | | |
| JRNL-03 | Tap Sport tab | Sport event history shown for selected date | | |
| JRNL-04 | Tap Liquid tab | Liquid event history shown for selected date | | |
| JRNL-05 | Select a different date in Journal | Events update for the selected date | | |
| JRNL-06 | On a day with no events, observe each Journal tab | Empty state shown for each tab | | |

### 14.2 Calendar

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| JRNL-07 | Tap Calendar icon on Dashboard | Calendar Pane screen opens | | |
| JRNL-08 | Observe days with events | Dots or markers shown on days that have logged events | | |
| JRNL-09 | Tap a marked day | Events for that day shown below the calendar | | |
| JRNL-10 | Tap an event in the calendar event list | Opens edit screen for that event | | |
| JRNL-11 | Navigate between months (swipe or arrows) | Calendar month changes. Markers update | | |
| JRNL-12 | Tap today button (if available) or navigate back to current month | Calendar returns to today's date | | |

---

## Section 15: Profile & Settings

### 15.1 Profile Viewing & Editing

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| PROF-01 | Navigate to Profile (hamburger menu > Profile) | Profile screen shows user info cards | | |
| PROF-02 | Observe profile data: name, age, sex, weight, height | All values match what was entered during registration | | |
| PROF-03 | Tap edit on General section | General Questions screen opens. Edit name, tap Save | | |
| PROF-04 | Tap edit on Health section | Health Questions screen opens. Edit conditions, tap Save | | |
| PROF-05 | Tap edit on Diet section | Diet Questions screen opens. Edit preferences, tap Save | | |
| PROF-06 | Tap edit on Physical Activity section | Physical Activity screen opens. Change level, tap Save | | |
| PROF-07 | Tap edit on Objectives section | Objectives dialog opens. Modify objectives, confirm | | |
| PROF-08 | Navigate to Aversions section | Aversions screen opens. Add/remove food aversions | | |
| PROF-09 | Change weight in profile, return to Dashboard | Water goal on Dashboard updates (new weight * 0.035L) | | |
| PROF-10 | Verify profile changes persist after app restart | Kill app, relaunch, navigate to Profile. Changes still there | | |

### 15.2 Settings

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| PROF-11 | Navigate to Settings (from Profile or settings icon) | Settings screen opens with all options | | |
| PROF-12 | Observe available settings | Log Out, Health Sync, Support/Contact, Privacy Policy visible | | |
| PROF-13 | Tap Health Sync | Health Sync Settings screen opens | | |
| PROF-14 | Enable Health Sync toggle | Device health permissions requested | | |
| PROF-15 | Disable Health Sync toggle | Sync disabled. Sleep/Steps widgets disappear from Dashboard | | |
| PROF-16 | Tap Support/Contact (WhatsApp link) | WhatsApp opens (or appropriate link handling) | | |
| PROF-17 | Tap Privacy Policy | Privacy Policy / Policy screen opens with content | | |
| PROF-18 | Tap Log Out | Confirmation dialog appears | | |
| PROF-19 | Confirm Log Out | App navigates to Login screen. Session cleared | | |
| PROF-20 | After logging out, relaunch app | Splash screen → Login screen (not Dashboard) | | |

---

## Section 16: Data Sync & Cross-Device

### 16.1 Basic Sync (Online)

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SYNC-01 | Save a food event while online | Event saves successfully | | |
| SYNC-02 | Log in on a second device with same account | Food event from first device appears on second device | | |
| SYNC-03 | Save a sport event on Device 1, check Device 2 | Sport event syncs to Device 2 | | |
| SYNC-04 | Save water events on Device 1, check Device 2 | Water events sync to Device 2 | | |
| SYNC-05 | Save a supplement event on Device 1, check Device 2 | Supplement event syncs to Device 2 | | |
| SYNC-06 | Save food favorites on Device 1, check Device 2 | Food favorites sync to Device 2 | | |
| SYNC-07 | Save sport favorites on Device 1, check Device 2 | Sport favorites sync to Device 2 | | |
| SYNC-08 | Save a feces event on Device 1, check Device 2 | Feces event syncs to Device 2 | | |

### 16.2 Offline & Recovery

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SYNC-09 | Enable airplane mode. Save a food event | Event saves locally without error | | |
| SYNC-10 | While still offline, observe the saved event on Dashboard | Event appears on Dashboard from local storage | | |
| SYNC-11 | Disable airplane mode. Wait a moment | Queued event syncs automatically to backend | | |
| SYNC-12 | Log in on second device. Verify the offline-saved event appears | Event synced successfully after network restored | | |

### 16.3 Sync Edge Cases

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| SYNC-13 | Save a liquid event on Device 1, check Device 2 | Note whether liquid events appear on Device 2 | | |
| SYNC-14 | Save a recipe favorite on Device 1, check Device 2 | Note whether recipe favorites appear on Device 2 | | |
| SYNC-15 | Save supplement routines on Device 1, check Device 2 | Supplement routines sync to Device 2 | | |
| SYNC-16 | Background the app for 5+ minutes, resume | App syncs data on resume (lifecycle trigger) | | |
| SYNC-17 | Force quit app during a save operation, relaunch | App picks up queued items and syncs on relaunch | | |
| SYNC-18 | Master files update: if a new food database version is available | Update dialog or automatic download triggers on Dashboard load | | |

---

## Section 17: Edge Cases & Regression

### 17.1 Date & Time Boundaries

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| EDGE-01 | Leave app open past midnight | Dashboard refreshes to new date automatically | | |
| EDGE-02 | Background app before midnight, resume after midnight | Date change detected. Dashboard shows new date | | |
| EDGE-03 | On a detail screen (e.g., Meal Time Details) at midnight | Snackbar or notification about date change shown | | |
| EDGE-04 | Select a past date on Dashboard, add a food event | Food event saved with the selected past date (not today) | | |

### 17.2 Empty States

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| EDGE-05 | New user with no events: observe Dashboard | All sections show zero/empty state. No crashes | | |
| EDGE-06 | No food favorites: go to Favorites > Meal tab | Empty list shown | | |
| EDGE-07 | No routines: go to Routines tabs | Each tab shows empty state | | |
| EDGE-08 | No recipes saved: go to Recipes > Favorites tab | Empty list shown | | |

### 17.3 Validation & Error Handling

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| EDGE-09 | Food event: save with quantity 0 | Validation error. Not saved | | |
| EDGE-10 | Sport event: save with duration 0 | Validation error. Not saved | | |
| EDGE-11 | Supplement event: save without selecting a supplement | Validation error. Not saved | | |
| EDGE-12 | Routine: try to save with no days of week selected | Validation error. Not saved | | |
| EDGE-13 | Login: trigger a network error (airplane mode + tap Sign In) | Appropriate connection error message shown | | |

### 17.4 Locale & Localization

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| EDGE-14 | Switch device language to Spanish (ES) | All app strings display in Spanish | | |
| EDGE-15 | Verify nutrient names in Spanish | Nutrient names correctly translated | | |
| EDGE-16 | Verify error messages in Spanish | Error/validation messages appear in Spanish | | |

### 17.5 App Lifecycle

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| EDGE-17 | Force quit app, relaunch | App opens to Splash → Dashboard (if logged in). Data intact | | |
| EDGE-18 | Background app for extended period (30+ min), resume | App resumes correctly. Data refreshes | | |
| EDGE-19 | Rotate device (if supported) | Layout adjusts without crashing | | |
| EDGE-20 | Rapidly tap between different Dashboard sections | No crashes or double-navigation | | |
| EDGE-21 | Navigate deep into screens (Dashboard > Meal > Edit > Back > Meal > Edit), then use Home button | Returns to Dashboard cleanly | | |

---

## Section 18: Health Sync Integration

| ID | Steps | Expected Result | Status | Notes |
|----|-------|-----------------|--------|-------|
| HS-01 | Android: With Health Connect installed, enable sync in Settings | Permissions requested. After granting, sync begins | | |
| HS-02 | Android: Without Health Connect installed, tap enable sync | Prompt to install Health Connect from Play Store | | |
| HS-03 | iOS: Enable sync in Settings | HealthKit permissions requested. After granting, sync begins | | |
| HS-04 | After enabling sync, observe Dashboard | Steps widget appears with step count from device | | |
| HS-05 | After enabling sync, observe Dashboard | Sleep widget appears with sleep hours from device | | |
| HS-06 | On Health Sync Settings, tap manual sync button | Data refreshes immediately | | |
| HS-07 | Disable sync, observe Dashboard | Sleep and Steps widgets disappear from Dashboard | | |
| HS-08 | Re-enable sync after disabling | Widgets reappear with current data | | |

---

## Dead Code Verification

These features exist in the codebase but should NOT be reachable by the user. Verify they are not accessible:

| ID | Feature | Verification Steps | Reachable? (should be No) | Notes |
|----|---------|-------------------|---------------------------|-------|
| DC-01 | Liquid Favorites tab | Go to Favorites Tab Holder. Check if a "Liquids" tab exists | | |
| DC-02 | Subjective Analysis screens | Search all menus and navigation for any "Subjective Analysis" entry point | | |
| DC-03 | Test Screen | Check all menus and navigation for any "Test" option | | |
| DC-04 | Old Barcode Scanner (BarCodeScanningScreen) | Use the food scanner. Verify it opens FoodScannerScreen (camera-based), not the old barcode-only screen | | |

---

## Summary & Sign-Off

### Test Execution Summary

| Metric | Count |
|--------|-------|
| **Total Test Cases** | |
| **Passed** | |
| **Failed** | |
| **Blocked** | |
| **Skipped** | |
| **Pass Rate** | % |

### Failed Test Cases

| Test ID | Section | Description of Failure |
|---------|---------|----------------------|
| | | |
| | | |
| | | |

### Blocked Test Cases

| Test ID | Section | Reason for Block |
|---------|---------|-----------------|
| | | |
| | | |

### Overall Result

| | |
|---|---|
| **Result** | Approved / Not Approved |
| **Tester Name** | |
| **Tester Signature** | |
| **Date** | |
| **App Version** | |
| **Build Number** | |
| **Devices Used** | |
| **OS Versions** | |
