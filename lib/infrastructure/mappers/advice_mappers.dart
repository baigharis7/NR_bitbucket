import 'package:nutrenaissance_flutter/data/api/advices/model/advice_response.dart';
import 'package:nutrenaissance_flutter/domain/models/advices/advice.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

Advice mapToAdviceFromResponse(AdviceResponse adviceResponse) {
  return Advice(
      id: adviceResponse.id,
      advEs: adviceResponse.adv_es,
      advEn: adviceResponse.adv_en.orEmpty(),
      objective: adviceResponse.objective,
      interaction: adviceResponse.interaction
  );
}