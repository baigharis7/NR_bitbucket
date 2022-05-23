import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/api/profile/profile_api.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/profile/profile_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/profile_mappers.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileApi profileApi;
  final LocalStorageRepository localStorageRepository;

  ProfileRepositoryImpl({required this.profileApi, required this.localStorageRepository});

  @override
  Future<UserProfileResponse> uploadProfile(UserProfileModel profile) async {
    final uploadProfile = mapToUploadUserProfileModel(profile);
    final upload = await profileApi.uploadProfileApi(uploadProfile);
    return UserProfileResponse.fromJson(upload);
  }

  @override
  Future<void> saveProfile(UserProfileModel profileModel) async {
    final profileEntity = mapToProfileEntity(profileModel);
    localStorageRepository.saveProfile(profileEntity);
  }

  @override
  Future<UserProfileModel> getProfile() async {
    // TODO: hacer el mapper bien y devolver bien, esto es para ir tirando.
    return UserProfileModel(userId: 'userId', commonName: 'commonName', birthDate: 12313123, sex: SexType.male, occupationActivityFactor: 1.2, objectives: [3, 4, 5]);
  }

  @override
  Future<List<String>> getUserMicronutrients() async {
    List<String>? micronutrients = await localStorageRepository.getProfile().then((profile) {
      return profile.micronutrients;
    });
    // TODO: mejorar esto, un poco cutre. Poner bien el método orEmpty().
    return micronutrients ?? [];
  }

}