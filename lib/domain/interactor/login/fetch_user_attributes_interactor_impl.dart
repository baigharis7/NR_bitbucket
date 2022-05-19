
import '../../repository/login/login_repository.dart';
import 'fetch_user_attributes_interactor.dart';

class FetchUserAttributesInteractorImpl extends FetchUserAttributesInteractor {
  final LoginRepository loginRepository;

  FetchUserAttributesInteractorImpl({required this.loginRepository});

  @override
  Future<void> execute() => loginRepository.fetchUserAttributes();
}