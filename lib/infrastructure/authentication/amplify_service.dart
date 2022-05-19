import 'package:amplify_flutter/amplify_flutter.dart';

class AmplifyService {
  Future<void> addPlugin(AmplifyPluginInterface plugin) async =>
      await Amplify.addPlugin(plugin);

  Future<void> configure(String configuration) async =>
      await Amplify.configure(configuration);

  AuthCategory getAuth() => Amplify.Auth;
}