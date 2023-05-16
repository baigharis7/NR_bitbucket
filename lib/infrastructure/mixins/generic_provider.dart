
import 'package:nutrenaissance_flutter/presentation/common/provider/base_provider.dart';

mixin GenericProvider<U extends BaseProvider> {
  U? _provider;
  void setProvider(U? provider) => _provider = provider;
  U get getProvider => _provider!;
}