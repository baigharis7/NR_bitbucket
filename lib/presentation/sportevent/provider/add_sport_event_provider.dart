import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

class AddSportEventProvider extends BaseProvider {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;
  final UploadSportEventsInteractor uploadSportsEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;

  AddSportEventProvider({
    required this.getUserIdInteractor,
    required this.saveSportEventInteractor,
    required this.uploadSportsEventInteractor,
    required this.getMasterFileInteractor
  });

  SportsInfoMaster? get getSportsInfo => _sportsInfo;
  bool get isInfoLoaded => _infoLoaded;
  DateTime? get getDateStart => _dateStart;
  int? get getSportId => _sportId;
  TimeOfDay? get getTimeStart => _timeStart;
  int? get getIntensity => _intensity;
  String? get getChosenSportName => _sportName;
  int? get getSportIntensities => _sportIntensities;
  int? get getMinutes => _minutes;
  bool onSaveSportEventSuccess = false;

  SportsInfoMaster? _sportsInfo;
  bool _infoLoaded = false;
  SportEventSimple? _sportEventSimple;
  DateTime? _dateStart;
  TimeOfDay? _timeStart;
  int? _intensity;
  String? _sportName;
  int? _sportIntensities;
  int? _sportId;
  int? _minutes;

  @override
  void initialize(Function onError) {
    super.initialize(onError);
    if (!isInfoLoaded) {
      _setInfoLoaded(true);
      getSportsInfo.doIfNull(_retrieveSportsInfo);
    }
  }

  List<String> getSportNames(String currentLanguage) {
    if (currentLanguage == 'es') {
      return getSportsInfo?.sportsInfoMaster.map((sport) => sport.es).toList() ?? [];
    } else {
      return getSportsInfo?.sportsInfoMaster.map((sport) => sport.en).toList() ?? [];
    }
  }

  String getSportName(/*int sportId, String currentLanguage*/) {
    // final sportChosen = getSportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
    // if (currentLanguage == 'es') {
    //   return sportChosen.es.orEmpty();
    // } else {
    //   return sportChosen.en.orEmpty();
    // }
    return _sportName.orEmpty();
  }

  void setSportName(String sportName, String currentLanguage) {
    _sportId = _findSportIdByName(sportName, currentLanguage);
    _sportName = sportName;
    _sportIntensities = _getChosenSportIntensities(currentLanguage);
    notifyListeners();
  }

  void setDateStart(DateTime dateTime) {
    _dateStart = dateTime;
    notifyListeners();
  }

  void setTimeStart(TimeOfDay timeOfDay) {
    _timeStart = timeOfDay;
    notifyListeners();
  }

  void setMinutes(int minutes) {
    _minutes = minutes;
    notifyListeners();
  }

  void setIntensity(int intensityIndex, String currentLanguage) {
    int intensitiesNumber = _findSportByName(getChosenSportName.orEmpty(), currentLanguage).mets;
    if (intensitiesNumber == 1) {
      _intensity = 0;
    } else if (intensitiesNumber > 1) {
      _intensity = intensityIndex;
    }
  }

  void onFinishClicked(Function onFinish, Function onError) {
    if (getTimeStart == null) {
      onError.call(ErrorTypes.sportEventTimeStartError);
    } else if (getDateStart == null) {
      onError.call(ErrorTypes.sportEventDateStartError);
    } else if (getSportId == null) {
      onError.call(ErrorTypes.sportEventSportIdError);
    } else if (getIntensity == null && getSportIntensities! > 1) {
      onError.call(ErrorTypes.sportEventIntensityStartError);
    } else if (getMinutes == null) {
      onError.call(ErrorTypes.sportEventMinutesStartError);
    } else {
      final sportEventSimple = SportEventSimple(
          userId: getUserIdInteractor.execute(),
          info: SportInfo(
            id: getSportId,
            minutes: getMinutes,
            timeStart: calculateMillisecondsStart(_timeStart!, _dateStart!),
            intensity: getIntensity,
          )
      );

      launchSync(
          block: () => uploadSportsEventInteractor.execute(sportEventSimple),
          onSuccess: (SportEventComplete sportEventComplete) {
            launchSync(
                block: () =>
                    saveSportEventInteractor.execute(sportEventComplete),
                onSuccess: (_) {
                  onSaveSportEventSuccess = true;
                  notifyListeners();
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    onSaveSportEventSuccess = false;
                    _sportId = null;
                    _sportName = null;
                    notifyListeners();
                    onFinish.call();
                  });
                },
                onError: (error) => onError.call(ErrorTypes.locallySavingSportEventError)
            );
          },
          onError: (Object error) => onError.call(ErrorTypes.uploadingSportEventError)
      );
    }
  }

  int calculateMillisecondsStart(TimeOfDay timeStart, DateTime dateStart) {
    DateTime dateTime = DateTime(dateStart.year, dateStart.month, dateStart.day, timeStart.hour, timeStart.minute);
    return dateTime.millisecondsSinceEpoch;
  }

  int? _getChosenSportIntensities(String currentLanguage) {
    if (getChosenSportName == null) return null;
    final sportChosen = getSportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == getChosenSportName;
      } else {
        return sport.en == getChosenSportName;
      }
    });
    return sportChosen.mets;
  }

  void _retrieveSportsInfo() async {
    launchSync(
        block: () => getMasterFileInteractor.execute(MasterFilesType.sportsInfo),
        onSuccess: (SportsInfoMaster sportsInfoMaster) {
          _setSportsInfoMaster(sportsInfoMaster);
          _setInfoLoaded(true);
        },
        onError: (Object error) {
          onError?.call(ErrorTypes.retrievingMasterFileError);
          _setInfoLoaded(false);
        }
    );
  }

  bool _setInfoLoaded(bool infoLoaded) => _infoLoaded = infoLoaded;

  void _setSportsInfoMaster(SportsInfoMaster sportsInfoMaster) => _sportsInfo = sportsInfoMaster;

  int _findSportIdByName(String name, String currentLanguage) {
    final sport = getSportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == name;
      } else {
        return sport.en == name;
      }
    });
    return sport.id;
  }

  SportInfoMaster _findSportByName(String name, String currentLanguage) {
    final sport = getSportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == name;
      } else {
        return sport.en == name;
      }
    });
    return sport;
  }

}