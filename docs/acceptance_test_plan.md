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

## Coverage Tags

Each test case is tagged to indicate whether it has automated coverage and whether it requires manual testing:

| Tag | Meaning |
|-----|---------|
| 🤖 **AUTO** | Has programmatic coverage (unit / widget / BLoC / integration test). Manual run still validates real-device behavior. |
| 👤 **MANUAL** | Cannot be reasonably automated. Requires real device, real backend, or human judgment. Always run manually. |
| ⚠️ **PARTIAL** | Logic is automated but visual/navigation portion needs manual verification. |

> **For QA testers:** All cases must still be executed manually for release sign-off. The tags are informational — they show which cases also have automated regression coverage.

---

## Section 1: Authentication & Onboarding

### 1.1 Splash & Login

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| AUTH-01 | 👤 MANUAL | Cold launch the app (kill process first) | Splash screen appears briefly, then transitions to Login screen (or Dashboard if already logged in) | | |
| AUTH-02 | 👤 MANUAL | On Login screen, enter valid email and password, tap Sign In | App navigates to Dashboard. User's name visible in greeting | | |
| AUTH-03 | ⚠️ PARTIAL | On Login screen, enter invalid email/password, tap Sign In | Error message appears. User stays on Login screen | | |
| AUTH-04 | 🤖 AUTO | On Login screen, leave email or password empty, tap Sign In | Validation error shown for empty fields | | |
| AUTH-05 | 👤 MANUAL | On Login screen, tap "Sign Up" toggle. Fill all fields (name, email, password, confirm password). Check privacy policy checkbox. Tap Sign Up | Account created. Navigates to Welcome screen | | |
| AUTH-06 | 👤 MANUAL | On Sign Up, fill all fields but do NOT check privacy policy checkbox. Tap Sign Up | Submission is blocked. Privacy policy checkbox required | | |
| AUTH-07 | 🤖 AUTO | On Sign Up, enter mismatched passwords. Tap Sign Up | Error message about password mismatch | | |
| AUTH-08 | 👤 MANUAL | On Login screen, tap "Forgot Password?" link | Navigates to Forgotten Password screen | | |

### 1.2 Password Reset

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| AUTH-09 | 👤 MANUAL | On Forgotten Password screen, enter registered email, tap Submit | Confirmation code sent. Screen shows code entry field | | |
| AUTH-10 | 👤 MANUAL | Enter valid confirmation code and new password on Reset Password screen, tap Submit | Password reset successful. Navigates to Login or Dashboard | | |

### 1.3 Onboarding (New User)

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| AUTH-11 | 👤 MANUAL | After first sign-up, observe Welcome screen. Tap Continue | Navigates to Health Sync Onboarding screen | | |
| AUTH-12 | 👤 MANUAL | On Health Sync Onboarding, tap "Connect" | Device health permissions requested (Health Connect / HealthKit) | | |
| AUTH-13 | 👤 MANUAL | On Health Sync Onboarding, tap "Skip" instead | Proceeds to Registry screen without health sync | | |
| AUTH-14 | 👤 MANUAL | On Registry screen, fill General Questions (name, DOB, sex, height, weight). Tap Next/Save | Data saved. Advances to next section | | |
| AUTH-15 | 👤 MANUAL | Fill Health Questions (medical conditions, pharmaceutical status). Tap Next/Save | Data saved. Advances to next section | | |
| AUTH-16 | 👤 MANUAL | Fill Diet Questions (diet type, intolerances, allergens). Tap Next/Save | Data saved. Advances to next section | | |
| AUTH-17 | 👤 MANUAL | Fill Physical Activity level. Tap Next/Save | Data saved. Objectives dialog appears | | |
| AUTH-18 | 👤 MANUAL | Select objectives in Objectives dialog. Confirm | Objectives saved. Navigates to Dashboard | | |

---

## Section 2: Dashboard

### 2.1 Dashboard Layout & Data Display

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| DASH-01 | 👤 MANUAL | After login, observe Dashboard screen | Dashboard loads with user greeting, all sections visible | | |
| DASH-02 | ⚠️ PARTIAL | Observe the week calendar at the top | Current week shown, today's date is highlighted/selected | | |
| DASH-03 | 🤖 AUTO | Tap a different day in the week calendar | Dashboard reloads data for the selected day | | |
| DASH-04 | ⚠️ PARTIAL | Observe Nutrition Progress widget | Shows kcal consumed out of daily goal. Circular or bar progress | | |
| DASH-05 | ⚠️ PARTIAL | Observe macro nutrient bars below progress | Protein, Carbs, Fat bars shown with percentages/amounts | | |
| DASH-06 | ⚠️ PARTIAL | Observe Micro Nutrients section | Nutrient bars shown with RDA percentages | | |
| DASH-07 | 🤖 AUTO | Tap on the Micro Nutrients section | Navigates to Micro Nutrients Detail screen | | |

### 2.2 Meal Sections

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| DASH-08 | ⚠️ PARTIAL | Observe Breakfast card on dashboard | Shows breakfast foods logged today (or empty state) with calorie total | | |
| DASH-09 | 🤖 AUTO | Tap Breakfast card | Navigates to Meal Time Details screen for Breakfast | | |
| DASH-10 | 🤖 AUTO | Tap Lunch card | Navigates to Meal Time Details screen for Lunch | | |
| DASH-11 | 🤖 AUTO | Tap Dinner card | Navigates to Meal Time Details screen for Dinner | | |
| DASH-12 | 🤖 AUTO | Tap Snack card | Navigates to Meal Time Details screen for Snack | | |

### 2.3 Supplements

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| DASH-13 | 🤖 AUTO | Observe Supplements card on dashboard | Shows supplements taken today (or empty state) | | |
| DASH-14 | 🤖 AUTO | Tap Supplements card | Navigates to Supplements Detail screen | | |
| DASH-15 | 🤖 AUTO | Tap "+" icon on Supplements card | Navigates to Supplements screen (add new) | | |

### 2.4 Water & Hydration

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| DASH-16 | 🤖 AUTO | Observe Water Intake widget | Shows current water count / glasses | | |
| DASH-17 | 🤖 AUTO | Tap "+" on water widget | Water count increments by 1 glass (0.25L) | | |
| DASH-18 | 🤖 AUTO | Tap "-" on water widget | Water count decrements by 1 glass | | |
| DASH-19 | 🤖 AUTO | Tap "-" when water is already at 0 | Water count does not go below 0 | | |
| DASH-20 | 👤 MANUAL | Tap the water info/detail icon | Navigates to Liquid Summary Detail screen | | |

### 2.5 Activity & Health Sync

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| DASH-21 | 🤖 AUTO | Observe Activity Log section | Shows sport events logged today (or empty state) | | |
| DASH-22 | 🤖 AUTO | Tap "+" on Activity Log section | Navigates to Add Sport Event screen | | |
| DASH-23 | 🤖 AUTO | Tap Activity Log area (not the +) | Navigates to Sport Items screen | | |
| DASH-24 | 🤖 AUTO | If Health Sync enabled: observe Sleep widget | Sleep hours from device health data displayed | | |
| DASH-25 | 🤖 AUTO | If Health Sync enabled: observe Steps widget | Step count from device health data displayed | | |

### 2.6 Feces/Urine & Calendar

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| DASH-26 | 🤖 AUTO | Observe Feces/Urine section on dashboard | Card visible with access to deposition tracking | | |
| DASH-27 | 🤖 AUTO | Tap Feces/Urine card | Navigates to Feces/Urine Tab Holder | | |
| DASH-28 | 👤 MANUAL | Tap Calendar icon in app bar | Navigates to Calendar Pane screen | | |

---

## Section 3: Bottom Navigation & Menus

### 3.1 Plus (+) Menu

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| NAV-01 | 🤖 AUTO | Tap the "+" button in bottom navigation bar | Overlay menu appears with food meal times and other options | | |
| NAV-02 | 🤖 AUTO | In + menu, tap Breakfast | Navigates to Add Food Event screen with Breakfast pre-selected | | |
| NAV-03 | 🤖 AUTO | In + menu, tap Lunch | Navigates to Add Food Event screen with Lunch pre-selected | | |
| NAV-04 | 🤖 AUTO | In + menu, tap Dinner | Navigates to Add Food Event screen with Dinner pre-selected | | |
| NAV-05 | 🤖 AUTO | In + menu, tap Snack | Navigates to Add Food Event screen with Snack pre-selected | | |
| NAV-06 | 🤖 AUTO | In + menu, tap Supplements | Navigates to Supplements screen | | |
| NAV-07 | 🤖 AUTO | In + menu, tap Physical Activity | Navigates to Add Sport Event screen | | |
| NAV-08 | 🤖 AUTO | In + menu, tap Feces/Urine | Navigates to Feces/Urine Tabs screen | | |

### 3.2 Hamburger Menu

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| NAV-09 | 🤖 AUTO | Tap hamburger menu icon in bottom navigation | Menu overlay opens with: Routines, Favorites, Tips, Recipes, Profile | | |
| NAV-10 | 🤖 AUTO | Tap Routines | Navigates to Routines Tab Holder | | |
| NAV-11 | 🤖 AUTO | Tap Favorites | Navigates to Favorites Tab Holder | | |
| NAV-12 | 🤖 AUTO | Tap Tips | Navigates to Recommendations Tab Holder | | |
| NAV-13 | 🤖 AUTO | Tap Recipes | Navigates to Recipes Tab Holder | | |
| NAV-14 | 🤖 AUTO | Tap Profile | Navigates to Profile screen | | |

### 3.3 General Navigation

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| NAV-15 | 🤖 AUTO | Tap "Start" / Home button in bottom nav from any screen | Navigates back to Dashboard | | |
| NAV-16 | 👤 MANUAL | Tap outside an open menu overlay (scrim area) | Menu dismisses | | |

---

## Section 4: Food Events

### 4.1 Add Food Event

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FOOD-01 | 👤 MANUAL | Navigate to Add Food Event (via + menu or meal card). Observe screen | Correct meal type icon/label shown. Search field visible | | |
| FOOD-02 | 🤖 AUTO | Type a food name in search field | Autocomplete results appear from food database | | |
| FOOD-03 | 🤖 AUTO | Select a food from search results | Food selected. Quantity and unit fields appear | | |
| FOOD-04 | 🤖 AUTO | Set quantity (e.g., 100g). Observe nutrient info card | Nutrient breakdown updates to reflect quantity | | |
| FOOD-05 | 🤖 AUTO | Tap Save/Add button | Confirmation shown. Returns to previous screen | | |
| FOOD-06 | ⚠️ PARTIAL | Return to Dashboard, observe the meal section | Saved food appears in correct meal section with calories | | |
| FOOD-07 | 🤖 AUTO | On Add Food Event, toggle to "Recent" items tab | Previously logged foods shown | | |
| FOOD-08 | 🤖 AUTO | On Add Food Event, toggle to "Favorites" tab | User's food favorites shown | | |
| FOOD-09 | 🤖 AUTO | Tap a food favorite to select it, then save | Food event created from favorite. Returns to previous screen | | |
| FOOD-10 | 🤖 AUTO | Set quantity to 0 or leave empty, tap Save | Validation error. Event not saved | | |

### 4.2 Food Scanner

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FOOD-11 | 👤 MANUAL | On Add Food Event, tap scanner/camera icon | Camera opens (permission requested if first time). Scanner screen shown | | |
| FOOD-12 | 👤 MANUAL | Point camera at a known food product barcode | Barcode detected. Food info retrieved from database | | |
| FOOD-13 | ⚠️ PARTIAL | Point camera at an unknown/invalid barcode | Barcode detected but no match. Appropriate message shown | | |
| FOOD-14 | ⚠️ PARTIAL | Capture a photo of food for visual recognition | Photo sent for recognition. Food suggestions returned | | |
| FOOD-15 | 🤖 AUTO | From scanner results, tap "Edit" on a matched food | Returns to Add Food Event screen with food pre-filled | | |
| FOOD-16 | 🤖 AUTO | From scanner results, tap "Log" on a matched food | Food event saved directly. Confirmation shown | | |
| FOOD-17 | 👤 MANUAL | Enable airplane mode, open food scanner | Offline indicator or message shown | | |

### 4.3 Meal Time Details & Editing

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FOOD-18 | 🤖 AUTO | Tap a meal card on Dashboard (with foods logged) | Meal Time Details screen shows all foods for that meal with totals | | |
| FOOD-19 | 👤 MANUAL | Tap a food item in Meal Time Details | Opens edit screen (Item Update) for that food | | |
| FOOD-20 | 🤖 AUTO | Edit the food quantity, tap Save | Quantity updated. Returns to Meal Time Details with updated values | | |
| FOOD-21 | 🤖 AUTO | Tap delete on a food item. Confirm deletion | Food removed. Meal Time Details and Dashboard reflect the change | | |
| FOOD-22 | ⚠️ PARTIAL | On Add Food Event, enable "Save as favorite" toggle, then save | Food event saved AND food added to favorites | | |

---

## Section 5: Liquid & Water Events

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| LIQ-01 | 🤖 AUTO | On Dashboard, tap "+" on water widget multiple times | Water count increments correctly each time | | |
| LIQ-02 | 🤖 AUTO | On Dashboard, tap "-" on water widget | Water count decrements correctly | | |
| LIQ-03 | 👤 MANUAL | Tap water detail icon on Dashboard | Navigates to Liquid Summary Detail screen | | |
| LIQ-04 | 🤖 AUTO | On Liquid Summary Detail, observe water + liquid breakdown | All water and liquid events for the day shown with totals | | |
| LIQ-05 | 🤖 AUTO | On Liquid Summary Detail, tap add water | Water event added. Count updates | | |
| LIQ-06 | 👤 MANUAL | Navigate to Add Liquid Event screen | Screen shows liquid type selector and quantity fields | | |
| LIQ-07 | 🤖 AUTO | Select a liquid type (e.g., juice, tea), set quantity, save | Liquid event saved. Appears in Liquid Summary Detail | | |
| LIQ-08 | 🤖 AUTO | Delete a liquid event from the detail screen | Event removed. Totals update | | |
| LIQ-09 | 🤖 AUTO | Verify water goal on dashboard matches profile weight * 0.035L | Goal displayed correctly based on user's weight | | |
| LIQ-10 | 🤖 AUTO | Log multiple different liquids, check nutrient contribution on Dashboard | Liquid nutrients (if applicable) contribute to daily totals | | |
| LIQ-11 | 👤 MANUAL | On a day with no water/liquid logged, observe water widget | Shows 0 glasses / 0L consumed | | |
| LIQ-12 | 🤖 AUTO | Add water from Liquid Summary Detail screen, return to Dashboard | Dashboard water widget reflects the added water | | |

---

## Section 6: Supplements

### 6.1 Add & View Supplements

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SUP-01 | 👤 MANUAL | Navigate to Supplements screen (via + menu or supplements card) | Supplement search and selection screen shown | | |
| SUP-02 | 🤖 AUTO | Search for a supplement by name | Results appear from master supplement list | | |
| SUP-03 | 🤖 AUTO | Select a supplement, set time and quantity, tap Save | Supplement event saved. Confirmation shown | | |
| SUP-04 | 🤖 AUTO | Return to Dashboard. Tap Supplements card | Supplements Detail screen shows the saved supplement | | |
| SUP-05 | 🤖 AUTO | Toggle to "Recent" on Supplements screen | Recently logged supplements shown | | |
| SUP-06 | 🤖 AUTO | Toggle to "Favorites" on Supplements screen | Saved supplement favorites shown | | |
| SUP-07 | 🤖 AUTO | Enable "Save as favorite" toggle, then save supplement | Supplement saved AND added to favorites | | |
| SUP-08 | 🤖 AUTO | Enable "Save as routine" toggle, set days and time, then save | Supplement saved AND routine created | | |

### 6.2 Edit & Delete Supplements

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SUP-09 | 👤 MANUAL | On Supplements Detail, tap a supplement item | Opens Update Supplement screen | | |
| SUP-10 | 🤖 AUTO | Edit supplement quantity/time, tap Save | Updated values shown in Supplements Detail | | |
| SUP-11 | 🤖 AUTO | Delete a supplement from Update Supplement screen | Supplement removed. Detail and Dashboard reflect removal | | |

### 6.3 Creatine & Collagen Quick Toggles

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SUP-12 | 🤖 AUTO | On Dashboard, toggle Creatine ON | Creatine event created for today | | |
| SUP-13 | 🤖 AUTO | On Dashboard, toggle Creatine OFF | Creatine event removed for today | | |
| SUP-14 | 🤖 AUTO | On Dashboard, toggle Collagen ON | Collagen event created for today | | |
| SUP-15 | 🤖 AUTO | On Dashboard, toggle Collagen OFF | Collagen event removed for today | | |

---

## Section 7: Sport / Physical Activity

### 7.1 Add Sport Event

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SPORT-01 | 👤 MANUAL | Navigate to Add Sport Event (via + menu or activity log) | Sport search and selection screen shown | | |
| SPORT-02 | 🤖 AUTO | Search for a sport/activity by name | Results appear from master sports list | | |
| SPORT-03 | 🤖 AUTO | Select a sport, set duration in minutes, tap Save | Sport event saved. Calories burned calculated and shown | | |
| SPORT-04 | 🤖 AUTO | Return to Dashboard. Observe Activity Log | Saved sport event appears with duration and kcal burned | | |
| SPORT-05 | 🤖 AUTO | Toggle to "Recent" on Add Sport Event screen | Recently logged sports shown | | |
| SPORT-06 | 🤖 AUTO | Toggle to "Favorites" on Add Sport Event screen | Saved sport favorites shown | | |
| SPORT-07 | 🤖 AUTO | Enable "Save as favorite" toggle, then save sport | Sport saved AND added to favorites | | |
| SPORT-08 | 🤖 AUTO | Enable "Save as routine" toggle, set days, then save sport | Sport saved AND routine created | | |

### 7.2 View, Edit & Delete Sport Events

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SPORT-09 | 👤 MANUAL | Tap Activity Log on Dashboard to open Sport Items screen | All sport events for the day shown | | |
| SPORT-10 | 👤 MANUAL | Tap a sport item to open edit screen | Sport Update screen opens with current values | | |
| SPORT-11 | 🤖 AUTO | Edit duration, tap Save | Updated duration and recalculated kcal shown | | |
| SPORT-12 | 🤖 AUTO | Delete a sport event, confirm deletion | Sport removed. Dashboard Activity Log updated | | |
| SPORT-13 | 🤖 AUTO | Set duration to 0, tap Save | Validation error. Event not saved with 0 duration | | |

---

## Section 8: Feces / Urine Analysis

### 8.1 Feces Tracking

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FU-01 | 👤 MANUAL | Navigate to Feces/Urine Tab Holder (from Dashboard or + menu) | Tab holder opens with Feces and Urine tabs | | |
| FU-02 | 👤 MANUAL | On Feces tab, observe the form | Bristol scale or stool type selection visible | | |
| FU-03 | 🤖 AUTO | Select feces type/characteristics, tap Save | Feces event saved. Entry appears in history below | | |
| FU-04 | 🤖 AUTO | Delete a feces event from the list | Event removed from history | | |

### 8.2 Urine Tracking

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FU-05 | 👤 MANUAL | Switch to Urine tab | Urine color/characteristic selection visible | | |
| FU-06 | 🤖 AUTO | Select urine color/characteristics, tap Save | Urine event saved. Entry appears in history below | | |
| FU-07 | 🤖 AUTO | Delete a urine event from the list | Event removed from history | | |

### 8.3 Detail View

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FU-08 | 🤖 AUTO | Navigate to Feces/Urine detail view (from Dashboard depositions area) | Detail view shows chart/history of events over time | | |
| FU-09 | 🤖 AUTO | Select a different date, observe events | Events for selected date shown | | |
| FU-10 | 👤 MANUAL | On a day with no feces/urine logged | Empty state shown (no crash) | | |

---

## Section 9: Nutrient Detail Screens

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| NUT-01 | 👤 MANUAL | Tap Macro Nutrients area on Dashboard | Macro Nutrients Detail screen opens with protein, carbs, fat breakdown | | |
| NUT-02 | 🤖 AUTO | Verify macro values match foods logged today | Values are consistent with logged food events | | |
| NUT-03 | 🤖 AUTO | Tap Micro Nutrients section on Dashboard | Micro Nutrients Detail screen opens with all micronutrients and RDA bars | | |
| NUT-04 | 👤 MANUAL | Scroll through micronutrients list | All vitamins and minerals shown with progress towards RDA | | |
| NUT-05 | 👤 MANUAL | Navigate to Micro Nutrients Weekly screen | Weekly aggregation of micronutrient data shown | | |
| NUT-06 | 🤖 AUTO | Navigate to Energy Balance Detail screen | Ingested kcal vs. burned kcal displayed | | |
| NUT-07 | 🤖 AUTO | Verify energy balance accounts for food + sport | Both food intake and sport calories reflected | | |
| NUT-08 | 👤 MANUAL | Navigate to Sugar Detail screen | Sugar intake for the day displayed | | |
| NUT-09 | 👤 MANUAL | Navigate to Fiber Detail screen | Fiber intake for the day displayed | | |
| NUT-10 | 👤 MANUAL | Navigate to Weekly All Nutrients Detail screen | Complete weekly nutrient summary shown | | |
| NUT-11 | 🤖 AUTO | Navigate to Weekly Dashboard Detail screen | Weekly summary with daily trends/charts displayed | | |
| NUT-12 | 👤 MANUAL | On a day with no food logged, open any nutrient detail screen | Zero values displayed (no crash, no negative numbers) | | |
| NUT-13 | 🤖 AUTO | Add a food event, then re-open a nutrient detail screen | Updated nutrient values reflected | | |
| NUT-14 | 👤 MANUAL | Tap back/navigate away from each detail screen | Returns to previous screen correctly | | |

---

## Section 10: Favorites

### 10.1 Favorites Tab Navigation

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FAV-01 | 👤 MANUAL | Navigate to Favorites Tab Holder (hamburger menu > Favorites) | Tab holder opens | | |
| FAV-02 | 🤖 AUTO | Observe available tabs | Three tabs visible: Meal, Physical Activity, Supplements | | |

### 10.2 Meal Favorites

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FAV-03 | 🤖 AUTO | Tap Meal tab | List of food favorites shown (grouped by meal time), or empty state | | |
| FAV-04 | 👤 MANUAL | Tap a food favorite cluster | Cluster detail screen shows individual items | | |
| FAV-05 | 👤 MANUAL | Tap "+" to add a new food favorite | Meal type selection appears, then food search | | |
| FAV-06 | 🤖 AUTO | Search and select a food, save as favorite | Food favorite created. Appears in Meal favorites list | | |
| FAV-07 | 👤 MANUAL | Tap "Create new" to create a multi-food cluster favorite | Create New Food Favorite screen opens. Add multiple foods, save | | |
| FAV-08 | 🤖 AUTO | Delete a food favorite (swipe or delete button) | Favorite removed from list | | |

### 10.3 Physical Activity Favorites

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FAV-09 | 🤖 AUTO | Tap Physical Activity tab | List of sport favorites shown, or empty state | | |
| FAV-10 | 👤 MANUAL | Tap "+" to add a sport favorite | Sport search screen opens | | |
| FAV-11 | 🤖 AUTO | Search and select a sport, save as favorite | Sport favorite created. Appears in list | | |
| FAV-12 | 🤖 AUTO | Delete a sport favorite | Favorite removed from list | | |

### 10.4 Supplements Favorites

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FAV-13 | 🤖 AUTO | Tap Supplements tab | List of supplement favorites shown, or empty state | | |
| FAV-14 | 🤖 AUTO | Delete a supplement favorite | Favorite removed from list | | |

### 10.5 Using Favorites from Event Screens

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| FAV-15 | 🤖 AUTO | On Add Food Event screen, toggle to Favorites. Tap a favorite | Food fields pre-filled from favorite data | | |
| FAV-16 | ⚠️ PARTIAL | On Add Sport Event screen, toggle to Favorites. Tap a favorite | Sport fields pre-filled from favorite data | | |
| FAV-17 | ⚠️ PARTIAL | On Supplements screen, toggle to Favorites. Tap a favorite | Supplement fields pre-filled from favorite data | | |
| FAV-18 | 🤖 AUTO | With no favorites saved, toggle to Favorites tab on any add screen | Empty state shown with guidance to create favorites | | |

---

## Section 11: Routines

### 11.1 Routine Tab Navigation

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| ROU-01 | 🤖 AUTO | Navigate to Routines Tab Holder (hamburger menu > Routines) | Tab holder opens | | |
| ROU-02 | 🤖 AUTO | Observe available tabs | Three tabs: Meal, Workouts, Supplements | | |

### 11.2 Meal Routines

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| ROU-03 | 🤖 AUTO | Tap Meal routines tab | List of food routines shown with days of week, or empty state | | |
| ROU-04 | 🤖 AUTO | Tap "+" to create a new food routine | Add Food Event screen opens with routine mode | | |
| ROU-05 | 🤖 AUTO | Select food, set time, select days of week, save | Food routine created. Appears in Meal routines list | | |
| ROU-06 | 🤖 AUTO | Delete a food routine, confirm deletion | Routine removed from list | | |

### 11.3 Workout Routines

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| ROU-07 | 🤖 AUTO | Tap Workouts tab | List of sport routines, or empty state | | |
| ROU-08 | 🤖 AUTO | Create a sport routine: select sport, set duration, set time, select days, save | Sport routine created. Appears in Workouts list | | |
| ROU-09 | 🤖 AUTO | After saving sport routine, observe navigation | Note where the app navigates after save (back to routines list, or elsewhere) | | |
| ROU-10 | 👤 MANUAL | Verify routine data appears immediately after save (no need to navigate away) | Routine data visible immediately in the list | | |
| ROU-11 | 🤖 AUTO | Delete a sport routine | Routine removed from list | | |

### 11.4 Supplement Routines

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| ROU-12 | 🤖 AUTO | Tap Supplements tab | List of supplement routines, or empty state | | |
| ROU-13 | 🤖 AUTO | Create a supplement routine: select supplement, set time, select days, save | Supplement routine created. Appears in Supplements list | | |
| ROU-14 | 🤖 AUTO | Delete a supplement routine | Routine removed from list | | |

### 11.5 Routine General Behavior

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| ROU-15 | 🤖 AUTO | Days-of-week selector: tap individual days on and off | Selected days highlight/unhighlight correctly | | |
| ROU-16 | 🤖 AUTO | Create routine with no days selected, try to save | Validation error. Routine not saved without at least one day | | |
| ROU-17 | 🤖 AUTO | With no routines saved, observe each routine tab | Empty state shown (no crash) | | |

---

## Section 12: Recommendations

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| REC-01 | 👤 MANUAL | Navigate to Recommendations (hamburger menu > Tips) | Recommendations Tab Holder opens | | |
| REC-02 | 🤖 AUTO | Observe available tabs | Two tabs: Tips and List (or similar) | | |
| REC-03 | 🤖 AUTO | Tap Tips tab | Personalized tips/recommendations load based on user profile | | |
| REC-04 | 👤 MANUAL | Tap a tip card (if it links to a recipe or food) | Opens relevant detail (recipe or food info) | | |
| REC-05 | 🤖 AUTO | Tap List tab | Food list/recommendations shown, grouped by category | | |
| REC-06 | 🤖 AUTO | Verify food list respects user's aversions/exclusions | Foods the user has excluded in profile are not recommended | | |
| REC-07 | 👤 MANUAL | With a new user profile (no objectives set), view recommendations | Appropriate content shown or empty state | | |
| REC-08 | 👤 MANUAL | Navigate back from Recommendations | Returns to Dashboard | | |

---

## Section 13: Recipes

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| RCPE-01 | 👤 MANUAL | Navigate to Recipes (hamburger menu > Recipes) | Recipes Tab Holder opens | | |
| RCPE-02 | 👤 MANUAL | Observe available tabs | Discover and Favorites tabs | | |
| RCPE-03 | 👤 MANUAL | Tap Discover tab | Recipe cards load | | |
| RCPE-04 | 👤 MANUAL | Tap a recipe card | Recipe Detail screen opens | | |
| RCPE-05 | 🤖 AUTO | On Recipe Detail, tap Ingredients tab | Ingredient list with quantities shown | | |
| RCPE-06 | 🤖 AUTO | On Recipe Detail, tap Steps tab | Cooking steps shown in order | | |
| RCPE-07 | 🤖 AUTO | Tap heart/favorite icon on a recipe | Recipe saved to favorites. Heart icon fills | | |
| RCPE-08 | 👤 MANUAL | Tap Favorites tab in Recipes | Saved recipe favorites listed | | |
| RCPE-09 | 👤 MANUAL | Remove a recipe from favorites (tap heart again or delete) | Recipe removed from favorites list | | |
| RCPE-10 | 👤 MANUAL | With no recipe favorites, observe Favorites tab | Empty state shown | | |

---

## Section 14: Journal & Calendar

### 14.1 Journal

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| JRNL-01 | 👤 MANUAL | Navigate to Journal screen | Journal opens with Food, Sport, Liquid tabs | | |
| JRNL-02 | 🤖 AUTO | Tap Food tab | Food event history shown for selected date | | |
| JRNL-03 | 🤖 AUTO | Tap Sport tab | Sport event history shown for selected date | | |
| JRNL-04 | 🤖 AUTO | Tap Liquid tab | Liquid event history shown for selected date | | |
| JRNL-05 | 🤖 AUTO | Select a different date in Journal | Events update for the selected date | | |
| JRNL-06 | 👤 MANUAL | On a day with no events, observe each Journal tab | Empty state shown for each tab | | |

### 14.2 Calendar

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| JRNL-07 | 👤 MANUAL | Tap Calendar icon on Dashboard | Calendar Pane screen opens | | |
| JRNL-08 | 🤖 AUTO | Observe days with events | Dots or markers shown on days that have logged events | | |
| JRNL-09 | 🤖 AUTO | Tap a marked day | Events for that day shown below the calendar | | |
| JRNL-10 | 👤 MANUAL | Tap an event in the calendar event list | Opens edit screen for that event | | |
| JRNL-11 | 👤 MANUAL | Navigate between months (swipe or arrows) | Calendar month changes. Markers update | | |
| JRNL-12 | 👤 MANUAL | Tap today button (if available) or navigate back to current month | Calendar returns to today's date | | |

---

## Section 15: Profile & Settings

### 15.1 Profile Viewing & Editing

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| PROF-01 | 👤 MANUAL | Navigate to Profile (hamburger menu > Profile) | Profile screen shows user info cards | | |
| PROF-02 | 🤖 AUTO | Observe profile data: name, age, sex, weight, height | All values match what was entered during registration | | |
| PROF-03 | 🤖 AUTO | Tap edit on General section | General Questions screen opens. Edit name, tap Save | | |
| PROF-04 | 🤖 AUTO | Tap edit on Health section | Health Questions screen opens. Edit conditions, tap Save | | |
| PROF-05 | 🤖 AUTO | Tap edit on Diet section | Diet Questions screen opens. Edit preferences, tap Save | | |
| PROF-06 | 🤖 AUTO | Tap edit on Physical Activity section | Physical Activity screen opens. Change level, tap Save | | |
| PROF-07 | 🤖 AUTO | Tap edit on Objectives section | Objectives dialog opens. Modify objectives, confirm | | |
| PROF-08 | 👤 MANUAL | Navigate to Aversions section | Aversions screen opens. Add/remove food aversions | | |
| PROF-09 | 👤 MANUAL | Change weight in profile, return to Dashboard | Water goal on Dashboard updates (new weight * 0.035L) | | |
| PROF-10 | ⚠️ PARTIAL | Verify profile changes persist after app restart | Kill app, relaunch, navigate to Profile. Changes still there | | |

### 15.2 Settings

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| PROF-11 | 🤖 AUTO | Navigate to Settings (from Profile or settings icon) | Settings screen opens with all options | | |
| PROF-12 | 🤖 AUTO | Observe available settings | Log Out, Health Sync, Support/Contact, Privacy Policy visible | | |
| PROF-13 | 🤖 AUTO | Tap Health Sync | Health Sync Settings screen opens | | |
| PROF-14 | 🤖 AUTO | Enable Health Sync toggle | Device health permissions requested | | |
| PROF-15 | 🤖 AUTO | Disable Health Sync toggle | Sync disabled. Sleep/Steps widgets disappear from Dashboard | | |
| PROF-16 | 👤 MANUAL | Tap Support/Contact (WhatsApp link) | WhatsApp opens (or appropriate link handling) | | |
| PROF-17 | 🤖 AUTO | Tap Privacy Policy | Privacy Policy / Policy screen opens with content | | |
| PROF-18 | 👤 MANUAL | Tap Log Out | Confirmation dialog appears | | |
| PROF-19 | 🤖 AUTO | Confirm Log Out | App navigates to Login screen. Session cleared | | |
| PROF-20 | 👤 MANUAL | After logging out, relaunch app | Splash screen → Login screen (not Dashboard) | | |

---

## Section 16: Data Sync & Cross-Device

### 16.1 Basic Sync (Online)

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SYNC-01 | ⚠️ PARTIAL | Save a food event while online | Event saves successfully | | |
| SYNC-02 | 👤 MANUAL | Log in on a second device with same account | Food event from first device appears on second device | | |
| SYNC-03 | 👤 MANUAL | Save a sport event on Device 1, check Device 2 | Sport event syncs to Device 2 | | |
| SYNC-04 | 👤 MANUAL | Save water events on Device 1, check Device 2 | Water events sync to Device 2 | | |
| SYNC-05 | 👤 MANUAL | Save a supplement event on Device 1, check Device 2 | Supplement event syncs to Device 2 | | |
| SYNC-06 | 👤 MANUAL | Save food favorites on Device 1, check Device 2 | Food favorites sync to Device 2 | | |
| SYNC-07 | 👤 MANUAL | Save sport favorites on Device 1, check Device 2 | Sport favorites sync to Device 2 | | |
| SYNC-08 | 👤 MANUAL | Save a feces event on Device 1, check Device 2 | Feces event syncs to Device 2 | | |

### 16.2 Offline & Recovery

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SYNC-09 | ⚠️ PARTIAL | Enable airplane mode. Save a food event | Event saves locally without error | | |
| SYNC-10 | 👤 MANUAL | While still offline, observe the saved event on Dashboard | Event appears on Dashboard from local storage | | |
| SYNC-11 | ⚠️ PARTIAL | Disable airplane mode. Wait a moment | Queued event syncs automatically to backend | | |
| SYNC-12 | 👤 MANUAL | Log in on second device. Verify the offline-saved event appears | Event synced successfully after network restored | | |

### 16.3 Sync Edge Cases

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| SYNC-13 | 👤 MANUAL | Save a liquid event on Device 1, check Device 2 | Note whether liquid events appear on Device 2 | | |
| SYNC-14 | 👤 MANUAL | Save a recipe favorite on Device 1, check Device 2 | Note whether recipe favorites appear on Device 2 | | |
| SYNC-15 | 👤 MANUAL | Save supplement routines on Device 1, check Device 2 | Supplement routines sync to Device 2 | | |
| SYNC-16 | 🤖 AUTO | Background the app for 5+ minutes, resume | App syncs data on resume (lifecycle trigger) | | |
| SYNC-17 | 👤 MANUAL | Force quit app during a save operation, relaunch | App picks up queued items and syncs on relaunch | | |
| SYNC-18 | 🤖 AUTO | Master files update: if a new food database version is available | Update dialog or automatic download triggers on Dashboard load | | |

---

## Section 17: Edge Cases & Regression

### 17.1 Date & Time Boundaries

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| EDGE-01 | 🤖 AUTO | Leave app open past midnight | Dashboard refreshes to new date automatically | | |
| EDGE-02 | 🤖 AUTO | Background app before midnight, resume after midnight | Date change detected. Dashboard shows new date | | |
| EDGE-03 | 👤 MANUAL | On a detail screen (e.g., Meal Time Details) at midnight | Snackbar or notification about date change shown | | |
| EDGE-04 | 🤖 AUTO | Select a past date on Dashboard, add a food event | Food event saved with the selected past date (not today) | | |

### 17.2 Empty States

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| EDGE-05 | 👤 MANUAL | New user with no events: observe Dashboard | All sections show zero/empty state. No crashes | | |
| EDGE-06 | 👤 MANUAL | No food favorites: go to Favorites > Meal tab | Empty list shown | | |
| EDGE-07 | 👤 MANUAL | No routines: go to Routines tabs | Each tab shows empty state | | |
| EDGE-08 | 👤 MANUAL | No recipes saved: go to Recipes > Favorites tab | Empty list shown | | |

### 17.3 Validation & Error Handling

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| EDGE-09 | 🤖 AUTO | Food event: save with quantity 0 | Validation error. Not saved | | |
| EDGE-10 | 🤖 AUTO | Sport event: save with duration 0 | Validation error. Not saved | | |
| EDGE-11 | 🤖 AUTO | Supplement event: save without selecting a supplement | Validation error. Not saved | | |
| EDGE-12 | 🤖 AUTO | Routine: try to save with no days of week selected | Validation error. Not saved | | |
| EDGE-13 | 👤 MANUAL | Login: trigger a network error (airplane mode + tap Sign In) | Appropriate connection error message shown | | |

### 17.4 Locale & Localization

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| EDGE-14 | 👤 MANUAL | Switch device language to Spanish (ES) | All app strings display in Spanish | | |
| EDGE-15 | 👤 MANUAL | Verify nutrient names in Spanish | Nutrient names correctly translated | | |
| EDGE-16 | 👤 MANUAL | Verify error messages in Spanish | Error/validation messages appear in Spanish | | |

### 17.5 App Lifecycle

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| EDGE-17 | 👤 MANUAL | Force quit app, relaunch | App opens to Splash → Dashboard (if logged in). Data intact | | |
| EDGE-18 | 👤 MANUAL | Background app for extended period (30+ min), resume | App resumes correctly. Data refreshes | | |
| EDGE-19 | 👤 MANUAL | Rotate device (if supported) | Layout adjusts without crashing | | |
| EDGE-20 | 👤 MANUAL | Rapidly tap between different Dashboard sections | No crashes or double-navigation | | |
| EDGE-21 | 👤 MANUAL | Navigate deep into screens (Dashboard > Meal > Edit > Back > Meal > Edit), then use Home button | Returns to Dashboard cleanly | | |

---

## Section 18: Health Sync Integration

| ID | Tag | Steps | Expected Result | Status | Notes |
|----|-----|-------|-----------------|--------|-------|
| HS-01 | 👤 MANUAL | Android: With Health Connect installed, enable sync in Settings | Permissions requested. After granting, sync begins | | |
| HS-02 | 👤 MANUAL | Android: Without Health Connect installed, tap enable sync | Prompt to install Health Connect from Play Store | | |
| HS-03 | 👤 MANUAL | iOS: Enable sync in Settings | HealthKit permissions requested. After granting, sync begins | | |
| HS-04 | 🤖 AUTO | After enabling sync, observe Dashboard | Steps widget appears with step count from device | | |
| HS-05 | 🤖 AUTO | After enabling sync, observe Dashboard | Sleep widget appears with sleep hours from device | | |
| HS-06 | 🤖 AUTO | On Health Sync Settings, tap manual sync button | Data refreshes immediately | | |
| HS-07 | 👤 MANUAL | Disable sync, observe Dashboard | Sleep and Steps widgets disappear from Dashboard | | |
| HS-08 | 👤 MANUAL | Re-enable sync after disabling | Widgets reappear with current data | | |

---

## Dead Code Verification

These features exist in the codebase but should NOT be reachable by the user. Verify they are not accessible:

| ID | Tag | Feature | Verification Steps | Reachable? (should be No) | Notes |
|----|-----|---------|-------------------|---------------------------|-------|
| DC-01 | 🤖 AUTO | Liquid Favorites tab | Go to Favorites Tab Holder. Check if a "Liquids" tab exists | | |
| DC-02 | 👤 MANUAL | Subjective Analysis screens | Search all menus and navigation for any "Subjective Analysis" entry point | | |
| DC-03 | 👤 MANUAL | Test Screen | Check all menus and navigation for any "Test" option | | |
| DC-04 | 👤 MANUAL | Old Barcode Scanner (BarCodeScanningScreen) | Use the food scanner. Verify it opens FoodScannerScreen (camera-based), not the old barcode-only screen | | |

---

## Coverage Summary

Total test cases: **284** across 18 sections + Dead Code verification.

| Tag | Count | % | Meaning |
|-----|-------|---|---------|
| 🤖 AUTO | 160 | 56% | Backed by automated tests — regression-safe |
| ⚠️ PARTIAL | 16 | 6% | Logic automated; visual/navigation needs manual eyes |
| 👤 MANUAL | 108 | 38% | Real device, real backend, or human judgment required |

**Behind the AUTO tag** (1,484 automated tests across unit / widget / BLoC layers, all passing):
- Phase 2: +35 BLoC tests for FecesUrine, Sport save flow, RecipeDetail
- Phase 3: +29 navigation widget tests (bottom navbar, meal section, dashboard widgets)
- Phase 3.5: +28 health-impact metric popup tests (Sleep, Steps, Hydration)
- Phase 4: +14 full-screen navigation tests (Settings, Profile, Routines)

**For QA testers:** All 284 cases must still be executed manually for release sign-off. The tags show which cases also have an automated regression net behind them.

**For developers:** When a 🤖 AUTO case fails manually, check the corresponding test file first — it may indicate the test mock has drifted from real behavior. When a 👤 MANUAL case repeatedly fails, consider promoting it to a programmatic test.

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
