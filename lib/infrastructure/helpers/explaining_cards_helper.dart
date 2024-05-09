import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/explaining_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExplainingCardsHelper {

  ExplainingCard getExplainingCardWithId({
    required BuildContext context,
    required int explainingCardId,
    Function? onHideCard,
    Function? onPressedButton,
  }) {
    final _textResolver = AppLocalizations.of(context)!;
    String? upperText;
    String? lowerText;
    String? buttonText;

    switch (explainingCardId) {
      case 0:
        upperText = _textResolver.dashboard_explaining_card;
        break;
      case 1:
        upperText = _textResolver.journal_general_explaining_card;
        break;
      case 2:
        upperText = _textResolver.journal_calendar_explaining_card;
        break;

      case 3:
        upperText = _textResolver.journal_foods_explaining_card;
        buttonText = _textResolver.add_new_food_button_text;
        break;
      case 4:
        upperText = _textResolver.journal_liquids_explaining_card;
        buttonText = _textResolver.add_new_liquid_button_text;
        break;
      case 5:
        upperText = _textResolver.journal_sports_explaining_card;
        buttonText = _textResolver.add_new_sport_button_text;
        break;

      case 6:
        upperText = _textResolver.food_add_new_event_upper_text;
        lowerText = _textResolver.food_add_new_event_lower_text;
        buttonText = _textResolver.add_new_food_button_text;
        break;
      case 7:
        upperText = _textResolver.liquid_add_new_event_upper_text;
        lowerText = _textResolver.liquid_add_new_event_lower_text;
        buttonText = _textResolver.add_new_liquid_button_text;
        break;
      case 8:
        upperText = _textResolver.sport_add_new_event_upper_text;
        lowerText = _textResolver.sport_add_new_event_lower_text;
        buttonText = _textResolver.add_new_sport_button_text;
        break;

      case 9:
        upperText = _textResolver.food_favorite_upper_text;
        lowerText = _textResolver.food_favorite_lower_text;
        buttonText = _textResolver.add_new_food_button_text;
        break;
      case 10:
        upperText = _textResolver.sport_favorite_upper_text;
        lowerText = _textResolver.sport_favorite_lower_text;
        buttonText = _textResolver.add_new_sport_button_text;
        break;
      case 11:
        upperText = _textResolver.recommendations_explaining_card;
        break;
      case 12:
        upperText = _textResolver.recipes_explaining_card;
        break;
      case 13:
        upperText = _textResolver.food_list_explaining_card;
        break;
      default:

    }
    return ExplainingCard(
      upperText: upperText.orEmpty(),
      lowerText: lowerText,
      buttonText: buttonText,
      onPressedButton: () => onPressedButton?.call(),
      onHideCard: onHideCard != null ? () => onHideCard.call() : null,
    );
  }

}