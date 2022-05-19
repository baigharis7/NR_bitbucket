
mixin GenericProvider<U> {
  U? _provider;
  void setProvider(U? provider) => _provider = provider;
  U get getProvider => _provider!;
}